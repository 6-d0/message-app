import 'package:get/get.dart';
import 'package:mobile/data/models/conversations.dart';
import 'package:mobile/domain/usecases/get_conversations.dart';

class ConversationsController extends GetxController {
  ConversationsController({required this.conversationsUseCase});
  final GetConversationsUseCase conversationsUseCase; 
  RxBool isLoading = false.obs;
  RxString errors = ''.obs;
  final RxList<ConversationsModel> conversations = <ConversationsModel>[].obs;

  Future<void> getConversations() async {
    errors.value = '';
    isLoading.value = true;
    try {
      final List<ConversationsModel> resp = await conversationsUseCase.call();
      resp.sort((a, b) => b.lastMessageTime != null && a.lastMessageTime != null? b.lastMessageTime!.compareTo(a.lastMessageTime!) : 0);
      conversations.assignAll(resp);
    } catch (e) {
      errors.value = e.toString();
      Get.log(e.toString());
    }
    isLoading.value = false;
  }

  void putFirst(ConversationsModel conversation) {
    Get.log('putFirst: ${conversation.id}');
    final index = conversations.indexWhere((c) => c.id == conversation.id);
    if (index != -1) {
      Get.log('Conversation trouvée, mise à jour...');
      final existingConversation = conversations.removeAt(index);
      conversations.insert(0, existingConversation);
    } else {
      Get.log('Nouvelle conversation, ajoutée en haut...');
      conversations.insert(0, conversation);
    }
    conversations.refresh();
  }
}