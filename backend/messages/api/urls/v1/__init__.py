from django.urls import path, include
from messages.api.views import TestViews
from messages.api.views.message import MessageSendView, MessageListView
from messages.api.views.conversation import ConversationViews, ConversationList

urlpatterns = [
    path('test/', TestViews.as_view()),
    path('auth/', include('messages.api.urls.v1.auth')),
    path('send/', MessageSendView.as_view(), name='send_message'),
    path('messages/<int:conversation_id>', MessageListView.as_view(), name='message_list_create'),
    path('create-conversation/', ConversationViews.as_view(), name='send_message'),
    path('conversations/', ConversationList.as_view(), name='get_conversations'),

]
