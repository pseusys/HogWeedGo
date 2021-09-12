from django.contrib.auth.forms import UserChangeForm
from django.forms import fields, TextInput
from django.utils.html import format_html


class PasswordRecoveryWidget(TextInput):
    template_name = "django/forms/widgets/password_recovery_field.html"
    read_only = True


class PasswordRecoveryField(fields.Field):
    widget = PasswordRecoveryWidget

    def __init__(self, *args, **kwargs):
        kwargs.setdefault("required", False)
        kwargs.setdefault("disabled", True)
        super().__init__(*args, **kwargs)


class UserForm(UserChangeForm):
    class Meta:
        help_texts = {"email": 'You can <a href="mailto:{}">write an email</a> to the user.'}

    password_recovery = PasswordRecoveryField(
        label="Password",
        help_text="Raw passwords are not stored by server.",
        initial=format_html('You can change the password using <a href="../password/">this form</a>.')
    )

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._meta.help_texts["email"] = self._meta.help_texts["email"].format(self.instance.email)
