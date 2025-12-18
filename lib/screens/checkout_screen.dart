import '../widgets/payment_method_sheet.dart';
import 'package:flutter/material.dart';
import '../services/server_api.dart';

class CheckoutScreen extends StatelessWidget {
  final api = ServerAPI();

  CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map? ?? {};

    final String title = args["film_title"] ?? args["title"] ?? "Unknown";
    final String genre = args["film_genre"] ?? args["genre"] ?? "-";

    final String time = args["time"] ?? "";
    final List seats = args["seats"] ?? [];
    final int price = args["price"] ?? 0;
    final int total = args["total"] ?? 0;
    final int userId = args["userId"] ?? 0;
    final int scheduleId = args["scheduleId"] ?? 0;

    int biayaLayanan = 4000;
    int totalBayar = total + biayaLayanan;

    return Scaffold(
      backgroundColor: const Color(0xFF001A49),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Ringkasan Pemesanan",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              "Genre: $genre",
              style: const TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 25),

            infoRow("${seats.length} Tiket", seats.join(", ")),
            infoRow("Jam", time.substring(0, 5)),
            infoRow(
              "Harga",
              "Rp.$price x ${seats.length}",
            ),
            infoRow("Biaya Layanan", "Rp.$biayaLayanan"),

            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF00225F),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  infoRow(
                    "Total Bayar",
                    "Rp.$totalBayar",
                    bold: true,
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        // =====================
                        // 1. CREATE BOOKING
                        // =====================
                        final bookingRes = await api.createBooking(
                          userId,
                          scheduleId,
                          seats.cast<String>(),
                        );

                        if (bookingRes["success"] != true) {
                          print(bookingRes);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Booking gagal")),
                          );
                          return;
                        }

                        final bookingId = bookingRes["booking_id"];

                        // =====================
                        // 2. PILIH METODE BAYAR
                        // =====================
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: const Color(0xFF001A49),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (_) => PaymentMethodSheet(
                            bookingId: bookingId,
                            amount: totalBayar,
                            api: api,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFAD29),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "BAYAR SEKARANG",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget infoRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
