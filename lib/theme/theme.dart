import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final theme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(230, 1, 25, 44)),

  textTheme: GoogleFonts.nunitoSansTextTheme(),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Color.fromARGB(230, 0, 29, 43),
      textStyle: TextStyle(fontSize: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: Colors.white),
  ),
);
