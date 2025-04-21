import 'dart:convert';
import 'package:get/get.dart';
import 'package:mobile/data/models/messages.dart';
import 'package:mobile/domain/usecases/get_messages.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatController extends GetxController {
  ChatController(this.messagesUseCase);
  final GetMessagesUseCase messagesUseCase;
  late WebSocketChannel _channel;
  var messages = <MessagesModel>[].obs;
  var isConnected = false.obs;

  void connect(int conversationId, String token) {
    final url = 'ws://10.0.2.2:8000/ws/chat/$conversationId/?token=$token';
    
    _channel = WebSocketChannel.connect(
      Uri.parse(url),
    );

    _channel.stream.listen((message) {
      final data = jsonDecode(message);
      messages.add(data['message']);
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
    }
  }

  Future<List<MessagesModel>> fetchMessages(int convId) async{
    try{
    Get.log('je passe dans uc');
      messages.assignAll(await messagesUseCase.call(convId));
      return messages;
    }catch(r){
      Get.log(r.toString());
      return [];
    }
  }

  @override
  void onClose() {
    _channel.sink.close();
    super.onClose();
  }
}
