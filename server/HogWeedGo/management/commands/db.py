import gzip
import json
from urllib.request import urlopen
from json import JSONDecodeError
from urllib.error import URLError

from django.core import management
from django.contrib.auth.models import User
from django.core.management.base import BaseCommand, CommandError
from django.core.serializers.base import DeserializationError

from HogWeedGo.models import Report, ReportImage, Reporter


class Command(BaseCommand):
    help = "Loads data to and from DB"

    def add_arguments(self, parser):
        parser.add_argument("mode", nargs='?', choices=("load", "dump", "clear"), help="LOAD data from archive to db, DUMP data from db to archive or CLEAR db")
        parser.add_argument("--file", "-f", nargs='?', dest="file", help="JSON file source")
        parser.add_argument("--url", "-u", nargs='?', dest="url", help="URL data source")
        parser.add_argument("--gzip", "-z", action="store_true", dest="gzip", help="Compression of I/O file")

    def load(self, json_data):
        try:
            if "users" in json_data:
                for user in json_data["users"]:
                    if User.objects.filter(username=user["username"]).exists():
                        raise CommandError(f"{ User.objects.get(username=user['username']) } already in database!")
                    usr = Reporter.decode(user, True)
                    usr.save()
                    self.stdout.write(self.style.SUCCESS(f"{ usr } saved!"))

            if "reports" in json_data:
                for report in json_data["reports"]:
                    if report["subs"] is None:
                        user = None
                    elif User.objects.filter(username=report["subs"]).exists():
                        user = User.objects.get(username=report["subs"])
                    else:
                        raise CommandError(f"{ report['subs'] } does not exist!")

                    rep = Report.decode(report, True, subs=user)
                    if Report.objects.filter(date=rep.date, subs=rep.subs).exists():
                        raise CommandError(f"{ rep } already in database!")
                    rep.save()
                    self.stdout.write(self.style.SUCCESS(f"{ rep } saved!"))

                    for photo in report["photos"]:
                        img = ReportImage.decode(photo, True, report=rep)
                        img.save()
                        self.stdout.write(self.style.SUCCESS(f"{ img } saved!"))

        except KeyError:
            raise CommandError(f"JSON data is malformed! Validate the data with ./sample_data.scheme.json scheme.")
        except (ValueError, DeserializationError) as e:
            raise CommandError(f"{ e }\nValidate the data with ./sample_data.scheme.json scheme.")

    def dump(self):
        omni = {"users": [], "reports": []}
        omni["users"].append([reporter.encode(True) for reporter in Reporter.objects.all()])
        for report in Report.objects.all():
            photos = [photo.encode(True) for photo in ReportImage.objects.filter(report=report)]
            omni["reports"].append(report.encode(True) | {"photos": photos})
        return json.dumps(omni, indent=2)

    def fetch(self, options):
        if options["file"] is not None:
            try:
                file = open(options["file"], 'r') if options["gzip"] is False else gzip.open(options["file"], 'r')
            except OSError:
                raise CommandError(f"File { options['file'] } can not be opened!")

            try:
                data = json.loads(file.read())
                file.close()
            except JSONDecodeError:
                file.close()
                raise CommandError(f"File { options['file'] } is not a valid JSON!")
            except (UnicodeDecodeError, gzip.BadGzipFile):
                raise CommandError("Source file is wrongly encoded.")

            self.stdout.write(self.style.SUCCESS(f"Loading data from file { options['file'] }..."))
            self.load(data)

        elif options["url"] is not None:
            try:
                url = urlopen(options["url"]) if options["gzip"] is False else gzip.decompress(urlopen(options["url"]))
            except URLError:
                raise CommandError(f"URL { options['url'] } can not be fetched!")

            try:
                data = json.loads(url.read().decode())
            except JSONDecodeError:
                raise CommandError(f"Data available by URL { options['url'] } is not a valid JSON!")
            except (UnicodeDecodeError, gzip.BadGzipFile):
                raise CommandError("Source data is wrongly encoded.")

            self.stdout.write(self.style.SUCCESS(f"Loading data from URL { options['url'] }..."))
            self.load(data)

        else:
            raise CommandError("No data source specified. Aborting command.")

    def handle(self, *args, **options):
        if options["mode"] == "load":
            self.fetch(options)

        elif options["mode"] == "dump":
            if options["gzip"]:
                with gzip.open("./data/data.gzip", "wb") as f:
                    f.write(bytes(self.dump(), "ascii"))
            else:
                with open("./data/data.json", "w") as f:
                    f.write(self.dump())

        elif options["mode"] == "clear":
            management.call_command('flush', verbosity=1, interactive=False)

        else:
            raise CommandError("Unknown DB interaction mode. Aborting command.")
