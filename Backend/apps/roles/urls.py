from django.urls import path

from apps.roles.views import RoleListView

app_name = "roles"

urlpatterns = [
    path("", RoleListView.as_view(), name="role-list"),
]
