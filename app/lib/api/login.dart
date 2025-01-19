import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/api/apiurl.dart';

class LoginResponse {
  final bool success;
  final String messageOrToken;

  LoginResponse(this.success, this.messageOrToken);
}

Future<LoginResponse> login(String username, String password) async {
  final url = Uri.parse('$apiUrl/login');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final accessToken = data['accessToken'];

      // Decode the JWT token
      final decodedToken = JwtDecoder.decode(accessToken);
      final extractedUsername = decodedToken['userInfo']['username'];
      final extractedId = decodedToken['userInfo']['id'];

      // Store the token and user details in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', accessToken);
      await prefs.setString('username', extractedUsername);
      await prefs.setString('userId', extractedId);

      return LoginResponse(true, accessToken); // Login successful
    } else if (response.statusCode == 401) {
      return LoginResponse(false, 'Username or password is incorrect');
    } else if (response.statusCode == 400) {
      return LoginResponse(false, 'Missing username or password');
    } else {
      return LoginResponse(
          false, 'An error occurred. Status code: ${response.statusCode}');
    }
  } catch (e) {
    return LoginResponse(false, 'Error: $e');
  }
}
