import 'package:flutter/material.dart';

Widget txtfield(String txt, int mxlines, controller) {
  return TextField(
    controller: controller,
    maxLines: mxlines,
    cursorHeight: 25,
    style: const TextStyle(
      decoration: TextDecoration.none,
      color: Colors.black,
    ),
    cursorColor: Colors.grey.withOpacity(0.8),
    decoration: InputDecoration(
      labelText: txt,
      labelStyle:
          const TextStyle(decoration: TextDecoration.none, color: Colors.grey),
      hintStyle: const TextStyle(
        color: Colors.grey,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(0),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
