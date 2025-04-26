import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/core/service/api_service.dart';
import 'package:mobile/presentation/state_management/controllers/conversations_controller.dart';
import 'package:mobile/presentation/state_management/controllers/chat_controller.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final conversationsController = Get.find<ConversationsController>();
      final chatController = Get.find<ChatController>();
      await conversationsController.getConversations();

      chatController.initGlobalChat(ApiService.instance.token);
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversationsController = Get.find<ConversationsController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Messenger'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Get.toNamed('/profile/');
            },
          ),
        ],
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Rechercher une conversation...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              final conversations = conversationsController.conversations;

              if (conversationsController.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (conversations.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 50, color: Colors.grey),
                      SizedBox(height: 10),
                      Text(
                        'Aucune conversation disponible.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              
              final filteredConversations = conversations.where((conversation) {
                final participants = conversation.participants.join(", ").toLowerCase();
                final lastMessage = conversation.lastMessage.toLowerCase();
                return participants.contains(_searchQuery) || lastMessage.contains(_searchQuery);
              }).toList();

              return RefreshIndicator(
                onRefresh: () async {
                  return await conversationsController.getConversations();
                },
                child: ListView.builder(
                  itemCount: filteredConversations.length,
                  itemBuilder: (context, index) {
                    final conversation = filteredConversations[index];

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Text(
                          conversation.participants[0].toString().toUpperCase()[0],
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        conversation.participants.join(", "),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        conversation.lastMessage,
                        style: TextStyle(color: Colors.grey),
                      ),
                      onTap: () {
                        Get.toNamed('/chat/', arguments: conversation);
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Get.toNamed('/settings/');
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
      ),
    );
  }
}
