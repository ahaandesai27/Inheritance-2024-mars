import 'package:shared_preferences/shared_preferences.dart';

Future<String> fetchStoredUserId() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId') ?? '';

  return userId;
}

Future<bool> isUserLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId') ?? '';

  return userId.isNotEmpty;
}

Future<void> logoutUser() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}
