import uuid
from base64 import b64encode, b64decode
from datetime import datetime
from io import BytesIO

from django.contrib.gis.geos import Point
from django.core.files import File
from django.utils.timezone import make_aware
from rest_framework.serializers import ModelSerializer
from rest_framework.fields import empty

from HogWeedGo.models import Report, User, Comment, ReportPhoto


def _to_datetime(timestamp):
    return make_aware(datetime.fromtimestamp(timestamp / 1000.0))


def _from_datetime(dt):
    return int(dt.timestamp() * 1000)


def _to_base64(data):
    return b64encode(data).decode('utf-8')


def _from_base64(base):
    return b64decode(base.encode('utf-8'))


# Serializers:


class UserSerializer(ModelSerializer):
    class Meta:
        model = User
        fields = ['password', 'last_login', 'is_superuser', 'email', 'first_name', 'is_staff', 'is_active', 'date_joined', 'photo']

    def __init__(self, instance=None, data=empty, **kwargs):
        self.bundle_photo = kwargs.pop('bundle_photo', False)
        super(UserSerializer, self).__init__(instance, data, **kwargs)

    def to_representation(self, instance):
        rep = super(UserSerializer, self).to_representation(instance)
        rep['last_login'] = _from_datetime(instance.last_login) if instance.last_login else None
        rep['date_joined'] = _from_datetime(instance.date_joined)
        if instance.photo:
            if self.bundle_photo:
                rep['photo'] = _to_base64(instance.photo.read())
        return rep

    def to_internal_value(self, data):
        data['last_login'] = _to_datetime(data['last_login']) if data['last_login'] else None
        data['date_joined'] = _to_datetime(data['date_joined'])
        if self.bundle_photo and data['photo']:
            data['photo'] = File(BytesIO(_from_base64(data['photo'])), f'{str(uuid.uuid4())}.png')
        return super(UserSerializer, self).to_internal_value(data)


class ReportSerializer(ModelSerializer):
    class Meta:
        model = Report
        fields = ['address', 'init_comment', 'date', 'status', 'subs', 'type', 'place']

    def __init__(self, instance=None, data=empty, **kwargs):
        self.subscribe_email = kwargs.pop('subscribe_email', False)
        self.bundle_photos = kwargs.pop('bundle_photos', False)
        self.trim = kwargs.pop('trim', False)
        self.assigned = kwargs.pop('assigned', None)
        super(ReportSerializer, self).__init__(instance, data, **kwargs)

    def to_representation(self, instance):
        rep = super(ReportSerializer, self).to_representation(instance)
        rep['date'] = _from_datetime(instance.date)
        rep['subs'] = (instance.subs.email if self.subscribe_email else instance.subs.id) if instance.subs else None
        if self.trim:
            rep.longitude = instance.place[0]
            rep.latitude = instance.place[1]
        else:
            rep['place'] = {'lng': instance.place[0], 'lat': instance.place[1]}
            rep['photos'] = [ReportPhotoSerializer(photo, bundle_photo=True).data for photo in ReportPhoto.objects.filter(report=instance)]
            rep['comments'] = [CommentSerializer(comment, subscribe_email=self.subscribe_email).data for comment in Comment.objects.filter(report=instance)]
        return rep

    def to_internal_value(self, data):
        data['date'] = _to_datetime(data['date'])
        data['place'] = Point(data['place']['lng'], data['place']['lat'])
        if self.assigned:
            data['subs'] = self.assigned
        elif data['subs']:
            data['subs'] = User.objects.get(email=data.pop('subs')).pk
        return super(ReportSerializer, self).to_internal_value(data)


class ReportPhotoSerializer(ModelSerializer):
    class Meta:
        model = ReportPhoto
        fields = ['report', 'photo']

    def __init__(self, instance=None, data=empty, **kwargs):
        self.bundle_photo = kwargs.pop('bundle_photo', False)
        super(ReportPhotoSerializer, self).__init__(instance, data, **kwargs)

    def to_representation(self, instance):
        rep = super(ReportPhotoSerializer, self).to_representation(instance)
        del rep['report']
        if self.bundle_photo:
            rep['photo'] = _to_base64(instance.photo.read())
        return rep

    def to_internal_value(self, data):
        if self.bundle_photo:
            data['photo'] = File(BytesIO(_from_base64(data['photo'])), f'{str(uuid.uuid4())}.png')
        return super(ReportPhotoSerializer, self).to_internal_value(data)


class CommentSerializer(ModelSerializer):
    class Meta:
        model = Comment
        fields = ['report', 'text', 'subs']

    def __init__(self, instance=None, data=empty, **kwargs):
        self.subscribe_email = kwargs.pop('subscribe_email', False)
        self.assigned = kwargs.pop('assigned', False)
        super(CommentSerializer, self).__init__(instance, data, **kwargs)

    def to_representation(self, instance):
        rep = super(CommentSerializer, self).to_representation(instance)
        del rep['report']
        rep['subs'] = (instance.subs.email if self.subscribe_email else instance.subs.id) if instance.subs else None
        return rep

    def to_internal_value(self, data):
        if self.assigned:
            data['subs'] = self.assigned
        else:
            data['subs'] = User.objects.get(email=data.pop('subs')).pk
        inter = super(CommentSerializer, self).to_internal_value(data)
        return inter
