import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Parolă',
                border: OutlineInputBorder(),
              ),
              obscureText: true, // Ascunde textul cu steluțe
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Logica pentru autentificare
                String email = emailController.text;
                String password = passwordController.text;
                print('Email: $email, Parolă: $password');
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}