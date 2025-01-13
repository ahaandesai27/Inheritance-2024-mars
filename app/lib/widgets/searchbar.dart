import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Searchbar extends StatefulWidget {
  const Searchbar({super.key});

  @override
  State<Searchbar> createState() => _SearchbarState();
}

class _SearchbarState extends State<Searchbar> {
  List recipes = [];
  String searchQuery = '';
  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  Future<void> fetchRecipes({String query = ''}) async {
    final endpoint = query.isEmpty
        ? 'http://localhost:4000/api/recipes'
        : 'http://localhost:4000/api/recipes?search=$query';
    try {
      final response = await http.get(Uri.parse(endpoint));
      if (response.statusCode == 200) {
        setState(() {
          recipes = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load recipes');
      }
    } catch (e) {
      print('Error fetching recipes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 5),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                borderSide: BorderSide(
                  width: 0,
                  color: Color.fromARGB(255, 173, 114, 196),
                  style: BorderStyle.none,
                ),
              ),
              filled: true,
              prefixIcon: Icon(
                Icons.search,
                color: Color.fromARGB(255, 173, 114, 196),
              ),
              fillColor: Color(0xFFFAFAFA),
              suffixIcon: Icon(
                Icons.sort,
                color: Color.fromARGB(255, 173, 114, 196),
              ),
              hintStyle: new TextStyle(color: Color(0xFFd0cece), fontSize: 18),
              hintText: "What would your like to buy?",
            ),
            /*onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
              fetchRecipes(query: value);
            },*/
          ),
          //SizedBox(height: 10),
          /*Expanded(
              child: recipes.isEmpty
                  ? Center(child: Text('No recipes found'))
                  : ListView.builder(
                      itemCount: recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = recipes[index];
                        return ListTile(
                          title: Text(recipe['translatedRecipeName']),
                          subtitle: Text('Cuisine: ${recipe['cuisine']}'),
                          leading: recipe['imageUrl'] != null
                              ? Image.network(recipe['imageUrl'], width: 50)
                              : Icon(Icons.fastfood),
                        );
                      }))*/
        ],
      ),
    );
  }
}
