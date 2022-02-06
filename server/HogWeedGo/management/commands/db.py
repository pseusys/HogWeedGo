import gzip
import json
import shutil
from gzip import BadGzipFile
from json import JSONDecodeError

from django.core import management
from django.core.management.base import BaseCommand, CommandError
from django.db import IntegrityError
from rest_framework.exceptions import ValidationError

from HogWeedGo.models import Report, User
from HogWeedGo.serializers import UserSerializer, ReportSerializer, ReportPhotoSerializer, CommentSerializer
from HogWeedGo.settings import MEDIA_ROOT


class Command(BaseCommand):
    help = "Loads data to and from DB"

    def add_arguments(self, parser):
        parser.add_argument("mode", nargs='?', choices=("load", "dump", "clear"), help="LOAD data from archive to db, DUMP data from db to archive or CLEAR db")
        parser.add_argument("--file", "-f", nargs='?', dest="file", help="File destination for loading and dumping (./backup/data by default)")
        parser.add_argument("--gzip", "-z", action="store_true", dest="gzip", help="Compression of I/O file")

    def load(self, json_data):
        def serialize(serializer, data, data_type, **serializer_args):
            res = None
            try:
                ser = serializer(data=data, **serializer_args)
                if ser.is_valid(raise_exception=True):
                    res = ser.save()
                    self.stdout.write(self.style.SUCCESS(f"{data_type} {res} saved!"))
            except ValidationError as error:
                self.stdout.write(self.style.NOTICE(f"{data_type} serializer data invalid:\n{error}"))
            return res

        try:
            if "users" in json_data:
                for user in json_data["users"]:
                    serialize(UserSerializer, user, "User", bundle_photo=True)

            if "reports" in json_data:
                for report in json_data["reports"]:
                    photos = report.pop('photos', [])
                    comments = report.pop('comments', [])
                    saved = serialize(ReportSerializer, report, "Report", from_user_input=False)
                    if saved:
                        for photo in photos:
                            serialize(ReportPhotoSerializer, photo | {'report': saved.pk}, "    Photo", bundle_photo=True)
                        for comment in comments:
                            serialize(CommentSerializer, comment | {'report': saved.pk}, "    Comment", from_user_input=False)

        except KeyError:
            raise CommandError(f"JSON data is malformed! Validate the data with ./data/data.schema.json schema.")
        except ValueError as e:
            raise CommandError(f"Validate the data with ./data/_data.schema.json schema.\n{e}")

    def dump(self):
        self.stdout.write(self.style.WARNING(f"Dumping { User.objects.count() } users and { Report.objects.count() } reports."))
        return json.dumps({
            "users": [UserSerializer(user, bundle_photo=True).data for user in User.objects.all()],
            "reports": [ReportSerializer(report, bundle_photos=True, subscribe_email=True, to_include_index=False).data for report in Report.objects.all()]
        }, indent=2)

    def clear(self):
        management.call_command('flush', interactive=False)
        self.stdout.write(self.style.SUCCESS("Database cleared."))
        try:
            shutil.rmtree(f"{MEDIA_ROOT}/report_photos")
            self.stdout.write(self.style.SUCCESS("Report photos folder deleted."))
        except FileNotFoundError:
            self.stdout.write(self.style.WARNING("Report photos folder deletion skipped - folder not present."))
        try:
            shutil.rmtree(f"{MEDIA_ROOT}/user_photos")
            self.stdout.write(self.style.SUCCESS("User photos folders deleted."))
        except FileNotFoundError:
            self.stdout.write(self.style.WARNING("User photos folders deletion skipped - folder not present."))

    def handle(self, *args, **options):
        if options["mode"] == "clear":
            self.stdout.write(self.style.WARNING("Clearing data..."))
            self.clear()
            return

        if options["file"] is None:
            options["file"] = f"./backup/data.{ 'json.gzip' if options['gzip'] else 'json' }"

        if options["mode"] == "load":
            try:
                with gzip.open(options["file"], 'r') if options["gzip"] else open(options["file"], 'r') as file:
                    self.stdout.write(self.style.WARNING(f"Loading data from file { options['file'] }..."))
                    self.load(json.loads(file.read()))
            except OSError:
                raise CommandError(f"File { options['file'] } can not be read!")
            except JSONDecodeError:
                raise CommandError(f"File { options['file'] } is not a valid JSON!")
            except (UnicodeDecodeError, BadGzipFile):
                raise CommandError(f"File { options['file'] } is wrongly encoded.")

        elif options["mode"] == "dump":
            try:
                with gzip.open(options["file"], 'wt') if options["gzip"] else open(options['file'], 'w') as file:
                    self.stdout.write(self.style.WARNING(f"Dumping data into file { options['file'] }..."))
                    file.write(self.dump())
            except OSError:
                raise CommandError(f"File { options['file'] } can not be written!")

        else:
            raise CommandError("Unknown DB interaction mode. Aborting command.")
