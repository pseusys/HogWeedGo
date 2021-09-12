import base64
import uuid
from io import BytesIO

from django.contrib.gis.geos import Point
from django.core.files import File
from django.utils.datetime_safe import datetime
from django.utils.timezone import make_aware

from HogWeedGo.models import User, ReportPhoto, Report


class Serializer:
    @staticmethod
    def encode(model):
        pass

    @staticmethod
    def parse(data):
        pass


def _to_datetime(timestamp):
    return make_aware(datetime.fromtimestamp(timestamp / 1000.0))


def _from_datetime(dt):
    return int(dt.timestamp() * 1000)


def _to_base64(data):
    return base64.b64encode(data).decode("utf-8")


def _from_base64(base):
    return base64.b64decode(base.encode("utf-8"))


class UserSerializer(Serializer):
    @staticmethod
    def encode(model, bundle_photo=False):
        photo = None

        if model.photo.name:
            if bundle_photo:
                photo = _to_base64(model.photo.read())
            else:
                photo = model.photo.name.split('/', 1)[1]

        return {
            "password": model.password,
            "last_login": _from_datetime(model.last_login) if model.last_login else None,
            "is_superuser": model.is_superuser,
            "email": model.email,
            "first_name": model.first_name,
            "is_staff": model.is_staff,
            "is_active": model.is_active,
            "date_joined": _from_datetime(model.date_joined),
            "photo": photo
        }

    @staticmethod
    def parse(data):
        password = data.pop("password")
        photo = data.pop("photo")

        data["last_login"] = _to_datetime(data["last_login"]) if data["last_login"] else None
        data["date_joined"] = _to_datetime(data["date_joined"])

        user = User.objects.create(**data)
        user.password = password

        if photo:
            user.photo.save(f"{str(uuid.uuid4())}.png", File(BytesIO(_from_base64(photo))))
            user.photo.flush()
        else:
            user.photo = None
            user.save()

        return user


class ReportPhotoSerializer(Serializer):
    @staticmethod
    def encode(model, bundle_photo=False):
        return _to_base64(model.photo.read()) if bundle_photo else model.photo.name.split('/', 1)[1]

    @staticmethod
    def parse(data):
        photo = ReportPhoto(report=data["report"])
        if data["photo"]:
            photo.photo.save(f"{str(uuid.uuid4())}.png", File(BytesIO(_from_base64(data["photo"]))))
            photo.photo.flush()
        return photo


class ReportSerializer(Serializer):
    @staticmethod
    def encode(model, bundle_photos=False):
        return {
            "address": model.address,
            "comment": model.comment,
            "date": _from_datetime(model.date),
            "name": model.name,
            "place": {"long": model.place[0], "lat": model.place[1]},
            "status": model.status,
            "subs": model.subs.email if model.subs else None,
            "type": model.type,
            "photos": [ReportPhotoSerializer.encode(photo, bundle_photo=bundle_photos) for photo in ReportPhoto.objects.filter(report=model)],
        }

    @staticmethod
    def parse(data):
        photos = data.pop("photos")

        data["date"] = _to_datetime(data["date"])
        data["place"] = Point(data["place"]["long"], data["place"]["lat"])
        if data["subs"]:
            data["subs"] = User.objects.filter(email=data.pop("subs"))[0]

        report = Report.objects.create(**data)

        for photo in photos:
            ReportPhotoSerializer.parse({"report": report, "photo": photo})

        return report
