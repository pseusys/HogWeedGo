import asyncio
import secrets
import time
from functools import wraps

from django.contrib.auth import logout
from django.core.mail import send_mail
from django.db import IntegrityError
from django.http import JsonResponse, StreamingHttpResponse, HttpResponse, HttpResponseBadRequest, HttpResponseForbidden
from django.shortcuts import get_object_or_404
from rest_framework.authtoken.views import obtain_auth_token
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny

from HogWeedGo.models import User, Report, set_photo
from HogWeedGo.serializers import UserSerializer, ReportSerializer, CommentSerializer


# TODO: make async with Django async support.


class HttpResponseUnauthorized(HttpResponse):
    status_code = 401

    def __init__(self, content=None, *args, **kwargs):
        super().__init__(content if content else "Authentication required!", *args, **kwargs)


def verify_post_params(*args):
    def decorator(func):
        @wraps(func)
        def inner(request):
            print(request.__dict__)
            for arg in args:
                if arg not in request:
                    return HttpResponseBadRequest(f"{arg} was not in request.")
            return func(request)
        return inner
    return decorator


def verify_resent_actors(func):
    def decorator(request):
        if request.user.email in recent_actors:
            return HttpResponseForbidden("Commenting too fast!")
        return func(request)
    return decorator


# TODO: echeck type and ext before uploading
def verify_file_size(func):
    def decorator(request):
        for file in request.FILES:
            if file.size > 1000000000:
                return HttpResponseBadRequest("Too large files included (over 1GB)!")
        return func(request)
    return decorator


# Should NOT be awaited!
async def async_timer(secs, func):
    await asyncio.sleep(secs)
    func()


# Auth


proved_emails = {}


@api_view(['POST'])
@permission_classes([AllowAny])
@verify_post_params("email")
def prove_email(request):
    email = request.POST["email"]
    code = secrets.token_urlsafe()
    delay = 10
    proved_emails[email] = code

    send_mail(
        "HogWeedGo authentication",
        f"Your code is: <bold>{ code }</bold>\nIt will be valid for { delay } minutes.",
        None,
        recipient_list=[email]
    )

    asyncio.run(async_timer(delay * 60, lambda: proved_emails.pop(email)))
    return HttpResponse("Code was sent.")


@api_view(['POST'])
@permission_classes([AllowAny])
@verify_post_params("username", "code", "password")
def auth(request):
    email = request.POST["username"]

    if proved_emails[email] != request.POST["code"]:
        return HttpResponseUnauthorized("Wrong or expired code!")
    else:
        proved_emails.pop(email)
        try:
            User.objects.create_user(email, request.POST["password"])
        except IntegrityError:
            return HttpResponseForbidden("User already exists!")
        return obtain_auth_token(request)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
@verify_post_params("email", "code")
def change_email(request):
    email = request.POST["email"]
    existing = User.objects.get(email=email)

    if not existing:
        if proved_emails[email] != request.POST["code"]:
            return HttpResponseForbidden("Wrong or expired code!")
        else:
            proved_emails.pop(email)
            request.user.email = email
            request.user.save()
            return HttpResponse("Email successfully changed!")
    else:
        return HttpResponseForbidden("User with given email already exists!")


@api_view(['POST'])
@permission_classes([IsAuthenticated])
@verify_post_params("password")
def change_password(request):
    request.user.set_password(request.POST["password"])
    return HttpResponse("Password successfully changed!")


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def log_out(request):
    logout(request)
    return HttpResponse("Logged out successfully!")


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def leave(request):
    request.user.delete()
    logout(request)
    return HttpResponse("User deleted out successfully!")


# Get data


def _event_stream():
    available = []
    while True:
        data = Report.objects.exclude(pk__in=available)
        for report in data:
            available.append(report.pk)
            yield ReportSerializer.encode(report)
        time.sleep(5)


@api_view(['GET'])
@permission_classes([AllowAny])
def poll_reports(request):
    return StreamingHttpResponse(_event_stream(), content_type="text/event-stream")


@api_view(['GET'])
@permission_classes([AllowAny])
def get_reports(request):
    return JsonResponse([ReportSerializer.encode(x) for x in Report.objects.all()])


@api_view(['GET'])
@permission_classes([AllowAny])
def get_report(request, report_id):
    return JsonResponse(ReportSerializer.encode(get_object_or_404(Report, pk=report_id)))


@api_view(['GET'])
@permission_classes([AllowAny])
def get_user(request, user_id):
    return JsonResponse(UserSerializer.encode(get_object_or_404(User, pk=user_id)))


# Set data


recent_actors = []


@api_view(['POST'])
@permission_classes([IsAuthenticated])
@verify_post_params("report")
@verify_resent_actors
@verify_file_size
def set_report(request):
    asyncio.run(async_timer(20, lambda: recent_actors.append(request.user.email)))
    ReportSerializer.parse(request.POST["report"], request.FILES, request.user)
    return HttpResponse("Report sent!")


@api_view(['POST'])
@permission_classes([IsAuthenticated])
@verify_post_params("comment")
@verify_resent_actors
def set_comment(request):
    asyncio.run(async_timer(20, lambda: recent_actors.append(request.user.email)))
    CommentSerializer.parse(request.POST["comment"], request.user)
    return HttpResponse("Comment sent!")


@api_view(['POST'])
@permission_classes([IsAuthenticated])
@verify_post_params("name")
def update_name(request):
    request.user.first_name = request.POST["name"]
    request.user.save()
    return HttpResponse("Name updated!")


@api_view(['POST'])
@permission_classes([IsAuthenticated])
@verify_file_size
def update_photo(request):
    set_photo(request.user.photo, request.FILES[0].read())
    request.user.save()
    return HttpResponse("Name updated!")


@api_view(['GET'])
@permission_classes([AllowAny])
def healthcheck(request):
    return HttpResponse('healthy')
