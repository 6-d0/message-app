import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:mobile/data/models/messages.dart';
import 'package:mobile/domain/usecases/get_messages.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatController extends GetxController {
  ChatController(this.messagesUseCase);
  final GetMessagesUseCase messagesUseCase;
  late WebSocketChannel _channel;
  final RxBool isLoading = false.obs;
  var messages = <MessagesModel>[].obs;
  var isConnected = false.obs;

  void initChat(int conversationId, String token) {
    fetchMessages(conversationId);
    connect(conversationId, token);
  }

  void connect(int conversationId, String token) {
    final url =
        '${dotenv.env['CHANNEL_URL']}chat/$conversationId/?token=$token';

    _channel = WebSocketChannel.connect(
      Uri.parse(url),
    );

    _channel.stream.listen((message) async {
      final data = jsonDecode(message);
      messages.add(MessagesModel(
        content: data['message'],
        sender: 'User ${data['sender']}',
        id: 0,
      ));
    }, onDone: () {
      isConnected.value = false;
    }, onError: (error) {
      Get.log("WebSocket error: $error");
    });

    isConnected.value = true;
  }

  void sendMessage(String message) {
    if (message.isNotEmpty) {
      _channel.sink.add(jsonEncode({'message': message}));

      messages.add(MessagesModel(
        content: message,
        sender: 'Moi',
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

  @override
  void onClose() {
    messages = <MessagesModel>[].obs;
    _channel.sink.close();
    super.onClose();
  }
}
