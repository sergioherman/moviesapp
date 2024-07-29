import 'package:flutter/material.dart';
import 'pages/details.dart';
import 'pages/mainpage.dart';

void main(){
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      Details.routeName: (context) => Details(),
    },
    title: "Infinite Scrolling",
    debugShowCheckedModeBanner: false,
    home: MainPage(),
  ));
}