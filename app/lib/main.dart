import 'package:flutter/material.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0x889df2f5),
        title: const Text('User Page'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                  'https://via.placeholder.com/150'), // Placeholder image
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.verified_user),
              title: const Text('Name: '),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Phone Number: '),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.mail),
              title: const Text('Email Address: '),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.food_bank),
              title: const Text('Allergies: '),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.next_plan),
              title: const Text('Diet Plan: '),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('History: '),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                // Handle logout
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Logout'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Perform logout logic here
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(items: const [
        BottomNavigationBarItem(icon: Icon(Icons.cookie), label: 'Recipe'),
        BottomNavigationBarItem(
            icon: Icon(Icons.coffee_maker_outlined), label: 'Vegetable'),
        BottomNavigationBarItem(
            icon: Icon(Icons.supervised_user_circle), label: 'User'),
      ]),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: UserPage(),
  ));
}
