import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Styling.
import 'theme_color_scheme.dart';

TextTheme customTextTheme = TextTheme(
  headlineMedium: GoogleFonts.arvo(
    textStyle: TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.normal,
      color: lightColorScheme.primary,
    ),
  ),
  titleMedium: GoogleFonts.oswald(
    textStyle: TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.normal,
      color: lightColorScheme.primary,
    ),
  ),
  // Body text
  bodyMedium: GoogleFonts.oswald(
    textStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.normal,
      color: lightColorScheme.primary,
      letterSpacing: 0,
    ),
  ),
);
