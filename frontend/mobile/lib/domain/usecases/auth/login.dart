import 'package:get/get.dart';
import 'package:mobile/data/repository/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase({required this.authRepository});
  final AuthRepository authRepository;
  Future<bool> call (String login, String password) async{
    bool success = true;
    await authRepository.authenticate(login: login, password: password).onError((error, stackTrace) {
      success = false;
      Get.log(error.toString());
      return {'error': error.toString()};
    },);
    return success;
  }
}