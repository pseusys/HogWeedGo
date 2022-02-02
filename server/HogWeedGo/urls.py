"""HogWeedGo URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/3.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path

from HogWeedGo import api

urlpatterns = [
    path('prove_email', api.prove_email),
    path('auth', api.auth),
    path('log_in', api.log_in),
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
