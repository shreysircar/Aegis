/*import 'dart:convert';
import 'package:http/http.dart' as http;
import '../features/auth/models/user_model.dart';
class AuthService {
  final String baseUrl = 'http://10.0.2.2:3000/api/auth'; // Android emulator fix

  Future<String> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    print('Login response: ${res.statusCode}, body: ${res.body}');

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['token'];
    } else {
      throw Exception(jsonDecode(res.body)['error'] ?? 'Login failed');
    }
  }
 Future<void> signup(String fullname, String email, String password) async {
  final res = await http.post(
    Uri.parse('$baseUrl/signup'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'fullname': fullname,
      'email': email,
      'password': password,
    }),
  );

  print('Signup response: ${res.statusCode}, body: ${res.body}');

  if (res.statusCode != 200 && res.statusCode != 201) {
    throw Exception(jsonDecode(res.body)['error'] ?? 'Signup failed');
  }
  // ✅ success
}

  Future<UserModel> getMe(String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print('Me response: ${res.statusCode}, body: ${res.body}');

    if (res.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Failed to fetch user');
    }
  }

  Future<void> signout(String token) async {
    final res = await http.post(
      Uri.parse('$baseUrl/signout'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print('Signout response: ${res.statusCode}, body: ${res.body}');

    if (res.statusCode != 200) {
      throw Exception('Signout failed');
    }
  }
}
*/
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../features/auth/models/user_model.dart';

class AuthService {
  final String baseUrl = 'http://10.0.2.2:3000/api/auth'; // Android emulator fix

  Future<String> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    print('Login response: ${res.statusCode}, body: ${res.body}');

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['token'];
    } else {
      throw Exception(_extractError(res));
    }
  }

  Future<void> signup(String fullname, String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullname': fullname,
        'email': email,
        'password': password,
      }),
    );

    print('Signup response: ${res.statusCode}, body: ${res.body}');

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception(_extractError(res));
    }
    // ✅ success
  }

  Future<UserModel> getMe(String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print('Me response: ${res.statusCode}, body: ${res.body}');

    if (res.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(res.body));
    } else {
      throw Exception(_extractError(res, fallback: 'Failed to fetch user'));
    }
  }

  Future<void> signout(String token) async {
    final res = await http.post(
      Uri.parse('$baseUrl/signout'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print('Signout response: ${res.statusCode}, body: ${res.body}');

    if (res.statusCode != 200) {
      throw Exception(_extractError(res, fallback: 'Signout failed'));
    }
  }

  /// 🔹 Extract readable error messages from API
  String _extractError(http.Response res, {String fallback = 'Request failed'}) {
    try {
      final body = jsonDecode(res.body);
      if (body is Map && (body['error'] != null || body['message'] != null)) {
        return body['error'] ?? body['message'];
      }
      return body.toString();
    } catch (_) {
      return res.body.isNotEmpty ? res.body : fallback;
    }
  }
}
