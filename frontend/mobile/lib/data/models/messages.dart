class MessagesModel {
  final int id;
  final String content;
  final String sender;
  const MessagesModel({required this.id, required this.content, required this.sender});

  factory MessagesModel.fromJson(Map<String, dynamic> json){
    return MessagesModel(
      id: json['id'], 
      content: json['content'], 
      sender: json['sender']
    );
  }
}