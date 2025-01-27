import 'package:app/pages/cuisinerecipe.dart';
import 'package:app/widgets/navbar.dart';
import 'package:app/widgets/searchbar.dart';
import 'package:app/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecipePage extends StatefulWidget {
  const RecipePage({super.key});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
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
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Searchbar(),
              SizedBox(height: 20),

              // Categories Section
              const Text(
                'Cuisines',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildCategoryTile('Indian'),
                  _buildCategoryTile('Continental'),
                  _buildCategoryTile('Chinese'),
                  _buildCategoryTile('Asian'),
                  _buildCategoryTile('French'),
                  _buildCategoryTile('Middle Eastern'),
                  _buildCategoryTile('Japanese'),
                  _buildCategoryTile('Italian'),
                  _buildCategoryTile('Fusion'),
                  _buildCategoryTile('Thai'),
                ],
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
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 5.0),
                    height: 60,
                    decoration: BoxDecoration(
                      color: index % 2 == 0
                          ? Colors.greenAccent
                          : Colors.redAccent,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                      child: Text(
                        index == 0 ? 'Most recommended' : 'Recommendation',
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
            ],
          ),
        ),
      ),
      drawer: const AppDrawer(),
      bottomNavigationBar: const Navbar(),
    );
  }

  Widget _buildCategoryTile(String title) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CuisineRecipesPage(cuisine: title),
            ));
      },
      child: Container(
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
      ),
    );
  }
}
