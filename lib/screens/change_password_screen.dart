import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChangePasswordScreen extends StatefulWidget {
  final int userId;
  const ChangePasswordScreen({super.key, required this.userId});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController oldPassController = TextEditingController();
  final TextEditingController newPassController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  bool isLoading = false;

  // Jika kamu menjalankan backend di emulator Android gunakan 10.0.2.2
  // Untuk perangkat fisik ganti dengan IP komputer lokal: e.g. 192.168.1.10
  // Sesuaikan baseHost jika perlu.
  final List<String> _candidateHosts = [
    "http://10.0.2.2:3000", // Android emulator
    "http://10.0.3.2:3000", // Genymotion
    "http://localhost:3000", // Flutter on desktop or web (may fail on Android)
    "http://192.168.100.85:3000", // contoh IP LAN (ganti sesuai)
  ];

  Future<void> updatePassword() async {
    final oldPass = oldPassController.text.trim();
    final newPass = newPassController.text.trim();
    final confirmPass = confirmPassController.text.trim();

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      _showSnack("Semua field wajib diisi", isError: true);
      return;
    }
    if (newPass.length < 6) {
      _showSnack("Password baru minimal 6 karakter", isError: true);
      return;
    }
    if (newPass != confirmPass) {
      _showSnack("Konfirmasi password tidak cocok", isError: true);
      return;
    }

    setState(() => isLoading = true);

    // body sesuai contract backend — sesuaikan keys jika backend beda
    final body = json.encode({
      "user_id": widget.userId,
      "old_password": oldPass,
      "new_password": newPass,
    });

    // coba beberapa host candidate agar lebih robust
    String? lastError;
    for (final host in _candidateHosts) {
      final url = Uri.parse("$host/change-password");
      try {
        final response = await http
            .post(url, headers: {"Content-Type": "application/json"}, body: body)
            .timeout(const Duration(seconds: 8));

        // sukses
        if (response.statusCode == 200) {
          // jika backend mengirim { success: true, message: "..."}
          try {
            final data = json.decode(response.body);
            if (data is Map && (data["success"] == true || response.statusCode == 200)) {
              _showSnack(data["message"] ?? "Password berhasil diubah", isError: false);
              Navigator.pop(context);
              setState(() => isLoading = false);
              return;
            } else {
              // backend balikan error-format
              lastError = "Server menolak: ${data["message"] ?? response.body}";
              // keluar loop? coba host lain dulu
            }
          } catch (_) {
            // body bukan JSON, anggap sukses jika 200
            _showSnack("Password berhasil diubah", isError: false);
            Navigator.pop(context);
            setState(() => isLoading = false);
            return;
          }
        } else {
          // catat pesan error server
          String msg = "HTTP ${response.statusCode}";
          try {
            final data = json.decode(response.body);
            msg += " - ${data['message'] ?? response.body}";
          } catch (_) {
            msg += " - ${response.body}";
          }
          lastError = msg;
          // coba host berikutnya
        }
      } on TimeoutException {
        lastError = "Timeout saat menghubungi $host";
      } on SocketException {
        lastError = "Tidak dapat terhubung ke $host (SocketException)";
      } catch (e) {
        lastError = "Error saat request ke $host: $e";
      }
    }

    // jika sampai sini semua candidate gagal
    _showSnack("Terjadi kesalahan koneksi ke server:\n${lastError ?? 'unknown'}", isError: true);
    setState(() => isLoading = false);
  }

  void _showSnack(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  void dispose() {
    oldPassController.dispose();
    newPassController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001A49),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00306E),
        elevation: 0,
        title: const Text("Ubah Password", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: oldPassController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Password Lama",
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPassController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Password Baru",
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPassController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Konfirmasi Password Baru",
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 260,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : updatePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: isLoading ? const CircularProgressIndicator() : const Text("Simpan"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
