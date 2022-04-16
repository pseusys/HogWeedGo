from django.contrib.gis.db import models
from django.contrib.auth.models import AbstractUser
from django.utils.translation import gettext_lazy as _

from HogWeedGo.image_utils import create_thumbnail
from HogWeedGo.managers import UserManager


class User(AbstractUser):
    class Meta:
        verbose_name = "User"
        ordering = ["email"]

    username = None
    email = models.EmailField(_('email address'), unique=True, error_messages={"unique": _("A user with that email already exists.")})
    last_name = None
    groups = None
    user_permissions = None
    photo = models.ImageField(upload_to="user_photos", null=True, blank=True, help_text="User profile photo.")
    thumbnail = models.ImageField(upload_to="thumbnails", null=True, blank=True, help_text="User profile photo thumbnail.")

    REQUIRED_FIELDS = []
    USERNAME_FIELD = "email"

    objects = UserManager()

    def save(self, *args, **kwargs):
        if self.photo:
            self.thumbnail.save(self.photo.name.split('/')[-1], create_thumbnail(self.photo), save=False)
        else:
            self.thumbnail.delete(save=False)
        super(User, self).save(*args, **kwargs)

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
        verbose_name = "Report"

    address = models.CharField(max_length=128, null=True, help_text=_("Address defined by user. May be just a geo-related recommendation."))
    init_comment = models.TextField(max_length=2048, help_text=_("User comment about the report."))
    date = models.DateTimeField(help_text=_("Date specified by user for his observation."))
    place = models.PointField()
    status = models.CharField(max_length=8, choices=ReportStatuses.choices, help_text=_("Report status."))
    subs = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, help_text=_("The sender of the report, subscription."))
    type = models.CharField(max_length=64, help_text=_("Staff reply for the report."))

    def __str__(self):
        return f"Report by { self.subs.email if self.subs is not None else 'null' } sent at { self.date.strftime('%Y-%m-%d %H:%M') } with id { self.id }"


class ReportPhoto(models.Model):
    class Meta:
        verbose_name = "Photo"

    report = models.ForeignKey(Report, on_delete=models.CASCADE, help_text="Report this photo is attached to")
    photo = models.ImageField(upload_to="report_photos", help_text="The photo itself")
    thumbnail = models.ImageField(upload_to="thumbnails", null=True, help_text="The photo thumbnail")

    def save(self, *args, **kwargs):
        self.thumbnail.save(self.photo.name.split('/')[-1], create_thumbnail(self.photo), save=False)
        super(ReportPhoto, self).save(*args, **kwargs)

    def __str__(self):
        return f"ReportPhoto (report { self.report.id }) with id { self.id }"


class Comment(models.Model):
    class Meta:
        verbose_name = "Comment"

    report = models.ForeignKey(Report, on_delete=models.CASCADE, help_text="Report this comment is attached to")
    subs = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, help_text="Author of the comment")
    text = models.TextField(max_length=2048, help_text=_("A comment, added to a report by another user."))

    def __str__(self):
        return f"Comment (report { self.report.id }) with id { self.id }"
