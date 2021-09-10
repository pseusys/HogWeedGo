import base64
import io
import os
import uuid
from datetime import datetime

from django.contrib.gis.db import models
from django.core.files import File
from django.utils import timezone
from django.contrib.auth.models import User
from django.utils.timezone import make_aware
from django.contrib.gis.geos import Point


class Serializable:
    def encode(self, img_bundle):
        pass

    @staticmethod
    def decode(data, img_bundle, **foreign):
        pass


def _to_datetime(timestamp):
    return make_aware(datetime.fromtimestamp(timestamp / 1000.0))


def _from_datetime(dt):
    return int(dt.timestamp() * 1000)


def _to_base64(data):
    return base64.b64encode(data).decode("utf-8")


def _from_base64(base):
    return base64.b64decode(base.encode("utf-8"))


class Reporter(models.Model, Serializable):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    photo = models.ImageField(upload_to="static/user_photos", null=True)

    def delete(self, using=None, keep_parents=False):
        super().delete(self, using)
        if self.photo.name:
            os.remove(self.photo.name)

    def encode(self, img_bundle):
        photo = None
        if self.photo.name:
            if img_bundle:
                photo = _to_base64(self.photo.read())
            else:
                photo = self.photo.name.split('/', 1)[1]
        return {
            "password": self.user.password,
            "last_login": _from_datetime(self.user.last_login),
            "is_superuser": self.user.is_superuser,
            "username": self.user.username,
            "first_name": self.user.first_name,
            "last_name": self.user.last_name,
            "email": self.user.email,
            "is_staff": self.user.is_staff,
            "is_active": self.user.is_active,
            "date_joined": _from_datetime(self.user.date_joined),
            "groups": [i.id for i in self.user.groups.all()],
            "user_permissions": [i.id for i in self.user.user_permissions.all()],
            "photo": photo
        }

    @staticmethod
    def decode(data, img_bundle, **foreign):
        user = User.objects.create(**{x: data[x] for x in data if x not in ["password", "photo", "groups", "user_permissions", "last_login", "date_joined"]})
        user.password = data["password"]
        user.last_login = _to_datetime(data["last_login"])
        user.date_joined = _to_datetime(data["date_joined"])
        for group in data["groups"]:
            user.groups.add(name=group)
        for permission in data["user_permissions"]:
            user.user_permissions.add(name=permission)
        user.save()

        rep = Reporter(user=user)
        if data["photo"] is not None and img_bundle:
            rep.photo.save(f"{str(uuid.uuid4())}.png", File(io.BytesIO(_from_base64(data["photo"]))), save=False)
            rep.photo.flush()
        else:
            rep.photo = None
        return rep


# Class representing report status
class ReportStatuses(models.TextChoices):
    RECEIVED = "RECEIVED"
    APPROVED = "APPROVED"
    INVALID = "INVALID"


class Report(models.Model, Serializable):
    class Meta:
        unique_together = [['subs', 'date']]

    address = models.CharField(max_length=128, default="")
    comment = models.CharField(max_length=1024, default="")
    date = models.DateTimeField(default=timezone.now)
    name = models.CharField(max_length=32, default="")
    place = models.PointField(db_index=True)
    status = models.CharField(max_length=8, choices=ReportStatuses.choices, default=ReportStatuses.RECEIVED)
    subs = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    type = models.CharField(max_length=64, default="")

    def encode(self, img_bundle):
        return {
            "address": self.address,
            "comment": self.comment,
            "date": _from_datetime(self.date),
            "name": self.name,
            "place": {"long": self.place[0], "lat": self.place[1]},
            "status": self.status,
            "subs": self.subs.username if self.subs else None,
            "type": self.type
        }

    @staticmethod
    def decode(data, img_bundle, **foreign):
        rep = Report(**{x: data[x] for x in data if x not in ["date", "place", "subs", "photos"]}, subs=foreign["subs"])
        rep.date = _to_datetime(data["date"])
        rep.place = Point(data["place"]["long"], data["place"]["lat"])
        return rep

    def __str__(self):
        return f"Report by {self.subs.username if self.subs is not None else 'null'} sent at {self.date} with id {self.id}"


class ReportImage(models.Model, Serializable):
    report = models.ForeignKey(Report, on_delete=models.CASCADE)
    image = models.ImageField(upload_to="static/report_photos")

    def delete(self, using=None, keep_parents=False):
        super().delete(self, using, keep_parents)
        os.remove(self.image.name)

    def encode(self, img_bundle):
        return _to_base64(self.image.read()) if img_bundle else self.image.name.split('/', 1)[1]

    @staticmethod
    def decode(data, img_bundle, **foreign):
        img = ReportImage(report=foreign["report"])
        if img_bundle:
            img.image.save(f"{str(uuid.uuid4())}.png", File(io.BytesIO(_from_base64(data))), save=False)
            img.image.flush()
        return img
