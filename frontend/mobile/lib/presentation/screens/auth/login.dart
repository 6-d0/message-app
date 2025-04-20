import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/presentation/state_management/controllers/auth_controller.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _usernameController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Nom d'utilisateur",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final username = _usernameController.text;
                final password = _passwordController.text;

                if (username.isNotEmpty && password.isNotEmpty) {
                  bool success = await Get.find<AuthController>().login(username, password);
                  if(success){
                    Get.offAndToNamed('/');
                  }else{
                    Get.snackbar('Auth failed', 'Failed to log in');
                  }
                } else {
                  Get.snackbar('Erreur', 'Veuillez remplir toutes les informations');
                }
              },
              child: Text('Se connecter'),
            ),
          ],
        ),
      ),
    );
  }
}