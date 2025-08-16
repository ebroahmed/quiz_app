import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final theme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(230, 0, 29, 43),
  ),

  appBarTheme: AppBarTheme(
    titleTextStyle: GoogleFonts.nunito(fontSize: 20),
    foregroundColor: Colors.white,
    backgroundColor: const Color.fromARGB(230, 0, 29, 43),
    elevation: 0,
    // so gradient shows behind AppBar
  ),

  textTheme: GoogleFonts.interTextTheme(),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: const Color.fromARGB(230, 0, 29, 43),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  ),
);
