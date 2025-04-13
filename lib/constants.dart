import 'package:flutter/material.dart';

const kPrimaryColor = Color.fromARGB(225, 244, 76, 213);
const kPrimarydark = Color.fromARGB(206, 241, 136, 229);
const kPrimarydark1 = Color.fromARGB(171, 235, 167, 229);
const kPrimaryLightColor = Color(0xCDDBC2F8);
const kprimaryLightBlue = Color(0x59771DA5);
const kPrimaryLightdark = Color(0xD7EBD4F8);
const kPrimaryhinttext = Color(0xB93B2647);

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: kPrimaryColor, width: 2.0),
  ),
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: 'Type your message here...',
  border: InputBorder.none,
);

const kSendButtonTextStyle = TextStyle(
  color: kPrimaryColor,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);
