import 'dart:async';
import 'package:app/services/getservicesrecipes.dart';
import 'package:app/utils/colors.dart';
import 'package:flutter/material.dart';

class Searchbar extends StatefulWidget {
  const Searchbar({super.key});

  @override
  State<Searchbar> createState() => _SearchbarState();
}

class _SearchbarState extends State<Searchbar> {
  final Map<String, List<dynamic>> _searchCache = {};
  Timer? _debounceTimer;
  final _getServices = Getservices();
  final LayerLink _layerLink = LayerLink();
  List<dynamic> recipes = [];
  String searchQuery = '';
  bool isLoading = false;
  bool hasMore = true;
  final ScrollController _scrollController = ScrollController();
  OverlayEntry? _overlayEntry;
  static const int limit = 10;
  int skip = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounceTimer?.cancel();
    _removeOverlay();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!isLoading && hasMore) {
        Future.delayed(const Duration(milliseconds: 100), fetchRecipes);
      }
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> fetchRecipes() async {
    if (isLoading || searchQuery.isEmpty) return;

    if (_searchCache.containsKey(searchQuery) && skip == 0) {
      setState(() {
        recipes = _searchCache[searchQuery]!;
        isLoading = false;
      });
    }

    setState(() => isLoading = true);

    try {
      final newRecipes = await _getServices.search(searchQuery, skip, limit);

      setState(() {
        if (skip == 0) {
          _searchCache[searchQuery] = newRecipes;
          recipes = newRecipes;
        } else {
          recipes.addAll(newRecipes);
        }

        skip += limit;
        hasMore = newRecipes.length == limit;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();

    setState(() {
      searchQuery = value.trim(); //HERE
      recipes = [];
      skip = 0;
      hasMore = true;
    });

    if (value.isEmpty) {
      _removeOverlay();
      return;
    }

    if (_overlayEntry == null) {
      _createOverlay();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), fetchRecipes);
  }

  void _createOverlay() {
    _removeOverlay();
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 32,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 55),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: _buildResultsList(),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _buildResultsList() {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (recipes.isEmpty && !isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No recipes found'),
      );
    }
    return ListView.builder(
      controller: _scrollController,
      shrinkWrap: true,
      itemCount: recipes.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < recipes.length) {
          final recipe = recipes[index];
          return InkWell(
            onTap: () {
              _removeOverlay();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: recipe['image-url'] != null
                        ? Image.network(
                            recipe['image-url'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, _) {
                              return const Icon(Icons.food_bank, size: 40);
                            },
                          )
                        : const Icon(Icons.food_bank, size: 40),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      recipe['TranslatedRecipeName'] ?? 'Check',
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        decoration: const InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            borderSide: BorderSide(
              color: Colour.purpur,
              width: 0,
              style: BorderStyle.none,
            ),
          ),
          filled: true,
          prefixIcon: Icon(Icons.search, color: Colour.purpur),
          fillColor: Colors.white,
          hintStyle: TextStyle(color: Color(0xFFd0cece), fontSize: 18),
          hintText: 'Search for recipes',
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }
}
