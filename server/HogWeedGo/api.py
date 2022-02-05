import random
import time
from functools import wraps
from string import ascii_letters

from django.contrib.auth import authenticate
from django.core.mail import send_mail
from django.db import IntegrityError
from rest_framework import status
from rest_framework.authtoken.models import Token
from rest_framework.decorators import api_view, permission_classes, action, schema
from rest_framework.mixins import RetrieveModelMixin, CreateModelMixin
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from rest_framework.schemas.openapi import AutoSchema
from rest_framework.throttling import UserRateThrottle
from rest_framework.viewsets import ViewSet, ReadOnlyModelViewSet, GenericViewSet

from HogWeedGo import settings
from HogWeedGo.api_schema import MeSchema, ReportsSchema
from HogWeedGo.models import User, Report, Comment
from HogWeedGo.serializers import UserSerializer, ReportSerializer, CommentSerializer


# TODO: make async with Django async support.


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
    return ''.join(random.choice(ascii_letters) for _ in range(size))


# ViewSets


class MeViewSet(ViewSet):
    schema = MeSchema(tags=['me'], operation_id_base='Me')

    @action(methods=['GET'], detail=False, permission_classes=[AllowAny])
    @verify_params('GET', "email")
    def prove_email(self, request):
        email = request.query_params.get('email')
        token = random_token(email=email)
        send_mail(
            "HogWeedGo authentication",
            f"Your confirmation code is: <bold>{token}</bold>\nIt will be valid for 10 minutes.",
            None,
            recipient_list=[email]
        )
        return Response("Code was sent")

    @action(methods=['GET'], detail=False, permission_classes=[AllowAny], throttle_classes=[UserRateThrottle])
    @verify_params('GET', "email", "code", "password")
    def auth(self, request):
        email = request.query_params.get('email')
        token = random_token(email=email)
        if token != request.data["code"]:
            return Response("Wrong or expired code!", status.HTTP_401_UNAUTHORIZED)
        try:
            User.objects.create_user(email, request.data["password"])
        except IntegrityError:
            return Response("User already exists!", status.HTTP_403_FORBIDDEN)
        password = request.query_params.get('password')
        token, _ = Token.objects.get_or_create(user=authenticate(request, email=email, password=password))
        return Response(f'Token {str(token)}')

    @action(methods=['GET'], detail=False, permission_classes=[AllowAny], throttle_classes=[UserRateThrottle])
    @verify_params('GET', "email", "password")
    def log_in(self, request):
        email = request.query_params.get('email')
        password = request.query_params.get('password')
        token, _ = Token.objects.get_or_create(user=authenticate(request, email=email, password=password))
        return Response(f'Token {str(token)}')

    @action(methods=['POST'], detail=False, permission_classes=[IsAuthenticated])
    def setup(self, request):
        results = {}
        if 'email' in request.data and 'code' in request.data:
            email = request.data['email']
            token = random_token(email=email)
            existing = User.objects.get(email=email)
            if existing:
                if token != request.data["code"]:
                    results |= {'email': "Wrong or expired code!"}
                else:
                    request.user.email = email
                    results |= {'email': "Saved!"}
            else:
                results += {'email': "User with given email already exists!"}
        if 'password' in request.data:
            request.user.set_password(request.data['password'])
            results |= {'password': "Saved!"}
        if 'name' in request.data:
            request.user.first_name = request.data['name']
            results |= {'name': "Saved!"}
        if 'photo' in request.data:
            results |= {'photo': "TODO: implement!"}
            # TODO: update user photo
        request.user.save()
        return Response(results)

    @action(methods=['DELETE'], detail=False, permission_classes=[IsAuthenticated])
    def log_out(self, request):
        request.user.auth_token.delete()
        return Response("Logged out successfully")

    @action(methods=['DELETE'], detail=False, permission_classes=[IsAuthenticated])
    def leave(self, request):
        request.user.auth_token.delete()
        request.user.delete()
        return Response("User deleted successfully")


class ReportViewSet(CreateModelMixin, ReadOnlyModelViewSet):
    schema = ReportsSchema()
    serializer_class = ReportSerializer
    queryset = Report.objects.all()

    def get_throttles(self):
        if self.action == 'create':
            return [UserRateThrottle()]
        else:
            return []

    def create(self, request, *args, **kwargs):
        # TODO: set photos
        return super().create(request, *args, **kwargs)


class UserViewSet(RetrieveModelMixin, GenericViewSet):
    schema = AutoSchema(tags=['user'])
    serializer_class = UserSerializer
    queryset = User.objects.all()


class CommentViewSet(CreateModelMixin, GenericViewSet):
    schema = AutoSchema(tags=['comment'])
    throttle_classes = [UserRateThrottle]
    serializer_class = CommentSerializer
    queryset = Comment.objects.all()


@api_view(['GET'])
@permission_classes([AllowAny])
@schema(AutoSchema(tags='health', operation_id_base='Health'))
def healthcheck(request):
    return Response('healthy')
