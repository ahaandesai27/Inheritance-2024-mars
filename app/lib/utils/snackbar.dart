import 'package:flutter/material.dart';

void showCustomSnackbar(
    BuildContext context, String message, Color backgroundColor,
    {int seconds = 3}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: backgroundColor,
      duration: Duration(seconds: seconds),
    ),
  );
}
