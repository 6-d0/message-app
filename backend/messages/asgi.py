import os
import django
from django.core.asgi import get_asgi_application
from channels.routing import ProtocolTypeRouter, URLRouter

# Définir le module de configuration de Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'messages.settings')

# Initialiser Django
django.setup()

# Maintenant que Django est configuré, importe ton middleware et autres composants
from messages.middlewares.auth_middleware import JWTAuthMiddleware
import messages.api.routing

application = ProtocolTypeRouter({
    "http": get_asgi_application(),
    "websocket": JWTAuthMiddleware(
        URLRouter(messages.api.routing.websocket_urlpatterns)
    ),
})
