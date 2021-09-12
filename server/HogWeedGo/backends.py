from django.contrib.auth.backends import ModelBackend
from django.contrib.auth.models import Permission


class SimpleBackend(ModelBackend):
    staff = (
        "view_user",
        "change_report", "delete_report", "view_report",
        "delete_reportphoto", "view_reportphoto"
    )

    def _get_user_permissions(self, user_obj):
        return Permission.objects.filter(codename__in=self.staff) if user_obj.is_staff else Permission.objects.none()

    def _get_group_permissions(self, user_obj):
        return Permission.objects.none()
