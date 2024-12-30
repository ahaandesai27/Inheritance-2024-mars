import 'package:app/pages/loginpage.dart';
import 'package:app/pages/recipepage.dart';
import 'package:app/pages/signuppage.dart';
import 'package:app/pages/user.dart';
import 'package:app/pages/vegetable.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const Recipaura());
}

class Recipaura extends StatelessWidget {
  const Recipaura({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Recipaura',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const LoginPage(),
        routes: {
         // "/": (context) => const UserPage(),
         // "/signup": (context) => const SignUpPage(),
         //"/login": (context) => const LoginPage(),
         // "/grocery": (context) => const GroceryPage(),
         // '/recipe': (context) => const RecipePage(),
        }
      );
  }
}
