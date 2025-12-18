import 'package:flutter/material.dart';
import '../services/server_api.dart';

class ChooseSeatsScreen extends StatefulWidget {
  const ChooseSeatsScreen({Key? key}) : super(key: key);

  @override
  State<ChooseSeatsScreen> createState() => _ChooseSeatsScreenState();
}

class _ChooseSeatsScreenState extends State<ChooseSeatsScreen> {
  final api = ServerAPI();

  int? scheduleId;
  int userId = -1;

  List seats = [];
  List<String> selectedSeats = [];
  bool loading = true;
  String? error;

  // Data film (nullable & aman)
  String filmPoster = "";
  String filmTitle = "Unknown";
  String filmGenre = "-";

  int filmId = 0;
  String selectedDate = "";
  String selectedTime = "";

  int seatPrice = 35000;
  int totalPrice = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(loadData);
  }

  Future<void> loadData() async {
    try {
      final args = (ModalRoute.of(context)?.settings.arguments ?? {}) as Map;

      // Ambil data film secara aman
      filmId = args["filmId"] ?? 0;
      selectedDate = args["date"] ?? "";
      selectedTime = args["time"] ?? "";
      userId = args["userId"] ?? -1;

      filmPoster = args["poster"] ?? "";
      filmTitle = args["title"] ?? "Unknown";
      filmGenre = args["genre"] ?? "-";

      seatPrice = args["price"] ?? 35000;

      if (filmId == 0 || selectedDate.isEmpty || selectedTime.isEmpty) {
        setState(() {
          error = "Data film atau jadwal tidak lengkap.";
          loading = false;
        });
        return;
      }

      // Ambil schedule
      final scheduleRes = await api.getScheduleByDetail(
        filmId: filmId,
        date: selectedDate,
        time: selectedTime,
      );

      if (scheduleRes == null || scheduleRes["success"] != true) {
        setState(() {
          error = scheduleRes?["message"] ?? "Schedule tidak ditemukan";
          loading = false;
        });
        return;
      }

      scheduleId = scheduleRes["schedule"]["id"];

      // Ambil kursi
      final seatsRes = await api.getSeats(scheduleId!);

      if (seatsRes == null || seatsRes["success"] != true) {
        setState(() {
          error = seatsRes?["error"] ?? "Gagal mengambil kursi";
          loading = false;
        });
        return;
      }

      seats = seatsRes["seats"];

      setState(() => loading = false);
    } catch (e) {
      setState(() {
        error = "Error: $e";
        loading = false;
      });
    }
  }

  void toggleSeat(String seatNumber) {
    setState(() {
      if (selectedSeats.contains(seatNumber)) {
        selectedSeats.remove(seatNumber);
      } else {
        selectedSeats.add(seatNumber);
      }

      totalPrice = selectedSeats.length * seatPrice;
    });
  }

  void goToCheckout() {
    Navigator.pushNamed(
      context,
      "/checkout",
      arguments: {
        "filmId": filmId,
        "poster": filmPoster,
        "title": filmTitle,
        "genre": filmGenre,
        "date": selectedDate,
        "time": selectedTime,
        "price": seatPrice,
        "total": totalPrice,
        "seats": selectedSeats,
        "scheduleId": scheduleId,
        "userId": userId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001A49),
      appBar: AppBar(
        title: const Text(
          "Pilih Kursi",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : error != null
              ? Center(
                  child: Text(
                    error ?? "Error",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: seats.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                        ),
                        itemBuilder: (context, index) {
                          final seat = seats[index];
                          final seatNumber = seat["seat_number"];
                          final booked = seat["is_booked"] == 1;
                          final selected = selectedSeats.contains(seatNumber);

                          return GestureDetector(
                            onTap: booked ? null : () => toggleSeat(seatNumber),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: booked
                                    ? Colors.red
                                    : selected
                                        ? Colors.amber
                                        : Colors.white10,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: booked
                                      ? Colors.red
                                      : selected
                                          ? Colors.amber
                                          : Colors.white30,
                                ),
                              ),
                              child: Text(
                                seatNumber,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Panel Harga
                    Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.white24),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Total Harga: Rp $totalPrice",
                            style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: selectedSeats.isEmpty
                                  ? null
                                  : goToCheckout,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedSeats.isEmpty
                                    ? Colors.grey
                                    : Colors.amber,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Konfirmasi Pembayaran",
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
    );
  }
}
