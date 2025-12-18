import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

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
          "PENGATURAN",
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
            const SizedBox(height: 80),

            // ===========================
            // BAHASA BUTTON
            // ===========================
            _buildSettingButton(
              icon: Icons.language,
              title: "Bahasa : Indonesia",
            ),

            const SizedBox(height: 25),

            // ===========================
            // MODE BUTTON
            // ===========================
            _buildSettingButton(
              title: "Mode : Gelap",
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================
  // WIDGET BUTTON OVAL SESUAI DESAIN
  // ===============================================
  Widget _buildSettingButton({
    IconData? icon,
    required String title,
  }) {
    return Container(
      width: 300,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 10),
          ],
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
