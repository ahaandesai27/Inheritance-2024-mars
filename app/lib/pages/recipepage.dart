import 'package:app/widgets/navbar.dart';
import 'package:app/widgets/searchbar.dart';
import 'package:app/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecipePage extends StatelessWidget {
  const RecipePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RecipAura',
            style:
                GoogleFonts.raleway(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 173, 114, 196),
        leading: Builder(
          builder: (BuildContext context) => IconButton(
            icon: const Icon(Icons.menu), // Three-bar icon
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Open the drawer
            },
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            SizedBox(height: 200, child: Searchbar()),
            const SizedBox(height: 20),

            // Categories Section
            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Flexible(
              flex: 2,
              child: GridView.count(
                crossAxisCount: 5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildCategoryTile('Burger'),
                  _buildCategoryTile('Chicken'),
                  _buildCategoryTile('Salad'),
                  _buildCategoryTile('Soup'),
                  _buildCategoryTile('Cake'),
                  _buildCategoryTile('Pasta'),
                  _buildCategoryTile('Pizza'),
                  _buildCategoryTile('Rolls'),
                  _buildCategoryTile('Rice'),
                  _buildCategoryTile('Dessert'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Recommended for You Section
            const Text(
              'Recommended for you',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              flex: 3,
              child: ListView.builder(
                itemCount: 5, // Placeholder for 5 items
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 5.0),
                    height: 60,
                    decoration: BoxDecoration(
                      color: index % 2 ==
                              0 //Put Condition here asking for veg nonveg
                          ? Colors.greenAccent
                          : Colors.redAccent,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                      child: Text(
                        index == 0
                            ? 'Most recommended'
                            : 'Recommendation', //Sort by most recommended
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      drawer: AppDrawer(),
      bottomNavigationBar: Navbar(),
    );
  }

  Widget _buildCategoryTile(String title) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.grey),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
