import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TicketScreen extends StatefulWidget {
  final int userId;

  const TicketScreen({super.key, required this.userId});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  late Future<List<dynamic>> ticketFuture;

  @override
  void initState() {
    super.initState();
    ticketFuture = fetchTickets();
  }

  Future<List<dynamic>> fetchTickets() async {
    final url = Uri.parse(
      "http://192.168.1.64:3000/api/bookings/user/${widget.userId}",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);

      // 🔥 SESUAI RESPONSE BACKEND
      if (result is Map && result["bookings"] is List) {
        return result["bookings"];
      }

      return [];
    } else {
      throw Exception("Gagal mengambil data tiket");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001A49),
      appBar: AppBar(
        backgroundColor: const Color(0xFF001A49),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Daftar Tiket",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: ticketFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final tickets = snapshot.data ?? [];

          if (tickets.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada tiket",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final t = tickets[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A1D45),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      t["film_title"] ?? "-",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              info("Tanggal", formatDate(t["date"])),
                              const SizedBox(height: 8),
                              info("Booking ID", "${t["booking_id"]}"),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              info("Jam", t["time"] ?? "-"),
                              const SizedBox(height: 8),
                              info("Total", "Rp ${t["total_price"]}"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget info(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }

  String formatDate(String? date) {
    if (date == null) return "-";
    final d = DateTime.parse(date);
    return "${d.day}-${d.month}-${d.year}";
  }
}
