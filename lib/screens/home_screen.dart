import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/server_api.dart';
import 'add_film_screen.dart';
import 'film_detail_screen.dart';
import 'profile_screen.dart';
import 'ticket_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final api = ServerAPI();
  List films = [];
  List filteredFilms = [];
  TextEditingController searchC = TextEditingController();

  bool loading = true;
  int userId = -1;
  String userName = "";
  String role = "";

  int _selectedIndex = 0; // NAVIGATION INDEX

  @override
  void initState() {
    super.initState();
    loadUserData();
    loadFilms();
  }

  // ===================== LOAD USER DATA =====================
  Future loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      userId = prefs.getInt("userId") ?? -1;
      userName = prefs.getString("userName") ?? "User";
      role = widget.user["role"];
    });
  }

  // ===================== LOAD FILM LIST =====================
  Future loadFilms() async {
    final res = await api.getAllFilms();

    setState(() {
      films = res["films"];
      filteredFilms = films;
      loading = false;
    });
  }

  // ===================== SEARCH FILM =====================
  void searchFilm(String query) async {
    if (query.isEmpty) {
      setState(() => filteredFilms = films);
      return;
    }

    final res = await api.searchFilm(query);
    setState(() => filteredFilms = res["films"]);
  }

  // ===================== ON NAVIGATION TAP =====================
  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TicketScreen(userId: userId)),
      );
    }

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProfileScreen(userId: userId)),
      );
    }
  }

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001A49),

      // ==================== FLOATING BUTTON ADMIN ====================
      floatingActionButton: role == "admin"
          ? FloatingActionButton(
              backgroundColor: Colors.orange,
              child: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddFilmScreen()),
                ).then((_) => loadFilms());
              },
            )
          : null,

      // ==================== BOTTOM NAVIGATION BAR (WARNA SESUAI BACKGROUND) ====================
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF001A49), // sama seperti background
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.white54,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Beranda",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            label: "Tiket",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profil",
          ),
        ],
      ),

      // ==================== BODY ====================
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              Text(
                "Halo, $userName",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Text(
                "Pesan film favorit kamu",
                style: TextStyle(color: Colors.white70),
              ),

              const SizedBox(height: 20),

              // SEARCH BOX
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: searchC,
                  onChanged: searchFilm,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    icon: Icon(Icons.search, color: Colors.white70),
                    hintText: "cari film",
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "Sedang Tayang",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),

              const SizedBox(height: 10),

              // FILM GRID
              Expanded(
                child: loading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : GridView.builder(
                        padding: EdgeInsets.zero,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                        ),
                        itemCount: filteredFilms.length,
                        itemBuilder: (context, index) {
                          final film = filteredFilms[index];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      FilmDetailScreen(filmId: film["id"]),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(
                                    film["poster"] ??
                                        "https://placehold.co/300x400",
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  film["title"],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
