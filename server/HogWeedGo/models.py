import os

from django.contrib.gis.db import models
from django.utils import timezone
from django.contrib.auth.models import AbstractUser


class User(AbstractUser):
    photo = models.ImageField(upload_to="static/user_photos", null=True)

    def delete(self, using=None, keep_parents=False):
        super().delete(self, using)
        if self.photo.name:
            os.remove(self.photo.name)

    def __str__(self):
        return f"User named { self.username } with id { self.id }"


# Class representing report status
class ReportStatuses(models.TextChoices):
    RECEIVED = "RECEIVED"
    APPROVED = "APPROVED"
    INVALID = "INVALID"


class Report(models.Model):
    class Meta:
        unique_together = [['subs', 'date']]

    address = models.CharField(max_length=128, default="")
    comment = models.CharField(max_length=1024, default="")
    date = models.DateTimeField(default=timezone.now)
    name = models.CharField(max_length=32, default="")
    place = models.PointField(db_index=True)
    status = models.CharField(max_length=8, choices=ReportStatuses.choices, default=ReportStatuses.RECEIVED)
    subs = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    type = models.CharField(max_length=64, default="")

    def __str__(self):
        return f"Report by { self.subs.username if self.subs is not None else 'null' } sent at { self.date } with id { self.id }"


class ReportPhoto(models.Model):
    report = models.ForeignKey(Report, on_delete=models.CASCADE)
    photo = models.ImageField(upload_to="static/report_photos")

    def delete(self, using=None, keep_parents=False):
        super().delete(self, using)
        os.remove(self.photo.name)

    def __str__(self):
        return f"ReportPhoto connected to report { self.report.id } with id { self.id }"
