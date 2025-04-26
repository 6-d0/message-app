import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/core/service/api_service.dart';
import 'package:mobile/data/models/conversations.dart';
import 'package:mobile/presentation/state_management/controllers/auth_controller.dart';
import 'package:mobile/presentation/state_management/controllers/chat_controller.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({super.key});
  final ConversationsModel conversation = Get.arguments;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ChatController>();
    controller.initChat(widget.conversation.id, ApiService.instance.token);
  }

  @override
  void dispose() {
    controller.onClose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txtcontroller = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.conversation.participants.join(", "),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        final messages = controller.messages;

        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (!controller.isChatConnected.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Connexion perdue. Tentative de reconnexion...',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    controller.connectToChat(widget.conversation.id, ApiService.instance.token);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[messages.length - 1 - index];
                  final isMe = message.sender == Get.find<AuthController>().username;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blueAccent : Colors.grey[300],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                            bottomLeft: isMe ? Radius.circular(16) : Radius.zero,
                            bottomRight: isMe ? Radius.zero : Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isMe)
                              Text(
                                message.sender,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            Text(
                              message.content,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              color: Colors.grey[100],
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: txtcontroller,
                      decoration: InputDecoration(
                        hintText: 'Écrivez un message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      if (txtcontroller.text.trim().isNotEmpty) {
                        controller.sendMessage(txtcontroller.text.trim());
                        txtcontroller.clear();
                      }
                    },
                    child: CircleAvatar(
                      backgroundColor: txtcontroller.text.trim().isEmpty
                          ? Colors.grey
                          : Colors.blueAccent,
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
