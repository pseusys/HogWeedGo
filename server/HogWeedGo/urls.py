from django.contrib import admin
from django.urls import path, include
from rest_framework.routers import SimpleRouter

from HogWeedGo.api import MeViewSet, ReportViewSet, UserViewSet, CommentViewSet, healthcheck

router = SimpleRouter(trailing_slash=False)
router.register('me', MeViewSet, basename='me')
router.register('reports', ReportViewSet, basename='report')
router.register('users', UserViewSet, basename='user')
router.register('comments', CommentViewSet, basename='comment')

urlpatterns = [
    path('healthcheck', healthcheck),
    path('api/', include(router.urls)),
    path('', admin.site.urls)
]
