import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Setări'),
      ),
      body: Center(
        child: Text(
          'Aceasta este pagina Setărilor.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}