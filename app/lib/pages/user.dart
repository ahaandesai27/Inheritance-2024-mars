import 'package:app/widgets/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      home: UserPage(),
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
            icon: const Icon(Icons.menu), // Three-bar icon
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Open the drawer
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.account_circle_sharp),
              title: Text(
                'Name: ',
                style: GoogleFonts.raleway(),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text(
                'Phone Number: ',
                style: GoogleFonts.raleway(),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.mail),
              title: Text(
                'Email Address: ',
                style: GoogleFonts.raleway(),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.dangerous),
              title: Text(
                'Allergies: ',
                style: GoogleFonts.raleway(),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.food_bank),
              title: Text(
                'Diet Plan: ',
                style: GoogleFonts.raleway(),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: Text(
                'Saved: ',
                style: GoogleFonts.raleway(),
              ),
              onTap: () {},
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
                        onPressed: () {
                          Navigator.pop(context);
                          // Perform logout logic here
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
      ),
      bottomNavigationBar: Navbar(),
    );
  }
}
