import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
class ServerAPI {
  static const String baseUrl = "http://localhost:3000/api";

  Future<dynamic> get(String endpoint) async {
    final response = await http.get(Uri.parse("$baseUrl$endpoint"));
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

  Future<dynamic> getAllFilms() {
    return get("/film");
  }

  Future<dynamic> getFilmById(int id) {
    return get("/film/$id");
  }

  Future<dynamic> searchFilm(String query) {
    return get("/film?query=$query");
  }

  Future<dynamic> getScheduleByFilm(int filmId) {
    return get("/schedule/film/$filmId");
  }

  Future<dynamic> getScheduleDetail(int id) {
    return get("/schedule/$id");
  }

  Future<dynamic> getSeats(int scheduleId) {
    return get("/seats/$scheduleId");
  }

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

  Future<dynamic> getUserBookings(int userId) {
    return get("/bookings/user/$userId");
  }

  Future<dynamic> getBookingDetail(int bookingId) {
    return get("/bookings/$bookingId");
  }

  Future<dynamic> getHomeData(int userId) {
    return get("/home?userId=$userId");
  }

  Future<dynamic> uploadPoster(String filePath) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('$baseUrl/film/upload'),
  );

  request.files.add(await http.MultipartFile.fromPath('poster', filePath));

  var response = await request.send();
  var responseBody = await response.stream.bytesToString();
  
  return jsonDecode(responseBody);
}

Future uploadPosterWeb(Uint8List bytes, String filename) async {
  final url = Uri.parse("$baseUrl/api/film/upload");

  final request = http.MultipartRequest('POST', url)
    ..files.add(http.MultipartFile.fromBytes('poster', bytes, filename: filename));

  final response = await request.send();
  final resBody = await response.stream.bytesToString();
  return json.decode(resBody);
}


}
