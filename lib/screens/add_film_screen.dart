import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io' show File;
import 'package:image_picker/image_picker.dart';
import '../services/server_api.dart';

class AddFilmScreen extends StatefulWidget {
  const AddFilmScreen({super.key});

  @override
  State<AddFilmScreen> createState() => _AddFilmScreenState();
}

class _AddFilmScreenState extends State<AddFilmScreen> {
  final titleC = TextEditingController();
  final descC = TextEditingController();
  final genreC = TextEditingController();

  final api = ServerAPI();

  XFile? pickedImage;
  bool loading = false;

  Future pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        pickedImage = picked;
      });
    }
  }

  Future submitFilm() async {
    if (titleC.text.isEmpty || descC.text.isEmpty || genreC.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Semua field wajib diisi")));
      return;
    }

    if (pickedImage == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Poster belum dipilih")));
      return;
    }

    setState(() => loading = true);

    late Map uploadRes;

    // 🌐 WEB UPLOAD → pakai bytes
    if (kIsWeb) {
      final bytes = await pickedImage!.readAsBytes();
      uploadRes = await api.uploadPosterWeb(bytes, pickedImage!.name);
    }
    // 📱 ANDROID UPLOAD → pakai file path
    else {
      uploadRes = await api.uploadPoster(pickedImage!.path);
    }

    if (uploadRes["status"] != "ok") {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Upload poster gagal")));
      setState(() => loading = false);
      return;
    }

    final posterUrl = uploadRes["url"];

    final res = await api.post("/film", {
      "title": titleC.text,
      "sinopsis": descC.text,
      "genre": genreC.text,
      "poster": posterUrl,
    });

    setState(() => loading = false);

    if (res["message"] == "Film berhasil ditambahkan") {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res["message"] ?? "Error")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001A49),
      appBar: AppBar(
        title: const Text("Tambah Film"),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white70),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: pickedImage == null
                    ? const Center(
                        child: Text("Pilih Poster Film",
                            style: TextStyle(color: Colors.white70)),
                      )

                    // 🌐 WEB PREVIEW
                    : kIsWeb
                        ? Image.network(
                            pickedImage!.path,
                            fit: BoxFit.cover,
                          )

                        // 📱 ANDROID PREVIEW
                        : Image.file(
                            File(pickedImage!.path),
                            fit: BoxFit.cover,
                          ),
              ),
            ),
            const SizedBox(height: 20),

            _inputField(titleC, "Judul"),
            const SizedBox(height: 12),
            _inputField(descC, "Deskripsi"),
            const SizedBox(height: 12),
            _inputField(genreC, "Genre"),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading ? null : submitFilm,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Simpan Film"),
            )
          ],
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController c, String text) {
    return TextField(
      controller: c,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: text,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.orange),
        ),
      ),
    );
  }
}
