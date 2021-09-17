import asyncio
import secrets
import time

from django.contrib.auth import authenticate, login, logout
from django.core.mail import send_mail
from django.db import IntegrityError
from django.http import JsonResponse, StreamingHttpResponse, HttpResponse, HttpResponseBadRequest, HttpResponseForbidden
from django.shortcuts import get_object_or_404
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST, require_GET

from HogWeedGo.models import User, Report, set_photo
from HogWeedGo.serializers import UserSerializer, ReportSerializer


# TODO: make async with Django async support.


class HttpResponseUnauthorized(HttpResponse):
    status_code = 401

    def __init__(self, content=None, *args, **kwargs):
        super().__init__(content if content else "Authentication required!", *args, **kwargs)


def verify_request(request, *params):
    for param in params:
        if param not in request:
            return HttpResponseBadRequest(f"{ param } was not in request.")
    return None


# Should NOT be awaited!
async def async_timer(secs, func):
    await asyncio.sleep(secs)
    func()


# Auth


proved_emails = {}


@csrf_exempt
@require_POST
def prove_email(request):
    response = verify_request(request.POST, "email")
    if response:
        return response

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


@csrf_exempt
@require_POST
def auth(request):
    response = verify_request(request.POST, "email", "code", "password")
    if response:
        return response

    email = request.POST["email"]

    if proved_emails[email] != request.POST["code"]:
        return HttpResponseUnauthorized("Wrong or expired code!")
    else:
        proved_emails.pop(email)
        try:
            User.objects.create_user(email, request.POST["password"])
        except IntegrityError:
            return HttpResponseForbidden("User already exists!")
        return log_in(request)


@csrf_exempt
@require_POST
def log_in(request):
    response = verify_request(request.POST, "email", "password")
    if response:
        return response

    user = authenticate(request, email=request.POST["email"], password=request.POST["password"])

    if user is not None:
        login(request, user)
        return HttpResponse("Logged in successfully!")
    else:
        return HttpResponseUnauthorized("Can not log in!")


@require_POST
def change_email(request):
    if not request.user.is_authenticated:
        return HttpResponseUnauthorized()

    response = verify_request(request.POST, "email", "code")
    if response:
        return response

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


@require_POST
def change_password(request):
    if not request.user.is_authenticated:
        return HttpResponseUnauthorized()

    response = verify_request(request.POST, "password")
    if response:
        return response

    request.user.set_password(request.POST["password"])
    return HttpResponse("Password successfully changed!")


@require_POST
def log_out(request):
    if not request.user.is_authenticated:
        return HttpResponseUnauthorized()

    logout(request)
    return HttpResponse("Logged out successfully!")


@require_POST
def leave(request):
    if not request.user.is_authenticated:
        return HttpResponseUnauthorized()

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


@require_GET
def poll_reports(request):
    if not request.user.is_authenticated:
        return HttpResponseUnauthorized()

    return StreamingHttpResponse(_event_stream(), content_type="text/event-stream")


@require_GET
def get_reports(request):
    if not request.user.is_authenticated:
        return HttpResponseUnauthorized()

    return JsonResponse([ReportSerializer.encode(x) for x in Report.objects.all()])


@require_GET
def get_report(request, report_id):
    if not request.user.is_authenticated:
        return HttpResponseUnauthorized()

    return JsonResponse(ReportSerializer.encode(get_object_or_404(Report, pk=report_id)))


@require_GET
def get_user(request, user_id):
    if not request.user.is_authenticated:
        return HttpResponseUnauthorized()

    return JsonResponse(UserSerializer.encode(get_object_or_404(User, pk=user_id)))


# Set data


recent_reporters = []


@require_POST
def set_report(request):
    if not request.user.is_authenticated:
        return HttpResponseUnauthorized()

    if request.user.email in recent_reporters:
        return HttpResponseForbidden("Reporting too fast!")

    response = verify_request(request.POST, "report")
    if response:
        return response

    photos = []
    for file in request.FILES:
        if file.size > 1000000000:
            return HttpResponseBadRequest("Too large files included (over 1GB)!")
        else:
            photos.append(file)

    asyncio.run(async_timer(60, lambda: recent_reporters.append(request.user.email)))
    ReportSerializer.parse(request.POST["report"], photos, request.user)
    return HttpResponse("Report sent!")


@require_POST
def set_comment(request):
    pass


@require_POST
def update_name(request):
    if not request.user.is_authenticated:
        return HttpResponseUnauthorized()

    response = verify_request(request.POST, "name")
    if response:
        return response

    request.user.first_name = request.POST["name"]
    request.user.save()
    return HttpResponse("Name updated!")


@require_POST
def update_photo(request):
    if not request.user.is_authenticated:
        return HttpResponseUnauthorized()

    if request.FILES[0].size > 1000000000:
        return HttpResponseBadRequest("Too large files included (over 1GB)!")
    else:
        file = request.FILES[0]

    set_photo(request.user.photo, file.read())
    request.user.save()
    return HttpResponse("Name updated!")
