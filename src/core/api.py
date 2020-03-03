from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from project.settings import __version__
from project.settings.common import env


@api_view(http_method_names=["GET"])
@permission_classes([])
def about(request):
    return Response(
        {"version": __version__, "commit": env.str("GIT_COMMIT", default="unknown")}
    )
