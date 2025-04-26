import 'package:get/get.dart';
import 'package:mobile/domain/usecases/auth/login.dart';

class AuthController extends GetxController{
  AuthController({required this.loginUseCase});
  final LoginUseCase loginUseCase;
  var isLoading = RxBool(false);
  String? username;

  Future<bool> login(String login, String password) async {
    isLoading.value = true;
    Get.log('caled');
    isLoading.value = false;
    bool value = await loginUseCase.call(login, password);
    if(value){
      username = login;
      return true;
    }
    return false;
  }

}