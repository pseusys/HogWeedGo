from django.contrib.postgres.fields import ArrayField
from django.contrib.gis.db import models
from django.utils import timezone
from django.contrib.auth.models import User


class Reporter(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    photo = models.ImageField(null=True)


# Class representing report status
class ReportStatuses(models.TextChoices):
    RECEIVED = "RECEIVED"
    APPROVED = "APPROVED"
    INVALID = "INVALID"


class Report(models.Model):
    address = models.CharField(max_length=128, default="")
    comment = models.CharField(max_length=1024, default="")
    date = models.DateTimeField(default=timezone.now)
    name = models.CharField(max_length=32, default="")
    photos = ArrayField(models.ImageField(), default=list)
    place = models.PointField(db_index=True)
    status = models.CharField(max_length=8, choices=ReportStatuses.choices, default=ReportStatuses.RECEIVED)
    subs = models.ManyToManyField(User)
    type = models.CharField(max_length=64, default="")
