import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/data/models/conversations.dart';
import 'package:mobile/presentation/state_management/controllers/conversations_controller.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> suggestions = [];

  List<String> filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    filteredSuggestions = suggestions;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Get.find<ConversationsController>().getConversations();
    },);
  }

  void _filterSuggestions(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredSuggestions = suggestions;
      } else {
        filteredSuggestions = suggestions
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messenger'),
        actions: [
          IconButton.outlined(
            icon: Icon(Icons.person),
            onPressed: () {
              Get.toNamed('/profile/');
            },
          ),
        ],
        elevation: 1,
        bottomOpacity: 0.5,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(30.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setModalState) {
                        return Padding(
                          padding: EdgeInsets.only(
                            top: 30,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.arrow_back, color: Colors.grey),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: Colors.grey),
                                        ),
                                        child: TextField(
                                          onChanged: (value) {
                                            setModalState(() {
                                              _filterSuggestions(value);
                                            });
                                          },
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                                            contentPadding: EdgeInsets.only(bottom: 5),
                                            alignLabelWithHint: true
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 300,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: filteredSuggestions.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(filteredSuggestions[index]),
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(Icons.search, color: Colors.black),
                    ),
                    Text(
                      'Rechercher...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      ),
      body: Obx(() {
        final controller = Get.find<ConversationsController>();
        List<ConversationsModel> convs = controller.conversations;
        if(controller.isLoading.value){
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return ListView.builder(
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('${convs[index].participants}'),
            );
          },
          itemCount: convs.length,
        );
      },),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}