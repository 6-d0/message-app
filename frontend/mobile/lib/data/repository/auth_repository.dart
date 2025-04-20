import 'package:dio/dio.dart';
import 'package:mobile/core/service/api_service.dart';

class AuthRepository {
  const AuthRepository();
  Future<Map<String, dynamic>> authenticate({required String login, required String password}) async {
    ApiService apiService = ApiService.instance;
    Response resp =  await apiService.post(
      'auth/login/', 
      data: {
        "username":login,
        "password":password,
      }
    );
    final String? jwt = resp.data['access'];
    final String? refresh = resp.data['refresh'];
    if(jwt != null && refresh != null){
      apiService.setTokens(jwt, refresh);
    }else{
      throw Exception(resp.data['detail']);
    }
    return resp.data;
  }
}