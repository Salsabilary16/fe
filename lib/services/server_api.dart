import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class ServerAPI {
  static const String baseUrl = "http://192.168.1.64:3000/api";

  // ================== CORE ==================
  Future<dynamic> get(String endpoint, {Map<String, dynamic>? params}) async {
    final uri =
        Uri.parse("$baseUrl$endpoint").replace(queryParameters: params);
    final response = await http.get(uri);

    return jsonDecode(response.body);
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    return jsonDecode(response.body);
  }

  // ================== AUTH ==================
  Future<dynamic> login(String email, String password) {
    return post("/auth/login", {
      "email": email,
      "password": password,
    });
  }

  Future<dynamic> register(String name, String email, String password) {
    return post("/auth/register", {
      "name": name,
      "email": email,
      "password": password,
    });
  }

  // ================== FILM ==================
  Future<dynamic> getAllFilms() => get("/film");

  Future<dynamic> getFilmById(int id) => get("/film/$id");

  Future<dynamic> searchFilm(String query) =>
      get("/film", params: {"query": query});

  // ================== SCHEDULE ==================
  Future<dynamic> getScheduleByFilm(int filmId) =>
      get("/schedule/film/$filmId");

  Future<dynamic> getScheduleDetail(int id) =>
      get("/schedule/$id");

  Future<dynamic> getScheduleByDetail({
    required int filmId,
    required String date,
    required String time,
  }) {
    return get("/schedule/by-detail", params: {
      "film_id": filmId.toString(),
      "date": date,
      "time": time,
    });
  }

  Future<int?> getPriceByFilm(int filmId) async {
    final res = await get("/schedule/film/$filmId");

    if (res != null && res["success"] == true && res["schedules"].length > 0) {
      return res["schedules"][0]["price"];
    }
    return null;
  }

  // ================== SEATS ==================
  Future<dynamic> getSeats(int scheduleId) {
    return get("/seats/$scheduleId");
  }

  // ================== BOOKING ==================
  Future<dynamic> createBooking(
      int userId, int scheduleId, List<String> seats) {
    return post("/bookings", {
      "user_id": userId,
      "schedule_id": scheduleId,
      "seats": seats,
    });
  }

  Future<dynamic> cancelBooking(int bookingId, int userId) {
    return post("/bookings/cancel", {
      "booking_id": bookingId,
      "user_id": userId,
    });
  }

  Future<dynamic> getUserBookings(int userId) =>
      get("/bookings/user/$userId");

  Future<dynamic> getBookingDetail(int bookingId) =>
      get("/bookings/$bookingId");

  // ================== 🧾 BUKTI PEMBELIAN ==================
  Future<dynamic> getPurchaseProof(int bookingId) {
    return get("/bookings/proof/$bookingId");
  }

  // ================== 🏠 HOME ==================
  Future<dynamic> getHomeData(int userId) =>
      get("/home", params: {"userId": userId.toString()});

  // =====================================================
  // ================== 💳 TRIPAY ==================
  // =====================================================

  /// Ambil semua channel pembayaran Tripay (QRIS, BCA, BRI, dll)
  Future<dynamic> getTripayChannels() {
    return get("/payment/tripay/channels");
  }

  /// Buat transaksi Tripay
  Future<dynamic> createTripayTransaction({
    required int bookingId,
    required int amount,
    required String method,
    required String customerName,
    required String customerEmail,
  }) {
    return post("/payment/tripay/create", {
      "booking_id": bookingId,
      "amount": amount,
      "method": method,
      "customer_name": customerName,
      "customer_email": customerEmail,
    });
  }

  /// Cek status pembayaran Tripay
  Future<dynamic> checkTripayStatus(String reference) {
    return get("/payment/tripay/status",
        params: {"reference": reference});
  }

  // ================== UPLOAD POSTER ==================
  Future<dynamic> uploadPoster(String filePath) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/film/upload'),
    );

    request.files
        .add(await http.MultipartFile.fromPath('poster', filePath));

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    return jsonDecode(responseBody);
  }

  Future uploadPosterWeb(Uint8List bytes, String filename) async {
    final url = Uri.parse("$baseUrl/film/upload");

    final request = http.MultipartRequest('POST', url)
      ..files.add(
        http.MultipartFile.fromBytes('poster', bytes, filename: filename),
      );

    final res = await request.send();
    final resBody = await res.stream.bytesToString();
    return json.decode(resBody);
  }
}
