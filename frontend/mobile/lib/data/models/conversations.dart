import 'package:get/get.dart';
import 'package:mobile/data/models/participant.dart';

class ConversationsModel {
  ConversationsModel({required this.id, required this.lastUpdated, required this.participants, required this.lastMessage, required this.lastMessageTime, required this.lastMessageSender});
  final int id;
  final DateTime lastUpdated;
  final List<ParticipantModel> participants;
  String lastMessage = 'Aucun message';
  DateTime? lastMessageTime;
  String? lastMessageSender;
  factory ConversationsModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> participantsJson = json['participants_details'];
    Get.log(participantsJson.toString());
    return ConversationsModel(
      id: json['id'],
      lastUpdated: DateTime.parse(json['last_updated']),
      lastMessage: json['last_message'] ?? 'Aucun message',
      lastMessageTime: json['last_message_time'] != null ? DateTime.parse(json['last_message_time']) : null,
      lastMessageSender: json['last_message_sender'],
      participants: participantsJson.map((p) => ParticipantModel.fromJson(p)).toList(),
    );
  }
}