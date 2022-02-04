from django.contrib import admin
from django.urls import path
from rest_framework.authtoken.views import obtain_auth_token

from HogWeedGo import api


urlpatterns = [
    path('prove_email', api.prove_email),
    path('auth', api.auth),
    path('log_in', obtain_auth_token),
    path('change_email', api.change_email),
    path('change_password', api.change_password),
    path('log_out', api.log_out),
    path('leave', api.leave),

    path('poll_reports', api.poll_reports),
    path('get_reports', api.get_reports),
    path('get_report/<int:report_id>', api.get_report),
    path('users/<int:user_id>', api.get_user),

    path('set_report', api.set_report),
    path('set_comment', api.set_comment),
    path('update_name', api.update_name),
    path('update_photo', api.update_photo),

    path('healthcheck', api.healthcheck),

    path('', admin.site.urls)
]
