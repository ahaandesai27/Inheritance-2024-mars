import 'package:flutter/material.dart';

class IngredientPage extends StatelessWidget {
  final List<Map<String, dynamic>> ingredients = [
    {'name': 'Carrot', 'price': 2.5},
    {'name': 'Broccoli', 'price': 3.0},
    {'name': 'Cabbage', 'price': 1.8},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 173, 114, 196),
        title: Text('RecipAura'),
        actions: [
          IconButton(
            icon: Icon(Icons.nightlight_round),
            onPressed: () {
              // Add theme toggle functionality here
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [DrawerHeader(child: Text('Menu'))],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  'assets/salad.jpg', // Replace with your image asset
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Broccoli Slaw',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Ingredients:',
              style: TextStyle(fontSize: 18),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: ingredients.length,
                itemBuilder: (context, index) {
                  final ingredient = ingredients[index];
                  return ListTile(
                    title: Text(ingredient['name']),
                    trailing: Text('\$${ingredient['price']}'),
                  );
                },
              ),
            ),
            Text(
              'Time for Recipe: 1 hr',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Recipe:',
              style: TextStyle(fontSize: 18),
            ),
            Text('1. Get stuff\n2. Cook'),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
