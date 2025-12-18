import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  int? filmPrice;

  int selectedDate = -1;
  int selectedTime = -1;

  int userId = -1;
  bool userLoaded = false;

  // ================== TANGGAL SESUAI BACKEND ==================
  final List<Map<String, String>> dateList = [
    {"day": "01", "month": "Jan", "week": "Senin", "full": "2025-01-01"},
    {"day": "02", "month": "Jan", "week": "Selasa", "full": "2025-01-02"},
    {"day": "03", "month": "Jan", "week": "Rabu", "full": "2025-01-03"},
    {"day": "04", "month": "Jan", "week": "Kamis", "full": "2025-01-04"},
    {"day": "05", "month": "Jan", "week": "Jumat", "full": "2025-01-05"},
    {"day": "06", "month": "Jan", "week": "Sabtu", "full": "2025-01-06"},
    {"day": "07", "month": "Jan", "week": "Minggu", "full": "2025-01-07"},
  ];

  // ================== JAM SESUAI BACKEND ==================
  final List<String> timeList = [
    "09:00:00",
    "10:30:00",
    "12:00:00",
    "14:00:00",
    "16:00:00",
    "18:00:00",
    "20:00:00",
  ];

  @override
  void initState() {
    super.initState();
    loadUserId();
    loadFilmDetail();
    loadFilmPrice();
  }

  // =================== LOAD USER ===================
  Future loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt("userId") ?? -1;

    setState(() {
      userLoaded = true;
    });

    // debug
    // print("=== USER LOGIN ID Loaded: $userId ===");
  }

  // =================== LOAD FILM ===================
  Future loadFilmDetail() async {
    try {
      final res = await api.getFilmById(widget.filmId);
      setState(() => film = res);
    } catch (e) {
      // optional: tampilkan error atau fallback
      // print("Error getFilmById: $e");
    }
  }

  // =================== LOAD PRICE ===================
  Future loadFilmPrice() async {
    try {
      final price = await api.getPriceByFilm(widget.filmId);
      setState(() => filmPrice = price);
    } catch (e) {
      // print("Error getPriceByFilm: $e");
    }
  }

  // =================== NAVIGATE ===================
  void goToChooseSeats() {
    if (selectedDate == -1 || selectedTime == -1) return;

    if (userId == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan login terlebih dahulu")),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      "/choose-seats",
      arguments: {
        "filmId": widget.filmId,
        "date": dateList[selectedDate]["full"],
        "time": timeList[selectedTime],
        "price": filmPrice,
        "userId": userId,

        // pastikan data film dikirim ke screen selanjutnya
        "title": film?["title"],
        "genre": film?["genre"],
        "poster": film?["poster"],
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001A49),
      extendBodyBehindAppBar: true,
      body: film == null
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top),

                // ================= POSTER =================
                Stack(
                  children: [
                    SizedBox(
                      height: 260,
                      width: double.infinity,
                      child: Image.network(
                        film!["poster"] ?? "",
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.black12,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ================= INFO =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          film!["poster"] ?? "",
                          width: 80,
                          height: 110,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 80,
                            height: 110,
                            color: Colors.black12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              film!["title"] ?? "Tidak diketahui",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Genre: ${film!["genre"] ?? '-'}",
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 16),
                            ),
                            const SizedBox(height: 10),

                            // ================= PRICE =================
                            Text(
                              filmPrice == null
                                  ? "Harga: -"
                                  : "Harga: Rp ${filmPrice}",
                              style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ================= TAB =================
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        const TabBar(
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white54,
                          indicatorColor: Colors.amber,
                          tabs: [
                            Tab(text: "SINOPSIS"),
                            Tab(text: "JADWAL"),
                          ],
                        ),

                        Expanded(
                          child: TabBarView(
                            children: [
                              // ================= SINOPSIS =================
                              SingleChildScrollView(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  film!["sinopsis"] ?? "",
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 15),
                                ),
                              ),

                              // ================= JADWAL =================
                              Column(
                                children: [
                                  Expanded(
                                    child: SingleChildScrollView(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Pilih Tanggal",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 10),

                                          SizedBox(
                                            height: 70,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: dateList.length,
                                              itemBuilder: (context, i) {
                                                return _dateItem(
                                                  dateList[i]["day"]!,
                                                  dateList[i]["month"]!,
                                                  dateList[i]["week"]!,
                                                  i,
                                                );
                                              },
                                            ),
                                          ),

                                          const SizedBox(height: 20),

                                          const Text(
                                            "Pilih Jam",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 10),

                                          SizedBox(
                                            height: 50,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: timeList.length,
                                              itemBuilder: (context, i) {
                                                return _timeItem(
                                                    timeList[i], i);
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // ================= BUTTON PILIH KURSI =================
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: GestureDetector(
                                      onTap:
                                          (selectedDate != -1 && selectedTime != -1)
                                              ? goToChooseSeats
                                              : null,
                                      child: Container(
                                        width: double.infinity,
                                        height: 55,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: (selectedDate != -1 &&
                                                  selectedTime != -1)
                                              ? Colors.amber
                                              : Colors.grey,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          "Pilih Kursi",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }

  // ================== DATE ITEM ==================
  Widget _dateItem(String day, String month, String week, int index) {
    final active = index == selectedDate;

    return GestureDetector(
      onTap: () => setState(() => selectedDate = index),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(10),
        width: 70,
        decoration: BoxDecoration(
          color: active ? Colors.amber : Colors.white10,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? Colors.amber : Colors.white30),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(day,
                style: TextStyle(
                    color: active ? Colors.black : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text(month,
                style: TextStyle(
                    color: active ? Colors.black87 : Colors.white70)),
            Text(week,
                style: TextStyle(
                    color: active ? Colors.black87 : Colors.white54)),
          ],
        ),
      ),
    );
  }

  // ================== TIME ITEM ==================
  Widget _timeItem(String time, int index) {
    final active = index == selectedTime;

    return GestureDetector(
      onTap: () => setState(() => selectedTime = index),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: active ? Colors.amber : Colors.white10,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? Colors.amber : Colors.white30),
        ),
        child: Text(
          time.substring(0, 5),
          style: TextStyle(
            color: active ? Colors.black : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
