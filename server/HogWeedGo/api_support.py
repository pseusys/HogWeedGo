import json
import random
import time
from functools import wraps
from string import ascii_letters

from django.contrib.auth import authenticate
from django.core.mail import send_mail
from django.utils.encoding import smart_str
from rest_framework import status
from rest_framework.authtoken.models import Token
from rest_framework.pagination import LimitOffsetPagination
from rest_framework.parsers import MultiPartParser, ParseError
from rest_framework.renderers import BaseRenderer
from rest_framework.response import Response

from HogWeedGo import settings


class PlainTextRenderer(BaseRenderer):
    media_type = 'text/plain'
    format = 'txt'

    def render(self, data, media_type=None, renderer_context=None):
        return smart_str(data, encoding=self.charset)


class MultiPartJSONParser(MultiPartParser):
    def parse(self, stream, media_type=None, parser_context=None):
        data_and_files = super(MultiPartJSONParser, self).parse(stream, media_type, parser_context)
        try:
            json_data = json.loads(data_and_files.data['data'])
        except ValueError as e:
            raise ParseError(f"JSON parse error - {e}")
        data_and_files.data = data_and_files.data.copy()
        data_and_files.data.update(json_data)
        del data_and_files.data['data']
        return data_and_files


def verify_params(method, *args):
    def decorator(func):
        @wraps(func)
        def inner(self, request):
            data = request.data if method.lower() in ('post', 'put', 'patch') else request.query_params
            for arg in args:
                if arg not in data:
                    return Response(f"Argument {arg} was not in request!", status.HTTP_400_BAD_REQUEST)
            return func(self, request)
        return inner
    return decorator


# TODO: check type and ext before uploading
def verify_photos(func):
    def decorator(self, request):
        for file in request.FILES:
            if file.size > 1000000000:
                return Response("Too large files included (over 1GB)!", status.HTTP_400_BAD_REQUEST)
        return func(self, request)
    return decorator


def random_token(size=8, email='', delay_minutes=10):
    random.seed(f'{settings.SECRET_KEY}{email}{time.time() // delay_minutes // 60}')
    return ''.join(random.choices(ascii_letters, k=size))


def auth(request, email, password):
    user = authenticate(request, email=email, password=password)
    if user:
        token, _ = Token.objects.get_or_create(user=user)
        return Response(f'Token {str(token)}')
    else:
        return Response(f'Can not log in user with email: {email}, password: {password}!', status.HTTP_400_BAD_REQUEST)


# FD: when other auth methods added, transfer this to user model.
def send_email(subject, message, from_email, recipient_list, fail_silently=False, auth_user=None, auth_password=None, connection=None, html_message=None):
    if settings.MOCK_SMTP_SERVER:
        return Response({'subject': subject, 'message': message, 'recipients': recipient_list})
    else:
        send_mail(subject, message, from_email, recipient_list, fail_silently, auth_user, auth_password, connection, html_message)
        return Response("Code was sent")


class OptionalLimitOffsetPagination(LimitOffsetPagination):
    default_limit = 100

    def __init__(self):
        self.request = None
        self.offset = None
        self.count = None
        self.limit = None

    def paginate_queryset(self, queryset, request, view=None):
        self.count = self.get_count(queryset)

        self.limit = self.get_limit(request)
        if self.limit is None:
            self.limit = self.count

        self.offset = self.get_offset(request)
        self.request = request
        if self.count > self.limit and self.template is not None:
            self.display_page_controls = True

        if self.count == 0 or self.offset > self.count:
            return []
        return list(queryset[self.offset:self.offset + self.limit])
