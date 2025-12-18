import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AccountScreen extends StatefulWidget {
  final int userId;

  const AccountScreen({super.key, required this.userId});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late Future<Map<String, dynamic>> userFuture;

  @override
  void initState() {
    super.initState();
    userFuture = fetchUser();
  }

  Future<Map<String, dynamic>> fetchUser() async {
    final url = Uri.parse(
      "http://192.168.1.64:3000/api/auth/users/${widget.userId}",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Gagal mengambil data akun");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001A49),
      appBar: AppBar(
        backgroundColor: const Color(0xFF11224D),
        foregroundColor: Colors.white,
        title: const Text(
          "AKUN",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }

          final user = snapshot.data!;

          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              infoBox("Nama : ${user["name"]}"),
              const SizedBox(height: 20),
              infoBox("Email : ${user["email"]}"),
              const SizedBox(height: 20),
              infoBox("Role : ${user["role"]}"),
            ],
          );
        },
      ),
    );
  }

  Widget infoBox(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.symmetric(vertical: 18),
      alignment: Alignment.center, // ⬅️ CENTER ISI
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white70,
          width: 1.5,
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center, // ⬅️ CENTER TEKS
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
