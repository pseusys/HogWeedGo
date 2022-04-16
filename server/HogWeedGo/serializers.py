from datetime import datetime

from django.contrib.gis.geos import Point
from django.utils.timezone import make_aware
from rest_framework.exceptions import ParseError
from rest_framework.serializers import ModelSerializer
from rest_framework.fields import empty

from HogWeedGo import settings
from HogWeedGo.image_utils import store_file, restore_file
from HogWeedGo.models import Report, User, Comment, ReportPhoto, ReportStatuses


def _to_datetime(timestamp):
    return make_aware(datetime.fromtimestamp(timestamp / 1000.0))


def _from_datetime(dt):
    return int(dt.timestamp() * 1000)


# Serializers:


class StateModelSerializer(ModelSerializer):
    def __init__(self, instance=None, data=empty, mode=None, **kwargs):
        modes = self.Meta.modes
        self.mode = mode if mode else getattr(self.Meta, 'default_mode', modes[0])
        assert self.mode in modes, f"Unknown mode: {self.mode}"
        super(StateModelSerializer, self).__init__(instance, data, **kwargs)


class UserSerializer(StateModelSerializer):
    class Meta:
        modes = ['user', 'backup']
        model = User
        fields = ['password', 'last_login', 'is_superuser', 'email', 'first_name', 'is_staff', 'is_active', 'date_joined', 'photo', 'thumbnail']

    def to_representation(self, instance):
        rep = super(UserSerializer, self).to_representation(instance)
        rep['last_login'] = _from_datetime(instance.last_login) if instance.last_login else None
        rep['date_joined'] = _from_datetime(instance.date_joined)
        if self.mode == 'backup':
            rep.pop('thumbnail', None)
            if instance.photo:
                data, name = store_file(instance.photo)
                rep['photo'] = {'data': data, 'name': name}
        else:
            rep.pop('password', None)
            rep.pop('is_superuser', None)
            rep.pop('email', None)
            rep.pop('is_active', None)
            rep.pop('date_joined', None)
            rep['photo'] = f'{settings.MEDIA_URL}{instance.photo.name}'
            rep['thumbnail'] = f'{settings.MEDIA_URL}{instance.thumbnail.name}'
        return rep

    def to_internal_value(self, data):
        data['last_login'] = _to_datetime(data['last_login']) if data['last_login'] else None
        data['date_joined'] = _to_datetime(data['date_joined'])
        if self.mode == 'backup':
            data.pop('password', None)
            data.pop('thumbnail', None)
            if data['photo']:
                data['photo'] = restore_file(data['photo']['data'], data['photo']['name'])
        else:
            raise ParseError("UserSerializer can not parse User object in 'user' mode!")
        return super(UserSerializer, self).to_internal_value(data)


class ReportSerializer(StateModelSerializer):
    class Meta:
        modes = ['user', 'backup', 'table']
        model = Report
        fields = ['address', 'init_comment', 'date', 'status', 'subs', 'type', 'place']

    def to_representation(self, instance):
        rep = super(ReportSerializer, self).to_representation(instance)
        rep['subs'] = (instance.subs.email if self.mode == 'backup' else instance.subs.id) if instance.subs else None
        if self.mode == 'table':
            rep['longitude'] = instance.place[0]
            rep['latitude'] = instance.place[1]
            del rep['place']
        else:
            rep['date'] = _from_datetime(instance.date)
            rep['place'] = {'lng': instance.place[0], 'lat': instance.place[1]}
            rep['photos'] = [ReportPhotoSerializer(photo, mode=self.mode).data for photo in ReportPhoto.objects.filter(report=instance)]
            rep['comments'] = [CommentSerializer(comment, mode=self.mode).data for comment in Comment.objects.filter(report=instance)]
        if self.mode == 'user':
            rep['id'] = instance.pk
        return rep

    def to_internal_value(self, data):
        if self.mode == 'user':
            data['date'] = datetime.now()
            data['status'] = ReportStatuses.RECEIVED
            data['subs'] = self.context['request'].user.pk
        else:
            data['date'] = _to_datetime(data['date'])
            data['subs'] = User.objects.get(email=data.pop('subs')).pk
        data['place'] = Point(data['place']['lng'], data['place']['lat'])
        return super(ReportSerializer, self).to_internal_value(data)


class ReportPhotoSerializer(StateModelSerializer):
    class Meta:
        modes = ['user', 'backup']
        model = ReportPhoto
        fields = ['report', 'photo', 'thumbnail']

    def to_representation(self, instance):
        rep = super(ReportPhotoSerializer, self).to_representation(instance)
        rep.pop('report', None)
        if self.mode == 'backup':
            rep.pop('thumbnail', None)
            data, name = store_file(instance.photo)
            rep['photo'] = {'data': data, 'name': name}
        else:
            rep['photo'] = f'{settings.MEDIA_URL}{instance.photo.name}'
            rep['thumbnail'] = f'{settings.MEDIA_URL}{instance.thumbnail.name}'
        return rep

    def to_internal_value(self, data):
        data['thumbnail'] = None
        if self.mode == 'backup':
            data['photo'] = restore_file(data['photo']['data'], data['photo']['name'])
        return super(ReportPhotoSerializer, self).to_internal_value(data)


class CommentSerializer(StateModelSerializer):
    class Meta:
        modes = ['user', 'backup']
        model = Comment
        fields = ['report', 'text', 'subs']

    def to_representation(self, instance):
        rep = super(CommentSerializer, self).to_representation(instance)
        rep.pop('report', None)
        rep['subs'] = (instance.subs.email if self.mode == 'backup' else instance.subs.id) if instance.subs else None
        return rep

    def to_internal_value(self, data):
        data['subs'] = self.context['request'].user.pk if self.mode == 'user' else User.objects.get(email=data.pop('subs')).pk
        return super(CommentSerializer, self).to_internal_value(data)
