import 'package:dskew/Pages/HomePage/Styles/colors.dart';
import 'package:flutter/material.dart';

class HomePageStyles {
  // Color backgroundColor = Theme.of(context).
  TextStyle errorTxt = TextStyle(
    color: HomePageColors.errorTxtColor,
    fontSize: 16,
  );
  TextStyle sourceTxt = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Colors.greenAccent[400],
  );

  TextStyle dateTxt = TextStyle(
    color: Color(0xFFFF0D0D),
    fontWeight: FontWeight.bold,
    fontSize: 12,
  );

  TextStyle termTxt = TextStyle(
    color: Color(0xFFFF0D0D),
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.italic,
    fontSize: 20,
  );
}
