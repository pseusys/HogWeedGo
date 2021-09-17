import base64
import uuid
from io import BytesIO

from asgiref.sync import sync_to_async
from django.contrib.gis.geos import Point
from django.core.files import File
from django.utils.datetime_safe import datetime
from django.utils.timezone import make_aware

from HogWeedGo.models import User, ReportPhoto, Report, set_photo


class Serializer:
    @staticmethod
    def encode(model):
        raise NotImplementedError('subclasses of Serializer must provide an encode() method')

    @staticmethod
    def parse(data):
        raise NotImplementedError('subclasses of Serializer must provide an parse() method')


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
            set_photo(user.photo, BytesIO(_from_base64(photo)))
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
            set_photo(photo.photo, data["photo"])
            photo.save()
        return photo


class ReportSerializer(Serializer):
    @staticmethod
    def encode(model, bundle_photos=False, trim=False):
        data = {
            "address": model.address,
            "comment": model.comment,
            "date": _from_datetime(model.date),
            "name": model.name,
            "status": model.status,
            "subs": model.subs.email if model.subs else None,
            "type": model.type
        }
        if trim:
            return data | {
                "longitude": model.place[0],
                "latitude": model.place[1]
            }
        else:
            return data | {
                "place": {"lng": model.place[0], "lat": model.place[1]},
                "photos": [ReportPhotoSerializer.encode(photo, bundle_photo=bundle_photos) for photo in ReportPhoto.objects.filter(report=model)]
            }

    @staticmethod
    def parse(data, loaded_photos=None, assigned=None):
        photos = data.pop("photos")

        data["date"] = _to_datetime(data["date"])
        data["place"] = Point(data["place"]["lng"], data["place"]["lat"])
        if assigned:
            data["subs"] = assigned
        elif data["subs"]:
            data["subs"] = User.objects.get(email=data.pop("subs"))

        report = Report.objects.create(**data)

        # TODO: NEURO API ENTRY

        for photo in photos:
            ReportPhotoSerializer.parse({"report": report, "photo": BytesIO(_from_base64(photo))})

        if loaded_photos:
            for photo in photos:
                ReportPhotoSerializer.parse({"report": report, "photo": photo})

        return report
