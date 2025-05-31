from django.conf import settings
from django.conf.urls import include, url
from django.conf.urls.static import static
from django_prometheus import exports

urlpatterns = [
    url(r'^metrics/', exports.ExportToDjangoView, name='prometheus-django-metrics'),  # Первым, чтобы избежать перехвата
    url(r'^sa/', include("shuup.admin.urls", namespace="shuup_admin")),
    url(r'^', include("shuup.front.urls", namespace="shuup")),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)