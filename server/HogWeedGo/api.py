import time

from django.http import StreamingHttpResponse, JsonResponse
from django.shortcuts import get_object_or_404

from HogWeedGo.models import User, Report
from HogWeedGo.serializers import UserSerializer


# Auth


def authenticate(request, user_id):
    pass


def log_in(request, user_id):
    pass


def change_email(request, user_id):
    pass


def change_password(request, user_id):
    pass


# Get data


def _event_stream(available):
    while True:
        data = Report.objects.exclude(pk__in=available)
        for report in data:
            available.append(report.pk)
            yield f"Report: The server time is: { report }\n\n"
        time.sleep(5)
        yield f"No time changes...\n\n"


def poll_reports(request):
    return StreamingHttpResponse(_event_stream([]), content_type="text/event-stream")


def get_report(request):
    pass


def get_user(request, user_id):
    user = get_object_or_404(User, pk=user_id)
    return JsonResponse(UserSerializer.encode(user))


# Set data


def set_report(request):
    pass


def set_comment(request):
    pass


def set_user(request):
    pass
