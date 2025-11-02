import 'package:flutter/material.dart';

Widget textField(controller, String txt) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          hintStyle: const TextStyle(color: Colors.grey),
          hintText: txt,
          labelText: txt,
          fillColor: Colors.white70),
    ),
  );
}
