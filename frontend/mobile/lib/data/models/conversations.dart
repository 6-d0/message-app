import 'dart:convert';

import 'package:get/get.dart';
import 'package:mobile/data/models/participant.dart';

class ConversationsModel {
  const ConversationsModel({required this.id, required this.lastUpdated, required this.participants});
  final int id;
  final DateTime lastUpdated;
  final List<ParticipantModel> participants;
  factory ConversationsModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> participantsJson = json['participants_details']; // Pas besoin de jsonDecode
    Get.log(participantsJson.toString());
    return ConversationsModel(
      id: json['id'],
      lastUpdated: DateTime.parse(json['last_updated']),
      participants: participantsJson.map((p) => ParticipantModel.fromJson(p)).toList(),
    );
  }
}