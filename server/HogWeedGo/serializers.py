import base64
import uuid
from datetime import datetime
from io import BytesIO

from django.contrib.auth.models import User
from django.contrib.gis.geos import Point
from django.core.files import File
from django.core.serializers.base import SerializationError, DeserializationError
from django.core.serializers.json import Serializer
from django.utils.timezone import make_aware

from HogWeedGo.models import Reporter, Report, ReportImage


def _from_datetime(dt):
    return int(dt.timestamp() * 1000)


def _from_base64(base):
    return base64.b64decode(base.encode("utf-8"))


def _serialize_user(user, ):
    return {
        "password": user.password,
        "last_login": _from_datetime(user.last_login),
        "is_superuser": user.is_superuser,
        "username": user.username,
        "first_name": user.first_name,
        "is_staff": user.is_staff,
        "is_active": user.is_active,
        "date_joined": _from_datetime(user.date_joined),
        "groups": [i.id for i in user.groups.all()],
        "user_permissions": [i.id for i in user.user_permissions.all()],
    }


class HogWeedGoSerializer(Serializer):
    def _init_options(self):
        super()._init_options()
        self.img_bundle = self.json_kwargs.pop('img_bundle', False)

    def get_dump_object(self, obj):
        return self._current

    def handle_field(self, obj, field):
        value = self._value_from_field(obj, field)
        if type(obj) == Reporter:
            if field.name == "user":
                self._current |= _serialize_user(value)
            elif field.name == "photo":
                photo = None
                if value.photo.name:
                    photo = self._serialize_photo(value)
                self._current[field.name] = photo
            else:
                super().handle_field(self, obj)
        elif type(obj) == Report:
            if field.name == "date":
                self._current[field.name] = _from_datetime(value)
            if field.name == "place":
                self._current[field.name] = {"long": value[0], "lat": value[1]}
            if field.name == "subs":
                self._current[field.name] = value.username if value else None
        elif type(obj) == ReportImage:
            if field.name == "date":
                self._current[field.name] = self._serialize_photo(value)
        else:
            raise SerializationError(f"Unknown model type { type(obj) }!")

    def _serialize_photo(self, photo):
        return _to_base64(photo.read()) if self.img_bundle else photo.name.split('/', 1)[1]


def _to_datetime(timestamp):
    return make_aware(datetime.fromtimestamp(timestamp / 1000.0))


def _to_base64(data):
    return base64.b64encode(data).decode("utf-8")


def _create_user(data):
    user = User.objects.create(**{x: data[x] for x in data if x not in ["password", "groups", "user_permissions", "last_login", "date_joined"]})
    user.password = data["password"]
    user.email = user.username
    user.last_login = _to_datetime(data["last_login"])
    user.date_joined = _to_datetime(data["date_joined"])
    for group in data["groups"]:
        user.groups.add(name=group)
    for permission in data["user_permissions"]:
        user.user_permissions.add(name=permission)
    user.save()
    return user


def HogWeedGoDeserializer(object_list, **options):
    img_bundle = options.pop('img_bundle', False)
    model_class = options.pop('model_class', None)
    report = options.pop('report', None)
    model_list = []

    for obj in object_list:
        if model_class == Reporter:
            if User.objects.filter(username=obj["username"]).exists():
                raise DeserializationError(f"{User.objects.get(username=obj['username'])} already in database!")
            photo = obj.pop("photo")
            user = _create_user(obj)
            rep = Reporter(user=user)
            if photo is not None and img_bundle:
                rep.photo.save(f"{str(uuid.uuid4())}.png", File(BytesIO(_from_base64(photo))), save=False)
                rep.photo.flush()
            else:
                rep.photo = None
            model_list.append(rep)

        elif model_class == Report:
            parent = obj.pop("subs")
            if parent is None:
                user = None
            elif User.objects.filter(username=parent).exists():
                user = User.objects.get(username=parent)
            else:
                raise DeserializationError(f"{ parent } does not exist!")
            rep = Report(**{x: obj[x] for x in obj if x not in ["date", "place", "photos"]}, subs=user)
            rep.date = _to_datetime(obj["date"])
            rep.place = Point(obj["place"]["long"], obj["place"]["lat"])
            model_list.append(rep)

        elif model_class == ReportImage:
            if not report:
                raise DeserializationError(f"Parent report does not exist!")
            img = ReportImage(report=report)
            if img_bundle:
                img.image.save(f"{str(uuid.uuid4())}.png", File(BytesIO(_from_base64(obj))), save=False)
                img.image.flush()
            model_list.append(img)

        else:
            raise DeserializationError(f"Unknown model type { model_class }!")
