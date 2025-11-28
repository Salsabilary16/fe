import 'package:flutter/material.dart';
import '../services/server_api.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final passC = TextEditingController();

  final api = ServerAPI();
  bool loading = false;

  Future doRegister() async {
    setState(() => loading = true);

    final res = await api.register(
      nameC.text.trim(),
      emailC.text.trim(),
      passC.text.trim(),
    );

    setState(() => loading = false);

    if (res["message"] == "Registrasi berhasil") {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Akun berhasil dibuat")));

      Navigator.pushReplacementNamed(context, "/login");
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res["message"] ?? "Error")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001A49),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 80),
          child: Column(
            children: [
              const SizedBox(height: 40),

              const Text(
                "DAFTAR",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w400),
              ),

              const SizedBox(height: 60),

              _inputField(nameC, "Nama Lengkap"),
              const SizedBox(height: 20),
              _inputField(emailC, "Email"),
              const SizedBox(height: 20),
              _inputField(passC, "Password", obscure: true),

              const SizedBox(height: 40),

              GestureDetector(
                onTap: loading ? null : doRegister,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.greenAccent, width: 2),
                  ),
                  child: Center(
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "DAFTAR",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                letterSpacing: 1.2),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              GestureDetector(
                onTap: () => Navigator.pushReplacementNamed(context, "/login"),
                child: const Text(
                  "Sudah punya akun? Masuk",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),

              const SizedBox(height: 70),

              Image.asset("assets/mountain.png"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController c, String hint,
      {bool obscure = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2A57),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: Colors.white, width: 1.4),
      ),
      child: TextField(
        controller: c,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
