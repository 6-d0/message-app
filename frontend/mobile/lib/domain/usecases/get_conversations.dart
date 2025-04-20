import 'package:mobile/data/models/conversations.dart';
import 'package:mobile/data/repository/conversation_repository.dart';

class GetConversationsUseCase {
  const GetConversationsUseCase({required this.conversationRepository});
  final ConversationRepository conversationRepository;

  Future<List<ConversationsModel>> call() async{
    return await conversationRepository.getConversations();
  }
}