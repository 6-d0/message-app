import 'package:dio/dio.dart' as dioResp;
import 'package:get/get.dart';
import 'package:mobile/core/service/api_service.dart';
import 'package:mobile/data/models/messages.dart';

class MessagesRepository {
  Future<List<MessagesModel>> fetchMessages(int conversationId) async {
    Get.log('je passe la repo avant');
    dioResp.Response resp = await ApiService.instance.get('messages/$conversationId');
    Get.log('resp ok??');
    if (resp.statusCode == 200) {
      final List<dynamic> jsonList = resp.data;
      return jsonList.map((json) => MessagesModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch messages');
    }
  }
}