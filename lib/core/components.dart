import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Pacifico extends StatelessWidget {
  final text;
  final size;
  final color;
  //final fontWeight;
  const Pacifico({
    super.key,
    required this.text,
    required this.size,
    this.color,
    //this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toString(),
      style: GoogleFonts.pacifico(
        fontSize: size,
        color: color ?? Colors.black,
        // fontWeight: fontWeight == null ? FontWeight.normal : fontWeight,
      ),
    );
  }
}

class OpenSans extends StatelessWidget {
  final text;
  final size;
  final color;
  final fontWeight;
  const OpenSans(
      {super.key,
      required this.text,
      required this.size,
      this.color,
      this.fontWeight});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toString(),
      style: GoogleFonts.openSans(
        fontSize: size,
        color: color ?? Colors.black,
        fontWeight: fontWeight ?? FontWeight.normal,
      ),
    );
  }
}

class Poppins extends StatelessWidget {
  final text;
  final size;
  final color;
  final fontWeight;
  const Poppins(
      {super.key,
      required this.text,
      required this.size,
      this.color,
      this.fontWeight});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toString(),
      style: GoogleFonts.poppins(
        fontSize: size,
        color: color ?? Colors.black,
        fontWeight: fontWeight ?? FontWeight.normal,
      ),
    );
  }
}
