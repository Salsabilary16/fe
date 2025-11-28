import 'package:flutter/material.dart';
import '../services/server_api.dart';
import 'home_screen.dart';   // <--- TAMBAH INI

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final api = ServerAPI();

  bool loading = false;

  Future doLogin() async {
    if (emailC.text.isEmpty || passC.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email dan password harus diisi")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final res = await api.login(
        emailC.text.trim(),
        passC.text.trim(),
      );

      setState(() => loading = false);

      if (res == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Server tidak merespons")),
        );
        return;
      }

      if (res["message"] == "Login sukses") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(user: res["user"]),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res["message"] ?? "Login gagal")),
        );
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
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
                "MASUK",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w400),
              ),

              const SizedBox(height: 60),

              _inputField(emailC, "Email"),
              const SizedBox(height: 20),
              _inputField(passC, "Password", obscure: true),

              const SizedBox(height: 40),

              GestureDetector(
                onTap: loading ? null : doLogin,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.redAccent, width: 2),
                  ),
                  child: Center(
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "MASUK",
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
                onTap: () =>
                    Navigator.pushReplacementNamed(context, "/register"),
                child: const Text(
                  "Belum Punya Akun? Buat Akun",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),

              const SizedBox(height: 10),
              const Text(
                "Masuk Sebagai Admin",
                style: TextStyle(color: Colors.white60, fontSize: 14),
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
