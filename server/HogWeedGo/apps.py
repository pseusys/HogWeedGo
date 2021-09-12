from django.apps import AppConfig
from django.contrib.admin.apps import AdminConfig


class HogWeedGoConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'HogWeedGo'


class HogWeedGoAdminConfig(AdminConfig):
    default_site = 'HogWeedGo.site.SiteAdmin'
