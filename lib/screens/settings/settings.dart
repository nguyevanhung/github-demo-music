import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // Sau khi signOut, main.dart sẽ điều hướng về LoginPage qua StreamBuilder
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cài đặt")),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => logout(context),
          icon: const Icon(Icons.logout),
          label: const Text("Đăng xuất"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
    );
  }
}
