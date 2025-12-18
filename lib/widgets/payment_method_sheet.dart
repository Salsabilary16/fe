import 'package:flutter/material.dart';
import '../services/server_api.dart';

class PaymentMethodSheet extends StatelessWidget {
  final int bookingId;
  final int amount;
  final ServerAPI api;

  const PaymentMethodSheet({
    super.key,
    required this.bookingId,
    required this.amount,
    required this.api,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: api.getTripayChannels(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final channels = snapshot.data["data"];

        return Container(
          color: const Color(0xFF001A49),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                "Pilih Metode Pembayaran",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              ...channels.map<Widget>((c) {
                return ListTile(
                  title: Text(
                    c["name"],
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.white70,
                  ),
                  onTap: () async {
                    await api.createTripayTransaction(
                      bookingId: bookingId,
                      amount: amount,
                      method: c["code"],
                      customerName: "User",
                      customerEmail: "user@email.com",
                    );

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Silakan bayar via ${c["name"]}"),
                      ),
                    );
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}
