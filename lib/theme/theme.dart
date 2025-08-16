import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final theme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(230, 51, 14, 1),
  ),
  scaffoldBackgroundColor: Colors.transparent, // make it transparent

  appBarTheme: AppBarTheme(
    titleTextStyle: GoogleFonts.quicksand(fontSize: 20),
    foregroundColor: Colors.white,
    elevation: 0,
    backgroundColor: Colors.transparent, // so gradient shows behind AppBar
  ),

  textTheme: GoogleFonts.interTextTheme(),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  ),
);
