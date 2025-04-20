
import 'package:dio/dio.dart';
import 'package:mobile/core/service/api_service.dart';
import 'package:mobile/data/models/conversations.dart';

class ConversationRepository {
  const ConversationRepository();
  Future<List<ConversationsModel>> getConversations() async{
    ApiService apiService = ApiService.instance;
    Response resp = await apiService.get('conversations/', queryParameters: {});
    List<ConversationsModel> conversations = [];
    for(Map<String, dynamic> sub in resp.data){
      conversations.add(ConversationsModel.fromJson(sub));
    }
    return conversations;
  }
}