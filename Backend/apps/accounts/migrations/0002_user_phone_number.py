import re

from django.db import migrations, models

KENYAN_PHONE_PATTERN = re.compile(r"^(?:\+?254|0)?([17]\d{8})$")


def normalize_phone(value):
    cleaned = re.sub(r"[\s\-()]", "", value.strip())
    match = KENYAN_PHONE_PATTERN.match(cleaned)
    if not match:
        return None
    return f"+254{match.group(1)}"


def populate_phone_numbers(apps, schema_editor):
    User = apps.get_model("accounts", "User")
    for index, user in enumerate(User.objects.all().order_by("date_joined"), start=1):
        phone = normalize_phone(user.username)
        if not phone:
            phone = f"+254700000{index:03d}"
        user.phone_number = phone
        if not user.username:
            user.username = phone
        user.save(update_fields=["phone_number", "username"])


class Migration(migrations.Migration):

    dependencies = [
        ("accounts", "0001_initial"),
    ]

    operations = [
        migrations.AddField(
            model_name="user",
            name="phone_number",
            field=models.CharField(max_length=15, null=True, unique=True),
        ),
        migrations.RunPython(populate_phone_numbers, migrations.RunPython.noop),
        migrations.AlterField(
            model_name="user",
            name="phone_number",
            field=models.CharField(max_length=15, unique=True),
        ),
    ]
