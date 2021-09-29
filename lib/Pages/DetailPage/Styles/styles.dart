import 'package:dskew/Pages/DetailPage/Styles/colors.dart';
import 'package:flutter/material.dart';

class DetailPageStyles {
  // Color backgroundColor = Theme.of(context).
  TextStyle errorTxt = TextStyle(
    color: DetailPageColors.errorTxtColor,
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
}
