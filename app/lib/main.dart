import 'package:app/pages/loginpage.dart';
import 'package:app/pages/recipepage.dart';
import 'package:app/pages/signuppage.dart';
import 'package:app/pages/user.dart';
import 'package:app/pages/vegetable.dart';
import 'package:app/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(Recipaura());
}

class Recipaura extends StatefulWidget {
  Recipaura({super.key});

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
          "/": (context) => RecipePage(),
          MyRoutes.userRoute: (context) => UserPage(),
          MyRoutes.signUpRoute: (context) => SignUpPage(),
          MyRoutes.loginRoute: (context) => LoginPage(),
          MyRoutes.vegetableRoute: (context) => GroceryPage(),
          MyRoutes.recipeRoute: (context) => RecipePage(),
        });
  }
}
