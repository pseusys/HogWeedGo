from django.contrib import admin

from HogWeedGo.models import Report


class SiteAdmin(admin.AdminSite):
    site_title = "HogWeedGo"
    site_header = "HogWeedGo administration"

    index_title = "HogWeedGo"
    index_template = "admin/index.html"

    empty_value_display = "null"
    site_url = None

    def get_app_list(self, request):
        return list(filter(lambda app: app["app_label"] == "HogWeedGo", super().get_app_list(request)))

    @staticmethod
    def extractor(report):
        return {"coords": [report.place[1], report.place[0]], "id": report.id}

    def index(self, request, extra_context=None):
        return super().index(request, extra_context or {"markers": list(map(self.extractor, Report.objects.all()))})
