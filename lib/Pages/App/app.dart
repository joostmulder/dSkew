import 'dart:async';
import 'package:dskew/Pages/DetailPage/detail_page.dart';
import 'package:dskew/Pages/HomePage/home_page.dart';
import 'package:flutter/material.dart';

class App extends StatefulWidget {
  App();

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  // String mode = "dark";
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        // primarySwatch: Colors.green,
        // primaryColor: Colors.blue,
        primaryColor: Color(0xFF0D11FF),
        splashColor: Colors.grey[400],
        highlightColor: Colors.black.withOpacity(.5),

        // primaryColorDark: Colors.grey[850],

        // Define the default font family.
        // fontFamily: 'Georgia',

        // Define the default TextTheme. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: TextTheme(
          headline1: TextStyle(
              fontSize: 72.0, fontWeight: FontWeight.bold, color: Colors.black),
          headline6: TextStyle(
              fontSize: 36.0, fontStyle: FontStyle.italic, color: Colors.black),
          bodyText2: TextStyle(fontSize: 12.0, color: Colors.grey[900]),
          bodyText1: TextStyle(
              fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      home: HomePage(title: 'Flutter Demo Home Page'),
      // home: DetailPage(
      //     link:
      //         'https://www.scmp.com/magazines/post-magazine/food-drink/article/3131373/neapolitan-pizzaiolo-angelo-dambrosio-talks'),
    );
  }
}
