from django.core.management import BaseCommand
from HogWeedGo.models import User


class Command(BaseCommand):
    help = "Creates superuser if no superuser exists"

    def add_arguments(self, parser):
        parser.add_argument("--email", "-e", help="Email of new superuser")
        parser.add_argument("--password", "-p", help="Password of new superuser")

    def handle(self, *args, **options):
        if User.objects.count() == 0:
            email = options["mode"]
            password = options["mode"]
            print(f"Created superuser with email: {email}, password: {password}")
            admin = User.objects.create_superuser(email=email, password=password)
            admin.is_superuser = True
            admin.is_active = True
            admin.is_admin = True
            admin.save()
        else:
            print("Superuser account can only be initialized if no other accounts exist")
