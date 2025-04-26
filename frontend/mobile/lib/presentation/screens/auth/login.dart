import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/presentation/state_management/controllers/auth_controller.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.lightBlue],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      
                      Text(
                        'Bienvenue',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      TextField(
                        controller: _usernameController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "Nom d'utilisateur",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(Icons.person),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: Icon(Icons.lock),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                      ),
                      SizedBox(height: 24),
                      
                      ElevatedButton(
                        onPressed: () async {
                          final username = _usernameController.text;
                          final password = _passwordController.text;

                          if (username.isNotEmpty && password.isNotEmpty) {
                            bool success = await Get.find<AuthController>().login(username, password);
                            if (success) {
                              Get.offAndToNamed('/');
                            } else {
                              Get.snackbar('Échec de connexion', 'Nom d\'utilisateur ou mot de passe incorrect');
                            }
                          } else {
                            Get.snackbar('Erreur', 'Veuillez remplir toutes les informations');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.blueAccent,
                        ),
                        child: Text(
                          'Se connecter',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      TextButton(
                        onPressed: () {
                          Get.toNamed('/register');
                        },
                        child: Text(
                          'Créer un compte',
                          style: TextStyle(color: Colors.blueAccent),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}