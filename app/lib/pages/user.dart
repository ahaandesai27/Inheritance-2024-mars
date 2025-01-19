import 'package:app/api/localstorage.dart';
import 'package:app/widgets/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/api/fetchuser.dart'; // Ensure this contains `fetchUserById` and `User` class.

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.ralewayTextTheme(),
      ),
      home: const UserPage(),
    );
  }
}

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 173, 114, 196),
        title: Text(
          'User Page',
          style: GoogleFonts.raleway(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<User?>(
        future: fetchUserById(), // Fetch the user data directly here
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: GoogleFonts.raleway(),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text(
                'No user data available',
                style: GoogleFonts.raleway(),
              ),
            );
          }

          final user = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      NetworkImage('https://via.placeholder.com/150'),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.account_circle_sharp),
                  title: Text(
                    'Name: ${user.firstName ?? ''} ${user.lastName ?? ''}',
                    style: GoogleFonts.raleway(),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: Text(
                    'Phone Number: ${user.mobileNumber ?? 'N/A'}',
                    style: GoogleFonts.raleway(),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.mail),
                  title: Text(
                    'Email Address: ${user.email ?? 'N/A'}',
                    style: GoogleFonts.raleway(),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.dangerous),
                  title: Text(
                    'Allergies: ${user.allergies != null && user.allergies!.isNotEmpty ? user.allergies!.join(', ') : 'None'}',
                    style: GoogleFonts.raleway(),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.food_bank),
                  title: Text(
                    'Diet Plan: ${user.dietPlans != null && user.dietPlans!.isNotEmpty ? user.dietPlans!.join(', ') : 'None'}',
                    style: GoogleFonts.raleway(),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.bookmark),
                  title: Text(
                    'Saved Recipes: ${user.savedRecipes != null && user.savedRecipes!.isNotEmpty ? user.savedRecipes!.length : 'None'}',
                    style: GoogleFonts.raleway(),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: Text(
                    'Logout',
                    style: GoogleFonts.raleway(),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                          'Confirm Logout',
                          style: GoogleFonts.raleway(),
                        ),
                        content: Text(
                          'Are you sure you want to log out?',
                          style: GoogleFonts.raleway(),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.raleway(),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              await logoutUser();
                              Navigator.pop(context);
                              Navigator.pop(context);
                              //once to remove logout confirmation, other to go back to login screen
                            },
                            child: Text(
                              'Logout',
                              style: GoogleFonts.raleway(),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Navbar(),
    );
  }
}
