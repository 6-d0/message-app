from django.urls import path, include 
urlpatterns = [
    path('v1/', include('messages.api.urls.v1')),
]
