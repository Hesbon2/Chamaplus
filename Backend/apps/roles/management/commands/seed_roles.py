from django.core.management.base import BaseCommand

from apps.roles.constants import DEFAULT_ROLES
from apps.roles.models import Role


class Command(BaseCommand):
    help = "Seed the default ChamaPlus role catalog."

    def handle(self, *args, **options):
        created_count = 0
        updated_count = 0

        for role_data in DEFAULT_ROLES:
            _, created = Role.objects.update_or_create(
                slug=role_data["slug"],
                defaults={
                    "name": role_data["name"],
                    "description": role_data["description"],
                    "is_platform_role": role_data["is_platform_role"],
                },
            )
            if created:
                created_count += 1
            else:
                updated_count += 1

        self.stdout.write(
            self.style.SUCCESS(
                f"Roles seeded: {created_count} created, {updated_count} updated."
            )
        )
