import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/presentation/state_management/controllers/chat_controller.dart';

class ChatScreen extends StatelessWidget {
  final int conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Conversation')),
      body: FutureBuilder(
        future: Get.find<ChatController>().fetchMessages(conversationId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur de chargement des messages'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucun message dans cette conversation.'));
          }

          final messages = snapshot.data!;

          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(messages[index].content),
                subtitle: Text(messages[index].sender),
              );
            },
          );
        },
      ),
    );
  }
}