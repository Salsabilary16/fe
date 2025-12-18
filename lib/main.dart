import 'package:flutter/material.dart';

// Import semua screen
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/film_detail_screen.dart';
import 'screens/choose_seats_screen.dart';
import 'screens/checkout_screen.dart';   // <-- WAJIB!

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // ================= STATIC ROUTES =================
      routes: {
        "/login": (_) => const LoginScreen(),
        "/register": (_) => const RegisterScreen(),
        "/choose-seats": (_) => const ChooseSeatsScreen(),
        "/checkout": (_) => CheckoutScreen(),   // <-- tambahkan ini
      },

      // ================= ROUTES WITH ARGUMENTS =================
      onGenerateRoute: (settings) {
        if (settings.name == "/film-detail") {
          final args = settings.arguments as Map;
          return MaterialPageRoute(
            builder: (_) => FilmDetailScreen(filmId: args["filmId"]),
          );
        }

        return null; // fallback
      },

      home: const SplashScreen(),
    );
  }
}
