import 'package:flutter/material.dart';

void showAuthDialog(BuildContext context, Widget authScreen) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          height:
              MediaQuery.of(context).size.height *
              0.5, // Adjust height as needed
          padding: const EdgeInsets.all(20),
          child: authScreen,
        ),
      );
    },
  );
}
