import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyDialog {
  static void showSnackBar({
    required BuildContext context,
    required String message,
    int seconds = 5,
    String label = 'Dismiss',

  }) {
    final snackBar = SnackBar(
      duration: Duration(seconds: seconds),
      content: Text(message),
      action: SnackBarAction(
        label: label,
        onPressed: (){},
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}