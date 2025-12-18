import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'account_screen.dart';
import 'setting_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatelessWidget {
  final int userId;

  const ProfileScreen({super.key, required this.userId});

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushNamedAndRemoveUntil(
      context,
      "/login",
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001A49),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00306E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          "PROFIL",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 80), // ganti jarak, tanpa image

            // =====================
            // AKUN
            // =====================
            buildMenuButton(
              "Akun",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AccountScreen(userId: userId),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // =====================
            // UBAH PASSWORD
            // =====================
            buildMenuButton(
              "Ubah Password",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangePasswordScreen(userId: userId),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // =====================
            // PENGATURAN
            // =====================
            buildMenuButton(
              "Pengaturan",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // =====================
            // LOGOUT
            // =====================
            buildMenuButton(
              "Keluar Akun",
              isLogout: true,
              onTap: () => logout(context),
            ),
          ],
        ),
      ),
    );
  }

  // =====================
  // BUTTON OVAL
  // =====================
  Widget buildMenuButton(
    String title, {
    bool isLogout = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isLogout ? Colors.redAccent : Colors.white,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isLogout ? Colors.redAccent : Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
