from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.http import HttpResponseRedirect
from django.shortcuts import redirect
from leaflet.admin import LeafletGeoAdmin

from HogWeedGo.forms import UserForm
from HogWeedGo.models import User, Report, ReportPhoto


@admin.action(description="Write an email to selected users")
def mail_to(model_admin, request, queryset):
    if "mailto" not in HttpResponseRedirect.allowed_schemes:
        HttpResponseRedirect.allowed_schemes.append('mailto')
    return redirect(f"mailto:{ ','.join([user.email for user in queryset]) }")


@admin.action(description="Make selected users inactive")
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

    list_display = ("email", "first_name", "is_staff", "last_login")
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

    def get_actions(self, request):
        actions = super().get_actions(request)
        if 'delete_selected' in actions:
            del actions['delete_selected']
        return actions

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
class ReportAdmin(LeafletGeoAdmin):
    modifiable = False

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
