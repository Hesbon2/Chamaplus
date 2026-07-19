from pathlib import Path
import tempfile

import environ
from datetime import timedelta
from django.core.exceptions import ImproperlyConfigured

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent.parent

env = environ.Env(
    DEBUG=(bool, False),
    ALLOWED_HOSTS=(list, []),
    CORS_ALLOWED_ORIGINS=(list, []),
    JWT_ACCESS_TOKEN_LIFETIME_MINUTES=(int, 60),
    JWT_REFRESH_TOKEN_LIFETIME_DAYS=(int, 7),
)

# Read .env from backend root
environ.Env.read_env(BASE_DIR / ".env")

SECRET_KEY = env("SECRET_KEY")

DEBUG = env("DEBUG")

ALLOWED_HOSTS = env("ALLOWED_HOSTS")

# Application definition
DJANGO_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
]

THIRD_PARTY_APPS = [
    "rest_framework",
    "rest_framework_simplejwt",
    "rest_framework_simplejwt.token_blacklist",
    "drf_spectacular",
    "corsheaders",
]

LOCAL_APPS = [
    "apps.core",
    "apps.accounts",
    "apps.roles",
    "apps.chamas",
    "apps.memberships",
    "apps.contributions",
    "apps.loans",
    "apps.governance",
    "apps.credit_scoring",
    "apps.reports",
    "apps.notifications",
    "apps.audit",
]

INSTALLED_APPS = DJANGO_APPS + THIRD_PARTY_APPS + LOCAL_APPS

MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "corsheaders.middleware.CorsMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

ROOT_URLCONF = "chamaplus_backend.urls"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [BASE_DIR / "templates"],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.debug",
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]

WSGI_APPLICATION = "chamaplus_backend.wsgi.application"
ASGI_APPLICATION = "chamaplus_backend.asgi.application"

# Database — MySQL (local XAMPP or remote e.g. Aiven; values from environment)
_db_options = {
    "charset": "utf8mb4",
    "init_command": "SET sql_mode='STRICT_TRANS_TABLES'",
}
# Aiven and other managed MySQL require TLS (ssl-mode=REQUIRED).
# mysqlclient expects OPTIONS["ssl"] (dict). Provide a CA via:
# - DB_SSL_CA: local PEM path, OR paste PEM text (Render-friendly)
# - DB_SSL_CA_CONTENT: PEM text (alias for pasting into env)
_db_ssl_mode = (env("DB_SSL_MODE", default="") or "").strip().upper()
_db_ssl_ca = (env("DB_SSL_CA", default="") or "").strip()
_db_ssl_ca_content = (env("DB_SSL_CA_CONTENT", default="") or "").strip()


def _normalize_pem(value: str) -> str:
    return value.replace("\\n", "\n").strip()


def _write_ssl_ca_pem(pem: str) -> str:
    ca_dir = Path(tempfile.gettempdir()) / "chamaplus-db-ssl"
    ca_dir.mkdir(parents=True, exist_ok=True)
    ca_path = ca_dir / "ca.pem"
    ca_path.write_text(_normalize_pem(pem) + "\n", encoding="utf-8")
    return str(ca_path)


if _db_ssl_mode in {"REQUIRED", "VERIFY_CA", "VERIFY_IDENTITY", "TRUE", "1"}:
    _ssl = {}
    _pem = _db_ssl_ca_content or (
        _db_ssl_ca if "BEGIN CERTIFICATE" in _db_ssl_ca else ""
    )
    if _pem:
        _ssl["ca"] = _write_ssl_ca_pem(_pem)
    elif _db_ssl_ca:
        _ca_path = Path(_db_ssl_ca)
        if not _ca_path.is_absolute():
            _ca_path = BASE_DIR / _db_ssl_ca
        if not _ca_path.is_file():
            raise ImproperlyConfigured(
                f"DB_SSL_CA file not found: {_ca_path}. "
                "On Render, paste the Aiven ca.pem contents into DB_SSL_CA "
                "(or DB_SSL_CA_CONTENT) instead of a local path."
            )
        _ssl["ca"] = str(_ca_path)
    else:
        raise ImproperlyConfigured(
            "DB_SSL_MODE requires a CA: set DB_SSL_CA to a PEM path or paste "
            "the Aiven ca.pem into DB_SSL_CA / DB_SSL_CA_CONTENT."
        )
    _db_options["ssl"] = _ssl

DATABASES = {
    "default": {
        "ENGINE": env("DB_ENGINE", default="django.db.backends.mysql"),
        "NAME": env("DB_NAME", default="chamaplus_db"),
        "USER": env("DB_USER", default="root"),
        "PASSWORD": env("DB_PASSWORD", default=""),
        "HOST": env("DB_HOST", default="127.0.0.1"),
        "PORT": env("DB_PORT", default="3306"),
        "OPTIONS": _db_options,
    }
}

AUTH_USER_MODEL = "accounts.User"

AUTH_PASSWORD_VALIDATORS = [
    {
        "NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.MinimumLengthValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.CommonPasswordValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.NumericPasswordValidator",
    },
]

LANGUAGE_CODE = "en-us"
TIME_ZONE = "Africa/Nairobi"
USE_I18N = True
USE_TZ = True

# Static files
STATIC_URL = env("STATIC_URL", default="/static/")
STATIC_ROOT = BASE_DIR / "staticfiles"
STATICFILES_DIRS = [BASE_DIR / "static"]

# Media files
MEDIA_URL = env("MEDIA_URL", default="/media/")
MEDIA_ROOT = BASE_DIR / "media"

DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

# Django REST Framework
REST_FRAMEWORK = {
    "DEFAULT_AUTHENTICATION_CLASSES": (
        "rest_framework_simplejwt.authentication.JWTAuthentication",
    ),
    "DEFAULT_PERMISSION_CLASSES": (
        "rest_framework.permissions.IsAuthenticated",
    ),
    "DEFAULT_SCHEMA_CLASS": "drf_spectacular.openapi.AutoSchema",
    "DEFAULT_RENDERER_CLASSES": (
        "rest_framework.renderers.JSONRenderer",
    ),
    "DEFAULT_PARSER_CLASSES": (
        "rest_framework.parsers.JSONParser",
        "rest_framework.parsers.FormParser",
        "rest_framework.parsers.MultiPartParser",
    ),
    "EXCEPTION_HANDLER": "apps.core.exceptions.handlers.custom_exception_handler",
    "DATETIME_FORMAT": "%Y-%m-%dT%H:%M:%S%z",
}

# Simple JWT
SIMPLE_JWT = {
    "ACCESS_TOKEN_LIFETIME": timedelta(
        minutes=env("JWT_ACCESS_TOKEN_LIFETIME_MINUTES")
    ),
    "REFRESH_TOKEN_LIFETIME": timedelta(
        days=env("JWT_REFRESH_TOKEN_LIFETIME_DAYS")
    ),
    "ROTATE_REFRESH_TOKENS": True,
    "BLACKLIST_AFTER_ROTATION": True,
    "AUTH_HEADER_TYPES": ("Bearer",),
    "USER_ID_FIELD": "id",
    "USER_ID_CLAIM": "user_id",
}

# drf-spectacular (OpenAPI / Swagger)
SPECTACULAR_SETTINGS = {
    "TITLE": "ChamaPlus API",
    "DESCRIPTION": (
        "REST API for ChamaPlus — a mobile decision support system "
        "for informal savings groups in Kenya."
    ),
    "VERSION": "1.0.0",
    "SERVE_INCLUDE_SCHEMA": False,
    "COMPONENT_SPLIT_REQUEST": True,
    "SCHEMA_PATH_PREFIX": r"/api/v1",
}

# CORS — origins loaded from environment; see development/production overrides
CORS_ALLOWED_ORIGINS = env("CORS_ALLOWED_ORIGINS")

# Loan eligibility and committee voting
MIN_CONTRIBUTIONS_FOR_LOAN_ELIGIBILITY = env.int(
    "MIN_CONTRIBUTIONS_FOR_LOAN_ELIGIBILITY", default=1
)
LOAN_VOTE_APPROVAL_THRESHOLD = env.float("LOAN_VOTE_APPROVAL_THRESHOLD", default=0.51)

# Credit scoring weights (must sum to 1.0)
CREDIT_SCORE_WEIGHTS = {
    "contribution_consistency": env.float("CS_WEIGHT_CONSISTENCY", default=0.35),
    "repayment_history": env.float("CS_WEIGHT_REPAYMENT", default=0.35),
    "attendance": env.float("CS_WEIGHT_ATTENDANCE", default=0.15),
    "membership_duration": env.float("CS_WEIGHT_DURATION", default=0.15),
}

CREDIT_SCORE_RISK_THRESHOLDS = {
    "excellent": env.int("CS_RISK_EXCELLENT", default=80),
    "good": env.int("CS_RISK_GOOD", default=60),
    "fair": env.int("CS_RISK_FAIR", default=40),
}

# Logging
LOGGING = {
    "version": 1,
    "disable_existing_loggers": False,
    "formatters": {
        "verbose": {
            "format": "{levelname} {asctime} {module} {process:d} {thread:d} {message}",
            "style": "{",
        },
        "simple": {
            "format": "{levelname} {message}",
            "style": "{",
        },
    },
    "handlers": {
        "console": {
            "class": "logging.StreamHandler",
            "formatter": "verbose",
        },
        "file": {
            "class": "logging.FileHandler",
            "filename": BASE_DIR / "logs" / "chamaplus.log",
            "formatter": "verbose",
        },
    },
    "root": {
        "handlers": ["console"],
        "level": "INFO",
    },
    "loggers": {
        "django": {
            "handlers": ["console"],
            "level": "INFO",
            "propagate": False,
        },
        "django.request": {
            "handlers": ["console"],
            "level": "WARNING",
            "propagate": False,
        },
        "apps": {
            "handlers": ["console"],
            "level": "DEBUG",
            "propagate": False,
        },
    },
}
