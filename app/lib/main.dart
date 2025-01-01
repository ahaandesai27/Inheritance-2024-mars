import 'package:app/pages/loginpage.dart';
import 'package:app/pages/recipepage.dart';
import 'package:app/pages/signuppage.dart';
import 'package:app/pages/user.dart';
import 'package:app/pages/vegetable.dart';
import 'package:app/utils/routes.dart';
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
        routes: {
          "/": (context) => const SignUpPage(),
          MyRoutes.userRoute: (context) => const UserPage(),
          MyRoutes.signUpRoute: (context) => const SignUpPage(),
          MyRoutes.loginRoute: (context) => const LoginPage(),
          MyRoutes.vegetableRoute: (context) => const GroceryPage(),
          MyRoutes.recipeRoute: (context) => const RecipePage(),
        });
  }
}
