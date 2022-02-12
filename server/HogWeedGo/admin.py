import csv
import tempfile

from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.http import HttpResponseRedirect, FileResponse
from django.shortcuts import redirect
from leaflet.admin import LeafletGeoAdmin

from HogWeedGo.forms import UserForm
from HogWeedGo.models import User, Report, ReportPhoto, Comment
from HogWeedGo.serializers import ReportSerializer


@admin.action(description="Write an email to selected Users")
def mail_to(model_admin, request, queryset):
    if "mailto" not in HttpResponseRedirect.allowed_schemes:
        HttpResponseRedirect.allowed_schemes.append('mailto')
    return redirect(f"mailto:{','.join([user.email for user in queryset])}")


@admin.action(description="Make selected Users inactive")
def ban(model_admin, request, queryset):
    for user in queryset:
        user.is_active = False
        user.save()


# Define a new User admin
@admin.register(User)
class UserAdmin(BaseUserAdmin):
    readonly_fields = ["email", "last_login", "date_joined", "photo_tag"]
    filter_horizontal = []
    form = UserForm

    list_display = ("email", "first_name", "is_active", "is_staff", "last_login")
    list_filter = ("is_staff", "is_superuser")
    search_fields = ["email", "first_name"]
    ordering = ["email"]
    actions = [mail_to, ban]

    fieldsets = (
        (None, {
            "fields": [("email", "first_name"), "password_recovery"]
        }),
        ("Status", {
            "fields": ("is_active", "is_staff", "is_superuser")
        }),
        ("History", {
            "fields": [("date_joined", "last_login")]
        }),
        ("User photo", {
            "fields": [("photo", "photo_tag")]
        })
    )

    def has_add_permission(self, request):
        return False

    def has_change_permission(self, request, obj=None):
        return request.user.is_superuser or (obj and obj.id == request.user.id)


@admin.action(description="Dump selected Reports as .CSV")
def dump(model_admin, request, queryset):
    data = [ReportSerializer(report, mode='table').data for report in queryset]
    with tempfile.SpooledTemporaryFile(mode="w", newline="") as tmp:
        fc = csv.DictWriter(tmp, fieldnames=data[0].keys())
        fc.writeheader()
        fc.writerows(data)
        tmp.seek(0)
        file_response = FileResponse(tmp.read(), as_attachment=True, filename="reports.csv")
        file_response.set_headers(tmp)
        return file_response


class ReportPhotoInline(admin.StackedInline):
    fields = ["photo_tag"]
    readonly_fields = ["photo_tag"]

    model = ReportPhoto
    extra = 0

    def has_add_permission(self, request, obj):
        return False

    def has_change_permission(self, request, obj=None):
        return False


class CommentInline(admin.TabularInline):
    fields = ["subs", "text"]
    readonly_fields = ["subs"]

    model = Comment
    extra = 0

    def has_add_permission(self, request, obj):
        return False


# Define a new User admin
@admin.register(Report)
class ReportAdmin(LeafletGeoAdmin):
    modifiable = False

    date_hierarchy = "date"
    readonly_fields = ["date", "subs"]
    inlines = [ReportPhotoInline, CommentInline]

    list_display = ("date", "user_name", "status")
    list_editable = ["status"]
    list_filter = ["status"]
    actions = [dump]

    fieldsets = (
        (None, {
            "fields": (("address", "date"), "type", ("status", "subs"))
        }),
        (None, {
            "fields": ("place", "init_comment"),
            "classes": ["wide"]
        })
    )

    def has_add_permission(self, request):
        return False
