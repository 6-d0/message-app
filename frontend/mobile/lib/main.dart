import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:mobile/core/service/api_service.dart';
import 'package:mobile/data/repository/auth_repository.dart';
import 'package:mobile/data/repository/conversation_repository.dart';
import 'package:mobile/domain/usecases/auth/login.dart';
import 'package:mobile/domain/usecases/get_conversations.dart';
import 'package:mobile/presentation/screens/home.dart';
import 'package:mobile/presentation/screens/auth/login.dart';
import 'package:mobile/presentation/state_management/controllers/auth_controller.dart';
import 'package:mobile/presentation/state_management/controllers/conversations_controller.dart';

void main() async {
  await dotenv.load();
  ApiService.baseurl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000/api/v1/';
  Get.put<AuthController>(permanent: true, AuthController(loginUseCase: LoginUseCase(authRepository: AuthRepository())));
  Get.put<ConversationsController>(permanent: true, ConversationsController(conversationsUseCase: GetConversationsUseCase(conversationRepository: ConversationRepository())));
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    String initial = ApiService.instance.hasToken? '/':'/auth/login/';
    return GetMaterialApp(
      getPages: [
        GetPage(name: '/', page: Home.new),
        GetPage(name: '/auth/login/', page: LoginPage.new)
      ],
      initialRoute: initial,
    );
  }
}
