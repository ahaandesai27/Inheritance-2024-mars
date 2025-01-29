// ignore_for_file: file_names

import 'package:app/utils/colors.dart';
import 'package:app/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  late int _currentIndex = 0;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context)?.settings.name;
    _currentIndex = _routes.indexWhere((r) => r == route);
    if (_currentIndex == -1) {
      _currentIndex = 0;
    }
  }

  final List<String> _routes = [
    MyRoutes.recipeRoute,
    MyRoutes.vegetableRoute,
    MyRoutes.userRoute,
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      Navigator.pushReplacementNamed(context, _routes[index]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      items: [
        _buildBottomNavigationBarItem(MdiIcons.food, 'Recipes', 0),
        _buildBottomNavigationBarItem(LineAwesomeIcons.lemon, 'Vegetables', 1),
        _buildBottomNavigationBarItem(
            Icons.supervised_user_circle, 'Profiles', 2),
      ],
      selectedItemColor: const Color.fromARGB(255, 70, 54, 74),
      unselectedItemColor: const Color.fromARGB(255, 152, 152, 152),
      selectedLabelStyle: TextStyle(
        fontFamily: GoogleFonts.raleway().fontFamily,
      ),
      unselectedLabelStyle: GoogleFonts.raleway(),
    );
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem(
      IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      icon: _currentIndex == index
          ? Container(
              decoration: BoxDecoration(
                color: Colour.purpur,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Icon(icon, color: Colors.white),
            )
          : Icon(
              icon,
              color: const Color.fromARGB(255, 152, 152, 152),
            ),
      label: label,
      backgroundColor: Colors.transparent,
    );
  }
}
