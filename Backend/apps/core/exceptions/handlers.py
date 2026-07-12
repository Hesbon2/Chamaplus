from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import exception_handler

from apps.core.exceptions.base import DomainError


def custom_exception_handler(exc, context):
    """Wrap DRF and domain exceptions in the standard API envelope."""
    if isinstance(exc, DomainError):
        return Response(
            {
                "success": False,
                "message": exc.message,
                "data": exc.data,
            },
            status=status.HTTP_400_BAD_REQUEST,
        )

    response = exception_handler(exc, context)
    if response is None:
        return response

    message = "Request failed"
    data = response.data

    if isinstance(data, dict):
        if "detail" in data:
            detail = data["detail"]
            message = str(detail)
            data = None
        else:
            message = "Validation failed"
    elif isinstance(data, list):
        message = str(data[0]) if data else message

    return Response(
        {
            "success": False,
            "message": message,
            "data": data,
        },
        status=response.status_code,
    )
