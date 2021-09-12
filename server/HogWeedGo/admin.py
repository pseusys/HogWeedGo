from django.contrib.auth.models import Group
from django.contrib.gis import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin, GroupAdmin

from HogWeedGo.models import User, Report, ReportPhoto


# Define a new User admin
@admin.register(User)
class UserAdmin(BaseUserAdmin):
    empty_value_display = "null"
    readonly_fields = ["email", "last_login", "date_joined", "photo_tag"]
    filter_horizontal = []

    list_display = ("email", "first_name", "is_staff", "last_login")
    list_filter = ("is_staff", "is_superuser")
    search_fields = ["email", "first_name"]
    ordering = ["email"]

    fieldsets = (
        (None, {
            "fields": [("email", "first_name")]
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


class ReportPhotoInline(admin.StackedInline):
    fields = ["photo_tag"]
    readonly_fields = ["photo_tag"]

    model = ReportPhoto
    extra = 0

    def has_add_permission(self, request, obj):
        return False

    def has_change_permission(self, request, obj=None):
        return False


# Define a new User admin
@admin.register(Report)
class ReportAdmin(admin.OSMGeoAdmin):
    modifiable = False
    point_zoom = 10

    empty_value_display = "null"
    date_hierarchy = "date"
    readonly_fields = ["date", "subs"]
    inlines = [ReportPhotoInline]

    list_display = ("name", "date", "user_name", "status")
    list_editable = ["status"]
    list_filter = ("status", "type")
    search_fields = ["name"]

    fieldsets = (
        (None, {
            "fields": (("name", "subs"), ("address", "date"), ("type", "status"))
        }),
        (None, {
            "fields": ("place", "comment"),
            "classes": ["wide"]
        })
    )

    def has_add_permission(self, request):
        return False


admin.site.unregister(Group)


@admin.register(Group)
class ForbiddenGroupAdmin(GroupAdmin):
    def has_module_permission(self, request):
        return False
