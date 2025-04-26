import 'dart:convert';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:mobile/data/models/messages.dart';
import 'package:mobile/domain/usecases/get_messages.dart';
import 'package:mobile/presentation/state_management/controllers/auth_controller.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatController extends GetxController {
  ChatController(this.messagesUseCase);
  final GetMessagesUseCase messagesUseCase;
  late WebSocketChannel _channel;
  final RxBool isLoading = false.obs;
  var messages = <MessagesModel>[].obs;
  var isConnected = false.obs;
  Timer? _pingTimer;

  void initChat(int conversationId, String token) {
    fetchMessages(conversationId);
    connect(conversationId, token);
  }

  void connect(int conversationId, String token) {
    final url = 'ws://10.0.2.2:8000/ws/chat/$conversationId/?token=$token';
    Get.log("Connecting to WebSocket: $url");

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));

      _channel.stream.listen((message) {
        Get.log("Message received: $message");

        // Décoder le message reçu
        final data = jsonDecode(message);
        if (data['type'] == 'message') {
          // Ajouter le message à la liste
          messages.add(MessagesModel(
            content: data['message'],
            sender: data['sender'],
            id: data['id'],
          ));
        }
      }, onDone: () {
        isConnected.value = false;
        Get.log("WebSocket connection closed.");
      }, onError: (error) {
        isConnected.value = false;
        Get.log("WebSocket error: $error");
      });

      isConnected.value = true;
      Get.log("WebSocket connected.");
      startPing(); // Démarrer les pings pour maintenir la connexion
    } catch (e) {
      Get.log("WebSocket connection failed: $e");
    }
  }

  void sendMessage(String message) {
    if (message.isNotEmpty) {
      _channel.sink.add(jsonEncode({'message': message}));

      messages.add(MessagesModel(
        content: message,
        sender: '${Get.find<AuthController>().username}',
        id: 0,
      ));
    }
  }

  Future<List<MessagesModel>> fetchMessages(int convId,
      {bool load = true}) async {
    if (load) {
      isLoading.value = true;
    }
    try {
      Get.log('je passe dans uc');
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

  void startPing() {
    _pingTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (isConnected.value) {
        _channel.sink.add(jsonEncode({'type': 'ping'}));
        Get.log("Ping sent to keep the connection alive.");
      }
    });
  }

  @override
  void onClose() {
    _pingTimer?.cancel();
    if (isConnected.value) {
      _channel.sink.close();
      Get.log("WebSocket connection closed.");
    }
    super.onClose();
  }
}
