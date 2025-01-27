import 'package:app/pages/ingredientpage.dart';
import 'package:app/pages/loginpage.dart';
import 'package:app/pages/recipepage.dart';
import 'package:app/pages/signuppage.dart';
import 'package:app/pages/user.dart';
import 'package:app/pages/vegetable.dart';
import 'package:app/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const Recipaura());
}

class Recipaura extends StatefulWidget {
  const Recipaura({super.key});

  @override
  State<Recipaura> createState() => _RecipauraState();
}

class _RecipauraState extends State<Recipaura> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Recipaura',
        theme: ThemeData(
          fontFamily: GoogleFonts.raleway().fontFamily,
          primarySwatch: Colors.blue,
        ),
        routes: {
          "/": (context) => LoginPage(),
          MyRoutes.userRoute: (context) => const UserPage(),
          MyRoutes.signUpRoute: (context) => SignUpPage(),
          MyRoutes.loginRoute: (context) => LoginPage(),
          MyRoutes.vegetableRoute: (context) => const GroceryPage(),
          MyRoutes.recipeRoute: (context) => const RecipePage(),
        });
  }
}
