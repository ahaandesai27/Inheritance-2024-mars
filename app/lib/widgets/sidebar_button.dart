import 'package:flutter/material.dart';

class SidebarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const SidebarButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(
          label,
          style: const TextStyle(
              fontSize: 18), // Larger font size for button labels
        ),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 40), // Full width buttons
        ),
      ),
    );
  }
}
