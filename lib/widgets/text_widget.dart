import 'package:flutter/material.dart';

Widget customText(
    String txt, double size, FontWeight fw, Color col, String fontfamily) {
  return Text(
    txt,
    maxLines: 3,
    style: TextStyle(
        fontFamily: fontfamily,
        fontSize: size,
        fontWeight: fw,
        color: col,
        overflow: TextOverflow.ellipsis),
  );
}
