class MessagesModel {
  final int? id;
  final String content;
  final String sender;
  final int conversationId;
  const MessagesModel({required this.id, required this.content, required this.sender, required this.conversationId});

  factory MessagesModel.fromJson(Map<String, dynamic> json){
    return MessagesModel(
      id: json['id'], 
      content: json['content'], 
      sender: json['sender'],
      conversationId: json['conversation'] ?? 0,
    );
  }

  @override 
  String toString() => content;
}