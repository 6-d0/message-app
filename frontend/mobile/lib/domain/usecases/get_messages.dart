import 'package:get/get.dart';
import 'package:mobile/data/models/messages.dart';
import 'package:mobile/data/repository/messages_repository.dart';

class GetMessagesUseCase {
  const GetMessagesUseCase(this.repository);
  final MessagesRepository repository;
  Future<List<MessagesModel>> call(int id) async{
    Get.log('je asse vrmt dans uc');
    return await repository.fetchMessages(id);
  }
}