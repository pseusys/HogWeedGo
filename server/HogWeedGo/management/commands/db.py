import gzip
import json
import shutil
from gzip import BadGzipFile
from json import JSONDecodeError

from django.core import management
from django.core.management.base import BaseCommand, CommandError
from django.db import IntegrityError

from HogWeedGo.models import Report, User
from HogWeedGo.serializers import UserSerializer, ReportSerializer


class Command(BaseCommand):
    help = "Loads data to and from DB"

    def add_arguments(self, parser):
        parser.add_argument("mode", nargs='?', choices=("load", "dump", "clear"), help="LOAD data from archive to db, DUMP data from db to archive or CLEAR db")
        parser.add_argument("--file", "-f", nargs='?', dest="file", help="File destination for loading and dumping (./sample/data by default)")
        parser.add_argument("--gzip", "-z", action="store_true", dest="gzip", help="Compression of I/O file")

    def load(self, json_data):
        try:
            if "users" in json_data:
                for user in json_data["users"]:
                    try:
                        self.stdout.write(self.style.SUCCESS(f"{ UserSerializer.parse(user) } saved!"))
                    except IntegrityError:
                        self.stdout.write(self.style.NOTICE("Integrity problem, some of the users already present!"))

            if "reports" in json_data:
                for report in json_data["reports"]:
                    try:
                        self.stdout.write(self.style.SUCCESS(f"{ ReportSerializer.parse(report) } saved!"))
                    except IntegrityError:
                        self.stdout.write(self.style.NOTICE("Integrity problem, some of the reports already present!"))

        except KeyError:
            raise CommandError(f"JSON data is malformed! Validate the data with ./data/data.schema.json schema.")
        except ValueError as e:
            raise CommandError(f"{ e }\nValidate the data with ./data/_data.schema.json schema.")

    def dump(self):
        self.stdout.write(self.style.WARNING(f"Dumping { User.objects.count() } users and { Report.objects.count() } reports."))
        return json.dumps({
            "users": [UserSerializer.encode(user, True) for user in User.objects.all()],
            "reports": [ReportSerializer.encode(report, True) for report in Report.objects.all()]
        }, indent=2)

    def handle(self, *args, **options):
        if options["mode"] == "clear":
            management.call_command('flush', interactive=False)
            self.stdout.write(self.style.SUCCESS("Database cleared."))
            try:
                shutil.rmtree("static/report_photos")
                self.stdout.write(self.style.SUCCESS("Report photos folder deleted."))
            except FileNotFoundError:
                self.stdout.write(self.style.WARNING("Report photos folder deletion skipped - folder not present."))
            try:
                shutil.rmtree("static/user_photos")
                self.stdout.write(self.style.SUCCESS("User photos folders deleted."))
            except FileNotFoundError:
                self.stdout.write(self.style.WARNING("User photos folders deletion skipped - folder not present."))
            return

        options.setdefault("file", f"./sample/data.{ 'json.gzip' if options['gzip'] else 'json' }")

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
