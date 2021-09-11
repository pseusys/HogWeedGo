from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin

from HogWeedGo.models import User, Report, ReportPhoto


# Define a new User admin
class UserAdmin(BaseUserAdmin):
    pass


class ReportPhotoInline(admin.StackedInline):
    model = ReportPhoto
    can_delete = False
    verbose_name = 'rep image'
    extra = 0


# Define a new User admin
class ReportAdmin(admin.ModelAdmin):
    date_hierarchy = "date"
    inlines = [ReportPhotoInline]


# Re-register UserAdmin
admin.site.register(User, UserAdmin)

admin.site.register(Report, ReportAdmin)
