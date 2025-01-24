import 'package:app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:app/widgets/sidebar_button.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const BeveledRectangleBorder(),
      child: Container(
        decoration: const BoxDecoration(
          color: Colour.purpur,
          border: Border(
            right: BorderSide(
              color: Color.fromARGB(255, 122, 71, 142), 
              width: 1,
            ),
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 40), // Add more spacing at the top
            Text(
              'Recipaura',
              style: TextStyle(
                fontSize: 24, // Larger font size for the header
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20), // Add spacing below the header
            SidebarButton(
              icon: Icons.favorite,
              label: 'Favorites',
              onPressed: () {
                // Handle Favorites button press
              },
            ),
            SizedBox(height: 20), // Add more spacing between buttons
            SidebarButton(
              icon: Icons.history,
              label: 'History',
              onPressed: () {
                // Handle History button press
              },
            ),
            SizedBox(height: 20), // Add more spacing between buttons
            SidebarButton(
              icon: Icons.feedback,
              label: 'Feedback',
              onPressed: () {
                // Handle Feedback button press
              },
            ),
          ],
        ),
      ),
    );
  }
}