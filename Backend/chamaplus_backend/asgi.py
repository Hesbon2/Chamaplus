"""
ASGI config for chamaplus_backend project.

Defaults to production. Override with DJANGO_SETTINGS_MODULE or APP_ENV.
"""

from django.core.asgi import get_asgi_application

from chamaplus_backend.env_bootstrap import (
    PRODUCTION_SETTINGS,
    bootstrap_settings_module,
)

bootstrap_settings_module(default=PRODUCTION_SETTINGS)

application = get_asgi_application()
