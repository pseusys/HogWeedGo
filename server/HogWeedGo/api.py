from django.db import IntegrityError
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes, action, schema, renderer_classes
from rest_framework.exceptions import ValidationError
from rest_framework.mixins import RetrieveModelMixin, CreateModelMixin
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.renderers import JSONRenderer
from rest_framework.response import Response
from rest_framework.schemas.openapi import AutoSchema
from rest_framework.throttling import UserRateThrottle
from rest_framework.viewsets import ViewSet, ReadOnlyModelViewSet, GenericViewSet

from HogWeedGo.api_schema import MeSchema, ReportsSchema
from HogWeedGo.api_support import PlainTextRenderer, verify_params, random_token, auth, send_email
from HogWeedGo.models import User, Report, Comment
from HogWeedGo.serializers import UserSerializer, ReportSerializer, CommentSerializer


# TODO: make async with Django async support.


# ViewSets


class MeViewSet(ViewSet):
    schema = MeSchema(tags=['me'], operation_id_base='Me')

    @action(methods=['GET'], detail=False, permission_classes=[AllowAny], renderer_classes=[JSONRenderer, PlainTextRenderer])
    @verify_params('GET', "email")
    def prove_email(self, request):
        email = request.query_params.get('email')
        token = random_token(email=email)
        return send_email("HogWeedGo authentication", f"Your confirmation code is: '{token}'\nIt will be valid for 10 minutes.", None, recipient_list=[email])

    @action(methods=['GET'], detail=False, permission_classes=[AllowAny], throttle_classes=[UserRateThrottle], renderer_classes=[PlainTextRenderer])
    @verify_params('GET', "email", "code", "password")
    def auth(self, request):
        email = request.query_params.get('email')
        token = random_token(email=email)
        if token != request.query_params.get('code'):
            return Response("Wrong or expired code!", status.HTTP_401_UNAUTHORIZED)
        try:
            User.objects.create_user(email, request.query_params.get('password'))
        except IntegrityError:
            return Response("User already exists!", status.HTTP_403_FORBIDDEN)
        return auth(request, email, request.query_params.get('password'))

    @action(methods=['GET'], detail=False, permission_classes=[AllowAny], throttle_classes=[UserRateThrottle], renderer_classes=[PlainTextRenderer])
    @verify_params('GET', "email", "password")
    def log_in(self, request):
        return auth(request, request.query_params.get('email'), request.query_params.get('password'))

    @action(methods=['POST'], detail=False, permission_classes=[IsAuthenticated])
    def setup(self, request):
        results = {}
        if 'email' in request.data and 'code' in request.data:
            email = request.data['email']
            token = random_token(email=email)
            existing = User.objects.get(email=email)
            if existing:
                if token != request.data["code"]:
                    results |= {'email': "Wrong or expired code!"}
                else:
                    request.user.email = email
                    results |= {'email': "Saved!"}
            else:
                results += {'email': "User with given email already exists!"}
        if 'password' in request.data:
            request.user.set_password(request.data['password'])
            results |= {'password': "Saved!"}
        if 'name' in request.data:
            request.user.first_name = request.data['name']
            results |= {'name': "Saved!"}
        if 'photo' in request.data:
            results |= {'photo': "TODO: implement!"}
            # TODO: update user photo
        request.user.save()
        return Response(results, status=200 if [1 if mess != 'Saved!' else 0 for mess in results.values()].count(0) > 0 else 400)

    @action(methods=['DELETE'], detail=False, permission_classes=[IsAuthenticated], renderer_classes=[PlainTextRenderer])
    def log_out(self, request):
        request.user.auth_token.delete()
        return Response("Logged out successfully")

    @action(methods=['DELETE'], detail=False, permission_classes=[IsAuthenticated], renderer_classes=[PlainTextRenderer])
    def leave(self, request):
        request.user.auth_token.delete()
        request.user.delete()
        return Response("User deleted successfully")


class ReportViewSet(CreateModelMixin, ReadOnlyModelViewSet):
    schema = ReportsSchema()
    serializer_class = ReportSerializer
    queryset = Report.objects.all()

    def get_throttles(self):
        if self.action == 'create':
            return [UserRateThrottle()]
        return super(ReportViewSet, self).get_throttles()

    def create(self, request, *args, **kwargs):
        # TODO: set photos
        request.data['photos'] = []
        try:
            return super().create(request, *args, **kwargs)
        except ValidationError as e:
            return Response(e.detail, status.HTTP_400_BAD_REQUEST)


class UserViewSet(RetrieveModelMixin, GenericViewSet):
    schema = AutoSchema(tags=['user'])
    serializer_class = UserSerializer
    queryset = User.objects.all()


class CommentViewSet(CreateModelMixin, GenericViewSet):
    schema = AutoSchema(tags=['comment'])
    throttle_classes = [UserRateThrottle]
    serializer_class = CommentSerializer
    queryset = Comment.objects.all()

    def create(self, request, *args, **kwargs):
        try:
            return super().create(request, *args, **kwargs)
        except ValidationError as e:
            return Response(e.detail, status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
@permission_classes([AllowAny])
@renderer_classes([PlainTextRenderer])
@schema(AutoSchema(tags='health', operation_id_base='Health'))
def healthcheck(request):
    return Response('healthy', content_type='text/plain')
