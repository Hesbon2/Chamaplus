from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView


def success_response(data=None, message="Success", status_code=status.HTTP_200_OK):
    return Response(
        {"success": True, "message": message, "data": data},
        status=status_code,
    )


def error_response(message="Error", data=None, status_code=status.HTTP_400_BAD_REQUEST):
    return Response(
        {"success": False, "message": message, "data": data},
        status=status_code,
    )


class EnvelopeMixin:
    """Mixin for class-based views returning the standard API envelope."""

    def success(self, data=None, message="Success", status_code=status.HTTP_200_OK):
        return success_response(data=data, message=message, status_code=status_code)

    def error(self, message="Error", data=None, status_code=status.HTTP_400_BAD_REQUEST):
        return error_response(message=message, data=data, status_code=status_code)


class EnvelopeAPIView(EnvelopeMixin, APIView):
    """Base API view with envelope response helpers."""

    pass
