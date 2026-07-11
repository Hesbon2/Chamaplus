"""
ASGI config for chamaplus_backend project.
"""

import os

from django.core.asgi import get_asgi_application

os.environ.setdefault(
    "DJANGO_SETTINGS_MODULE",
    "chamaplus_backend.settings.production",
)

application = get_asgi_application()
