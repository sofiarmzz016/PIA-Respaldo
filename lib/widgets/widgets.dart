// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

const textInputDecoration = InputDecoration(
  labelStyle: TextStyle(color:Color(0xFF757575)),
  filled: true,
  fillColor: Color(0xFFEEEEEE),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide( color:Color(0xFF757575)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide( color:Colors.white),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide( color:Color(0xFFD50000)),
  ),
  
);


void nextScreen(context, page) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}

void nextScreenReplace(context, page) {
  Navigator.pushReplacement(
    context, MaterialPageRoute(builder: (context) => page));
}

void showSnackbar (context, color, message){
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message, 
        style: TextStyle(fontSize: 14)
      ),
      backgroundColor: color,
      duration: Duration(seconds: 2),
      action: SnackBarAction(
        label: "OK",
        onPressed: () {},
        textColor: Colors.white,
      )
    )
  );
}