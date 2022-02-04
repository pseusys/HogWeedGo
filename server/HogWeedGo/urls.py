from django.contrib import admin
from django.urls import path
from rest_framework.routers import DefaultRouter

from HogWeedGo.api import MeViewSet, ReportViewSet, UserViewSet, CommentViewSet, healthcheck

router = DefaultRouter()
router.register('me', MeViewSet, basename='me')
router.register('reports', ReportViewSet, basename='report')
router.register('users', UserViewSet, basename='user')
router.register('comments', CommentViewSet, basename='comment')

urlpatterns = [
    path('healthcheck', healthcheck),
    path('', admin.site.urls)
] + router.urls
