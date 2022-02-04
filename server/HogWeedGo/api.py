import asyncio
import secrets
from functools import wraps

from django.core.mail import send_mail
from django.db import IntegrityError
from rest_framework import status
from rest_framework.authtoken.views import obtain_auth_token
from rest_framework.decorators import api_view, permission_classes, action
from rest_framework.mixins import RetrieveModelMixin, CreateModelMixin
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from rest_framework.viewsets import ViewSet, ReadOnlyModelViewSet, GenericViewSet

from HogWeedGo.models import User, Report, Comment
from HogWeedGo.serializers import UserSerializer, ReportSerializer, CommentSerializer


# TODO: make async with Django async support.


def verify_post_params(*args):
    def decorator(func):
        @wraps(func)
        def inner(request):
            for arg in args:
                if arg not in request:
                    return Response(f"Argument {arg} was not in request!", status.HTTP_400_BAD_REQUEST)
            return func(request)
        return inner
    return decorator


# TODO: check type and ext before uploading
def verify_photos(func):
    def decorator(request):
        for file in request.FILES:
            if file.size > 1000000000:
                return Response("Too large files included (over 1GB)!", status.HTTP_400_BAD_REQUEST)
        return func(request)
    return decorator


# Should NOT be awaited!
async def async_timer(secs, func):
    await asyncio.sleep(secs)
    func()


# ViewSets


proved_emails = {}


class MeViewSet(ViewSet):
    @action(methods=['PUT'], detail=False, permission_classes=[AllowAny])
    @verify_post_params("email")
    def prove_email(self, request):
        email = request.PUT["email"]
        code = secrets.token_urlsafe()
        delay = 10
        proved_emails[email] = code
        send_mail(
            "HogWeedGo authentication",
            f"Your code is: <bold>{code}</bold>\nIt will be valid for {delay} minutes.",
            None,
            recipient_list=[email]
        )
        asyncio.run(async_timer(delay * 60, lambda: proved_emails.pop(email)))
        return Response("Code was sent")

    @action(methods=['PUT'], detail=False, permission_classes=[AllowAny])
    @verify_post_params("username", "code", "password")
    def auth(self, request):
        email = request.data["username"]
        if proved_emails[email] != request.data["code"]:
            return Response("Wrong or expired code!", status.HTTP_401_UNAUTHORIZED)
        else:
            proved_emails.pop(email)
            try:
                User.objects.create_user(email, request.data["password"])
            except IntegrityError:
                return Response("User already exists!", status.HTTP_403_FORBIDDEN)
            return obtain_auth_token(request)

    @action(methods=['POST'], detail=False, permission_classes=[AllowAny])
    @verify_post_params("username", "password")
    def log_in(self, request):
        return obtain_auth_token(request)

    @action(methods=['POST'], detail=True, permission_classes=[IsAuthenticated])
    @verify_post_params("email", "code")
    def change_email(self, request):
        email = request.data["email"]
        existing = User.objects.get(email=email)
        if not existing:
            if proved_emails[email] != request.data["code"]:
                return Response("Wrong or expired code!", status.HTTP_403_FORBIDDEN)
            else:
                proved_emails.pop(email)
                request.user.email = email
                request.user.save()
                return Response("Email successfully changed")
        else:
            return Response("User with given email already exists!", status.HTTP_403_FORBIDDEN)

    @action(methods=['POST'], detail=True, permission_classes=[IsAuthenticated])
    @verify_post_params("password")
    def change_password(self, request):
        request.user.set_password(request.data["password"])
        return Response("Password successfully changed")

    @action(methods=['POST'], detail=True, permission_classes=[IsAuthenticated])
    @verify_post_params("name")
    def change_name(self, request):
        request.user.first_name = request.data["name"]
        request.user.save()
        return Response("Name updated")

    @action(methods=['DELETE'], detail=True, permission_classes=[IsAuthenticated])
    @permission_classes([IsAuthenticated])
    def log_out(self, request):
        request.user.auth_token.delete()
        return Response("Logged out successfully")

    @action(methods=['DELETE'], detail=True, permission_classes=[IsAuthenticated])
    @permission_classes([IsAuthenticated])
    def leave(self, request):
        request.user.auth_token.delete()
        request.user.delete()
        return Response("User deleted successfully")


class ReportViewSet(CreateModelMixin, ReadOnlyModelViewSet):
    serializer_class = ReportSerializer
    queryset = Report.objects.all()

    def create(self, request, *args, **kwargs):
        # TODO: set photos
        return super().create(request, *args, **kwargs)


class UserViewSet(RetrieveModelMixin, GenericViewSet):
    serializer_class = UserSerializer
    queryset = User.objects.all()


class CommentViewSet(CreateModelMixin, GenericViewSet):
    serializer_class = CommentSerializer
    queryset = Comment.objects.all()


@api_view(['GET'])
@permission_classes([AllowAny])
def healthcheck(request):
    return Response('healthy')
