import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class CustomToast {
  // SUCESS ALERT
  void successAlert(BuildContext context, String msg) {
    Toast.show(msg, context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
        backgroundColor: Colors.grey[800],
        textColor: Colors.greenAccent);
  }

  // ERROR ALERT
  void errorAlert(BuildContext context, String msg) {
    Toast.show(msg, context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
        backgroundColor: Colors.grey[800],
        textColor: Colors.red);
  }
}
