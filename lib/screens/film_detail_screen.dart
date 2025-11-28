import 'package:flutter/material.dart';
import '../services/server_api.dart';

class FilmDetailScreen extends StatefulWidget {
  final int filmId;

  const FilmDetailScreen({super.key, required this.filmId});

  @override
  State<FilmDetailScreen> createState() => _FilmDetailScreenState();
}

class _FilmDetailScreenState extends State<FilmDetailScreen> {
  final api = ServerAPI();
  Map? film;

  @override
  void initState() {
    super.initState();
    loadDetail();
  }

  Future loadDetail() async {
    final res = await api.getFilmById(widget.filmId);
    setState(() => film = res);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001A49),

      body: film == null
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SafeArea(
              child: Column(
                children: [
                  Image.network(film!["poster"] ??
                      "https://placehold.co/300x400"),
                  const SizedBox(height: 20),
                  Text(
                    film!["title"],
                    style: const TextStyle(color: Colors.white, fontSize: 26),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      film!["sinopsis"],
                      style: const TextStyle(color: Colors.white70),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
