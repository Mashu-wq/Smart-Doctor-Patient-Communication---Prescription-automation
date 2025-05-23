

import 'package:flutter/material.dart';
import 'package:medisafe/constants.dart';

InputDecoration buildInputDecoration(IconData icons, String hinttext) {
  return InputDecoration(
    hintText: hinttext,
    counter: const Offstage(),
    prefixIcon: Icon(
      icons,
      color: kPrimaryColor,
    ),
    fillColor: kPrimaryLightColor,
    filled: true,
    errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25.0),
        borderSide: const BorderSide(color: Colors.red, width: 2)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25.0),
      borderSide: const BorderSide(color: kPrimaryColor, width: 2),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25.0),
      borderSide: const BorderSide(
        color: kPrimaryLightColor,
        width: 2,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25.0),
      borderSide: const BorderSide(
        color: kPrimaryLightColor,
        width: 2,
      ),
    ),
  );
}
