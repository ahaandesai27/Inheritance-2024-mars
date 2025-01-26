import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class IngredientPage extends StatefulWidget {
  const IngredientPage({Key? key}) : super(key: key);

  @override
  State<IngredientPage> createState() => _IngredientPageState();
}

class _IngredientPageState extends State<IngredientPage> {
  List<Map<String, dynamic>> ingredients = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchIngredients();
  }

  Future<void> fetchIngredients() async {
    const String url = 'http://localhost:3578/api/ingredients'; // Replace with your computer's IP if needed
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          ingredients = data.map((item) {
            return {
              'name': item['name'], // Adjust to match your backend response keys
              'price': item['price'], // Adjust to match your backend response keys
            };
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch ingredients');
      }
    } catch (error) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 173, 114, 196),
        title: const Text('RecipAura'),
        actions: [
          IconButton(
            icon: const Icon(Icons.nightlight_round),
            onPressed: () {
              // Add theme toggle functionality here
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: const [DrawerHeader(child: Text('Menu'))],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : hasError
            ? const Center(
          child: Text('Failed to load ingredients.'),
        )
            : Column(
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
            const SizedBox(height: 16),
            const Text(
              'Broccoli Slaw',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
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
            const Text(
              'Time for Recipe: 1 hr',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Recipe:',
              style: TextStyle(fontSize: 18),
            ),
            const Text('1. Get stuff\n2. Cook'),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

