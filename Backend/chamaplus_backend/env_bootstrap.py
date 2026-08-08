"""Resolve DJANGO_SETTINGS_MODULE from process env, .env, or APP_ENV."""

from __future__ import annotations

import os
from pathlib import Path

DEVELOPMENT_SETTINGS = "chamaplus_backend.settings.development"
PRODUCTION_SETTINGS = "chamaplus_backend.settings.production"


def bootstrap_settings_module(*, default: str) -> str:
    """
    Ensure DJANGO_SETTINGS_MODULE is set.

    Priority:
    1. Already set in the process environment
    2. DJANGO_SETTINGS_MODULE in Backend/.env
    3. APP_ENV in Backend/.env (development|production)
    4. [default] (manage.py → development, wsgi/asgi → production)
    """
    existing = os.environ.get("DJANGO_SETTINGS_MODULE")
    if existing:
        return existing

    app_env = None
    from_file = None
    env_path = Path(__file__).resolve().parent.parent / ".env"

    if env_path.exists():
        for raw in env_path.read_text(encoding="utf-8").splitlines():
            line = raw.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, _, value = line.partition("=")
            key = key.strip()
            value = value.strip().strip("'").strip('"')
            if key == "DJANGO_SETTINGS_MODULE" and value:
                from_file = value
            elif key == "APP_ENV" and value:
                app_env = value.strip().lower()

    if from_file:
        os.environ["DJANGO_SETTINGS_MODULE"] = from_file
        return from_file

    if app_env in {"production", "prod"}:
        chosen = PRODUCTION_SETTINGS
    elif app_env in {"development", "dev"}:
        chosen = DEVELOPMENT_SETTINGS
    else:
        chosen = default

    os.environ["DJANGO_SETTINGS_MODULE"] = chosen
    return chosen
