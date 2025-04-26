import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/core/service/api_service.dart';
import 'package:mobile/data/models/conversations.dart';
import 'package:mobile/presentation/state_management/controllers/chat_controller.dart';

class ChatScreen extends StatefulWidget {

  ChatScreen({
    super.key,
  });
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
          title:
              ListTile(subtitle: Text('${widget.conversation.participants}'))),
      body: Obx(() {
        final messages = controller.messages;

        if (controller.isLoading.value) {
          return CircularProgressIndicator();
        }

        if (messages.isEmpty) {
          return Center(child: Text('Aucun message dans cette conversation.'));
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(messages[messages.length - 1 - index].content),
                    subtitle:
                        Text(messages[messages.length - 1 - index].sender),
                  );
                },
              ),
            ),
            TextFormField(
              controller: txtcontroller,
              decoration: InputDecoration(
                  suffix: IconButton.filled(
                      onPressed: () {
                        controller.sendMessage(txtcontroller.value.text);
                        txtcontroller.text = '';
                      },
                      icon: Icon(Icons.send))),
            )
          ],
        );
      }),
    );
  }
}
