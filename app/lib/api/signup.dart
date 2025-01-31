import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/api/apiurl.dart';

Future<bool> registerUser(
  String username,
  String firstName,
  String lastName,
  String email,
  String phoneNumber,
  String password,
) async {
  final url = Uri.parse('$apiUrl/register');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'mobileNumber': phoneNumber,
        'password': password,
        'vegetarian': false,
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}
