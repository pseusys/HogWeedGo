import os
import uuid

from django.contrib import admin
from django.contrib.gis.db import models
from django.core.files import File
from django.utils import timezone
from django.contrib.auth.models import AbstractUser
from django.utils.html import format_html
from django.utils.translation import gettext_lazy as _

from HogWeedGo.managers import UserManager


def set_photo(image, raw):
    image.save(f"{str(uuid.uuid4())}.png", File(raw), False)
    image.flush()


class User(AbstractUser):
    class Meta:
        verbose_name = "User"
        ordering = ["email"]

    username = None
    email = models.EmailField(_('email address'), unique=True, error_messages={"unique": _("A user with that email already exists.")})
    last_name = None
    groups = None
    user_permissions = None
    photo = models.ImageField(upload_to="static/user_photos", null=True)

    REQUIRED_FIELDS = []
    USERNAME_FIELD = "email"

    objects = UserManager()

    def delete(self, using=None, keep_parents=False):
        if self.photo.name:
            os.remove(self.photo.name)
        super().delete(using, keep_parents)

    @admin.display(description="User photo")
    def photo_tag(self):
        return format_html(f'<img src="/{self.photo.name}" alt={str(self)}/>')

    def __str__(self):
        return f"User { self.email } with id { self.id }"


# Class representing report status
class ReportStatuses(models.TextChoices):
    RECEIVED = "RECEIVED"
    APPROVED = "APPROVED"
    INVALID = "INVALID"


class Report(models.Model):
    class Meta:
        unique_together = [["subs", "date"]]
        indexes = [models.Index(fields=["name"])]
        verbose_name = "Report"

    address = models.CharField(max_length=128, help_text=_("Address defined by user. May be just a geo-related recommendation."), default="")
    init_comment = models.TextField(max_length=2048, help_text=_("User comment about the report."), default="")
    date = models.DateTimeField(default=timezone.now, help_text=_("Date specified by user for his observation."))
    name = models.CharField(max_length=32, help_text=_("The name of the report marker on map."), default="")
    place = models.PointField()
    status = models.CharField(max_length=8, choices=ReportStatuses.choices, help_text=_("Report status."), default=ReportStatuses.RECEIVED)
    subs = models.ForeignKey(User, on_delete=models.SET_NULL, help_text=_("The sender of the report, subscription."), null=True)
    type = models.CharField(
        max_length=64,
        help_text=_("Staff reply for the report. NB! Auto type check appends ' | NN%' to guessed type, thus everything after '|' is omitted by filtering."),
        default=""
    )

    def exact_type(self):
        delim = self.type.find('|')
        return self.type[:delim - 1] if delim != -1 else self.type

    @admin.display(description="User", ordering="subs__email")
    def user_name(self):
        return (f"{ self.subs.first_name } ({ self.subs.email })" if self.subs.first_name else self.subs.email) if self.subs else None

    def __str__(self):
        return f"Report by { self.subs.email if self.subs is not None else 'null' } sent at { self.date.strftime('%Y-%m-%d %H:%M') } with id { self.id }"


class ReportPhoto(models.Model):
    class Meta:
        verbose_name = "Photo"

    report = models.ForeignKey(Report, on_delete=models.CASCADE)
    photo = models.ImageField(upload_to="static/report_photos")

    def delete(self, using=None, keep_parents=False):
        os.remove(self.photo.name)
        super().delete(using, keep_parents)

    @admin.display(description="Report photo")
    def photo_tag(self):
        return format_html(f'<img src="/{ self.photo.name }" alt={ str(self) }/>')

    def __str__(self):
        return f"ReportPhoto (report { self.report.id }) with id { self.id }"


class Comment(models.Model):
    class Meta:
        verbose_name = "Comment"

    report = models.ForeignKey(Report, on_delete=models.CASCADE)
    subs = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    text = models.TextField(max_length=2048, help_text=_("A comment, added to a report by another user."), default="")

    def __str__(self):
        return f"Comment (report { self.report.id }) with id { self.id }"
