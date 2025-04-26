import 'dart:convert';
import 'dart:async';
import 'package:get/get.dart';
import 'package:mobile/data/models/messages.dart';
import 'package:mobile/domain/usecases/get_messages.dart';
import 'package:mobile/presentation/state_management/controllers/conversations_controller.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatController extends GetxController {
  ChatController(this.messagesUseCase);
  final GetMessagesUseCase messagesUseCase;

  late WebSocketChannel _chatChannel;
  late WebSocketChannel _globalChannel;
  final RxBool isLoading = false.obs;
  var messages = <MessagesModel>[].obs;
  var isChatConnected = false.obs;
  var isGlobalConnected = false.obs;
  Timer? _pingTimer;

  void initChat(int conversationId, String token) {
    if (!isChatConnected.value) {
      fetchMessages(conversationId);
      connectToChat(conversationId, token);
    }
  }

  void initGlobalChat(String token) {
    if (!isGlobalConnected.value) {
      connectToGlobalWebSocket(token);
    }
  }

  void connectToChat(int conversationId, String token) {
    final url = 'ws://10.0.2.2:8000/ws/chat/$conversationId/?token=$token';
    Get.log("Connecting to WebSocket for conversation: $url");

    try {
      _chatChannel = WebSocketChannel.connect(Uri.parse(url));

      _chatChannel.stream.listen((message) {
        Get.log("Message received for conversation: $message");

        final data = jsonDecode(message);
        messages.add(MessagesModel(
          content: data['message'],
          sender: data['sender'],
          conversationId: data['conversation_id'],
          id: null,
        ));
      }, onDone: () {
        isChatConnected.value = false;
        Get.log("WebSocket connection for conversation closed.");
      }, onError: (error) {
        isChatConnected.value = false;
        Get.log("WebSocket error for conversation: $error");
      });

      isChatConnected.value = true;
      Get.log("WebSocket connected for conversation.");
    } catch (e) {
      Get.log("WebSocket connection failed for conversation: $e");
    }
  }

  void connectToGlobalWebSocket(String token) {
    final url = 'ws://10.0.2.2:8000/ws/global/?token=$token';
    Get.log("Connecting to global WebSocket for notifications: $url");

    try {
      _globalChannel = WebSocketChannel.connect(Uri.parse(url));

      _globalChannel.stream.listen((message) {
        try {
          Get.log("Notification received on global WebSocket: $message");

          final data = jsonDecode(message);
          if (data.containsKey('conversation_id') && data.containsKey('message')) {
            final conversationId = data['conversation_id'];
            final newMessage = MessagesModel(
              content: data['message'],
              sender: data['sender'],
              id: data['id'],
              conversationId: conversationId,
            );
            updateConversationMessages(conversationId, newMessage);
          } else {
            Get.log("Invalid message format received on global WebSocket.");
          }
        } catch (e) {
          Get.log("Error processing message on global WebSocket: $e");
        }
      }, onDone: () {
        isGlobalConnected.value = false;
        Get.log("Global WebSocket connection closed.");
      }, onError: (error) {
        isGlobalConnected.value = false;
        Get.log("Global WebSocket error: $error");
      });

      isGlobalConnected.value = true;
      Get.log("Global WebSocket connected for notifications.");
    } catch (e) {
      Get.log("Global WebSocket connection failed: $e");
    }
  }

  void updateConversationMessages(int conversationId, MessagesModel newMessage) {
    final conversationsController = Get.find<ConversationsController>();
    final conversations = conversationsController.conversations;

    final conversationIndex = conversations.indexWhere((c) => c.id == conversationId);

    if (conversationIndex != -1) {
      final conversation = conversations[conversationIndex];
      conversation.lastMessage = newMessage.content;
      conversation.lastMessageTime = DateTime.now();

      conversationsController.putFirst(conversation);

      Get.log("Conversation $conversationId mise à jour et remontée en haut de la liste.");
    } else {
      Get.log("Conversation $conversationId introuvable.");
    }
  }

  void sendMessage(String message) {
    if (message.isNotEmpty && isChatConnected.value) {
      _chatChannel.sink.add(jsonEncode({'message': message}));
      Get.log("Message sent: $message");
    } else {
      Get.log("Cannot send message. WebSocket is not connected.");
    }
  }

  Future<List<MessagesModel>> fetchMessages(int convId, {bool load = true}) async {
    if (load) {
      isLoading.value = true;
    }
    try {
      Get.log('Fetching messages for conversation $convId');
      messages.assignAll(await messagesUseCase.call(convId));
      return messages;
    } catch (r) {
      Get.log(r.toString());
      return [];
    } finally {
      if (load) {
        isLoading.value = false;
      }
    }
  }

  @override
  void onClose() {
    _pingTimer?.cancel();

    if (isChatConnected.value) {
      _chatChannel.sink.close();
      Get.log("WebSocket connection for conversation closed.");
    }
    if (isGlobalConnected.value) {
      _globalChannel.sink.close();
      Get.log("Global WebSocket connection closed.");
    }

    super.onClose();
  }
}
