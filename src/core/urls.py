from django.urls import path
from . import api

app_name = "core"

urlpatterns = [
    path("about/", api.about),
]
