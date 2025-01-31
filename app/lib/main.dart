import 'package:app/api/localstorage.dart';
import 'package:app/pages/loginpage.dart';
import 'package:app/pages/recipepage.dart';
import 'package:app/pages/signuppage.dart';
import 'package:app/pages/user.dart';
import 'package:app/pages/ingredientselector.dart';
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
  get apiBaseUrl => null;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recipaura',
      theme: ThemeData(
        fontFamily: GoogleFonts.raleway().fontFamily,
        primarySwatch: Colors.blue,
      ),
      routes: {
        "/": (context) => FutureBuilder<bool>(
              future: isUserLoggedIn(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                return snapshot.data == true ? const RecipePage() : LoginPage();
              },
            ),
        MyRoutes.userRoute: (context) => const UserPage(),
        MyRoutes.signUpRoute: (context) => SignUpPage(),
        MyRoutes.loginRoute: (context) => LoginPage(),
        MyRoutes.vegetableRoute: (context) => const IngredientSelector(),
        MyRoutes.recipeRoute: (context) => const RecipePage(),
      },
    );
  }
}
