from django.urls import path, include
from messages.api.views import TestViews
from messages.api.views.message import MessageListCreateView
from messages.api.views.conversation import ConversationViews

urlpatterns = [
    path('test/', TestViews.as_view()),
    path('auth/', include('messages.api.urls.v1.auth')),
    path('send/', MessageListCreateView.as_view(), name='send_message'),
    path('create-conversation/', ConversationViews.as_view(), name='send_message'),

]
