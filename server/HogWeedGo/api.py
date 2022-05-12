from django.db import IntegrityError
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes, action, schema, renderer_classes
from rest_framework.exceptions import ValidationError
from rest_framework.mixins import RetrieveModelMixin, CreateModelMixin, ListModelMixin
from rest_framework.parsers import MultiPartParser
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.renderers import JSONRenderer
from rest_framework.response import Response
from rest_framework.schemas.openapi import AutoSchema
from rest_framework.throttling import UserRateThrottle
from rest_framework.viewsets import ViewSet, GenericViewSet

from HogWeedGo.api_support import PlainTextRenderer, verify_params, random_token, auth, send_email, MultiPartJSONParser
from HogWeedGo.models import User, Report, Comment
from HogWeedGo.serializers import UserSerializer, ReportSerializer, CommentSerializer, ReportPhotoSerializer


# TODO: make async with Django async support.


class MeViewSet(ViewSet):
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

    @action(methods=['GET'], detail=False, permission_classes=[IsAuthenticated])
    def profile(self, request):
        return Response(UserSerializer(request.user).data)

    @action(methods=['POST'], detail=False, permission_classes=[IsAuthenticated], throttle_classes=[UserRateThrottle], parser_classes=[MultiPartParser])
    def setup(self, request):
        results = {}
        if 'email' in request.query_params and 'code' in request.query_params:
            email = request.query_params.get('email')
            token = random_token(email=email)
            existing = User.objects.filter(email=email).first()
            if not existing:
                if token != request.query_params.get("code"):
                    results |= {'email': "Wrong or expired code!"}
                else:
                    request.user.email = email
                    results |= {'email': "Saved!"}
            else:
                results |= {'email': "User with given email already exists!"}
        if 'password' in request.query_params:
            request.user.set_password(request.query_params.get('password'))
            results |= {'password': "Saved!"}
        if 'name' in request.query_params:
            request.user.first_name = request.query_params.get('name')
            results |= {'name': "Saved!"}
        if 'photo' in request.FILES:
            request.user.photo = request.FILES['photo']
            results |= {'photo': "Saved!"}
        request.user.save()
        return Response(results, status=status.HTTP_200_OK if [1 if mess != 'Saved!' else 0 for mess in results.values()].count(1) == 0 else status.HTTP_400_BAD_REQUEST)

    @action(methods=['DELETE'], detail=False, permission_classes=[IsAuthenticated], renderer_classes=[PlainTextRenderer])
    def log_out(self, request):
        request.user.auth_token.delete()
        return Response("Logged out successfully")

    @action(methods=['DELETE'], detail=False, permission_classes=[IsAuthenticated], renderer_classes=[PlainTextRenderer])
    def leave(self, request):
        request.user.auth_token.delete()
        request.user.delete()
        return Response("User deleted successfully")


class ReportViewSet(CreateModelMixin, ListModelMixin, GenericViewSet):
    serializer_class = ReportSerializer
    parser_classes = [MultiPartJSONParser]

    def get_throttles(self):
        if self.action == 'create':
            return [UserRateThrottle()]
        return super(ReportViewSet, self).get_throttles()

    def get_queryset(self):
        if 'filter' in self.request.query_params:
            return Report.objects.filter(status=self.request.query_params['filter'])
        else:
            return Report.objects.all()

    def create(self, request, *args, **kwargs):
        try:
            pk = super().create(request, *args, **kwargs).data['id']
            for photo in request.FILES.getlist('photos'):
                serializer = ReportPhotoSerializer(data={'photo': photo, 'report': pk})
                serializer.is_valid(raise_exception=True)
                serializer.save()
            serializer = self.get_serializer(instance=Report.objects.get(pk=pk))
            headers = self.get_success_headers(serializer.data)
            return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)
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
