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
      conversations.assignAll(resp);
    } catch (e) {
      errors.value = e.toString();
      Get.log(e.toString());
    }
    isLoading.value = false;
  }
}