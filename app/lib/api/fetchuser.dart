import 'dart:convert';
import 'package:app/api/localstorage.dart';
import 'package:http/http.dart' as http;
import 'package:app/api/apiurl.dart';

class User {
  String? id;
  String? username;
  String? password;
  String? firstName;
  String? lastName;
  String? email;
  String? mobileNumber;
  List<dynamic>? savedRecipes;
  List<dynamic>? history;
  List<dynamic>? allergies;
  List<dynamic>? refreshToken;
  bool? veg;
  List<dynamic>? dietPlans;
  DateTime? createdAt;
  int? v;

  // constructor
  User({
    this.id,
    this.username,
    this.password,
    this.firstName,
    this.lastName,
    this.email,
    this.mobileNumber,
    this.savedRecipes,
    this.history,
    this.allergies,
    this.refreshToken,
    this.veg,
    this.dietPlans,
    this.createdAt,
    this.v,
  });

  // json factory
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      username: json['username'],
      password: json['password'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      mobileNumber: json['mobileNumber'],
      savedRecipes: json['savedRecipes'] ?? [],
      history: json['history'] ?? [],
      allergies: json['allergies'] ?? [],
      refreshToken: json['refreshToken'] ?? [],
      veg: json['veg'],
      dietPlans: json['dietPlans'] ?? [],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'mobileNumber': mobileNumber,
      'savedRecipes': savedRecipes,
      'history': history,
      'allergies': allergies,
      'refreshToken': refreshToken,
      'veg': veg,
      'dietPlans': dietPlans,
      'createdAt': createdAt?.toIso8601String(),
      '__v': v,
    };
  }
}

Future<User?> fetchUserById() async {
  try {
    final id = await fetchStoredUserId(); // Fetch the stored user ID

    if (id == null || id.isEmpty) {
      print('Error: No user ID found in storage.');
      return null;
    }

    final url = Uri.parse("$apiUrl/api/user/id/$id");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      print('Error: Failed to fetch user. Status code: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Exception occurred: $e');
    return null;
  }
}
