from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.contrib.auth.models import User

from HogWeedGo.models import Reporter, Report, ReportImage


# Define an inline admin descriptor for Employee model
# which acts a bit like a singleton
class EmployeeInline(admin.StackedInline):
    model = Reporter
    can_delete = False
    verbose_name = 'reporter'


# Define a new User admin
class UserAdmin(BaseUserAdmin):
    inlines = [EmployeeInline]


class ReportImageInline(admin.StackedInline):
    model = ReportImage
    can_delete = False
    verbose_name = 'rep image'
    extra = 0


# Define a new User admin
class ReportAdmin(admin.ModelAdmin):
    date_hierarchy = "date"
    inlines = [ReportImageInline]


# Re-register UserAdmin
admin.site.unregister(User)
admin.site.register(User, UserAdmin)

admin.site.register(Report, ReportAdmin)
