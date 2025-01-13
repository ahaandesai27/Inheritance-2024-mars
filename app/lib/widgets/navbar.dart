// ignore: file_names
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
  int get _curIn {
    final String? currentRoute = ModalRoute.of(context)!.settings.name;
    return _routes.indexOf(currentRoute ?? _routes[0]);
  }

  final List<String> _routes = [
    MyRoutes.recipeRoute,
    MyRoutes.vegetableRoute,
    MyRoutes.userRoute,
  ];
  void _onItemTapped(int index) {
    print('OIndex: $_curIn');
    Navigator.pushReplacementNamed(context, _routes[index]);
    print('NIndex: $_curIn');
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _curIn,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      items: [
        _buildBottomNavigationBarItem(MdiIcons.food, '$_curIn', 0),
        _buildBottomNavigationBarItem(LineAwesomeIcons.lemon, '$_curIn', 1),
        _buildBottomNavigationBarItem(
            Icons.supervised_user_circle, '$_curIn', 2),
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
      icon: _curIn == index
          ? Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 173, 114, 196),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Icon(icon, color: Colors.white),
            )
          : Icon(
              icon,
              color: Color.fromARGB(255, 152, 152, 152),
            ),
      label: label,
      backgroundColor: Colors.transparent,
    );
  }
}
