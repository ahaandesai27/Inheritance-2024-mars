import 'package:app/utils/colors.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
        shape: BeveledRectangleBorder(),
        child: Container(
          decoration: BoxDecoration(
            color: Colour.purpur,
            border: Border(
                right: BorderSide(
                    color: Color.fromARGB(255, 122, 71, 142), width: 1)),
          ),
          child: Column(
            children: [],
          ),
        ));
  }
}
