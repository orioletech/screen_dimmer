import 'package:flutter/material.dart';

// Source for colour setup - https://m3.material.io/styles/color/roles
// Primary, Secondary, Tertiary – Accent color roles used to emphasize or de-emphasize foreground elements.
// Surface - A role used for backgrounds and large, low-emphasis areas of the screen.
// Container – Roles used as a fill color for foreground elements like buttons. They should not be used for text or icons.
// On – Roles starting with this term indicate a color for text or icons on top of its paired parent color. For example, on primary is used for text and icons against the primary fill color.
// Variant – Roles ending with this term offer a lower emphasis alternative to its non-variant pair. For example, outline variant is a less emphasized version of the outline color.

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color.fromRGBO(
      0, 0, 0, 1), // Primary – High-emphasis fills, texts, and icons against surface
  onPrimary:
      Color.fromRGBO(255, 255, 255, 1), // On primary – Text and icons against primary
  primaryContainer: Color.fromRGBO(255, 255, 255,
      1), // Primary container – Standout fill color against surface, for key components like FAB
  onPrimaryContainer: Color.fromRGBO(
      0, 0, 0, 1), // On primary container – Text and icons against primary container
  secondary: Color.fromRGBO(255, 255, 255,
      1), // Secondary – Less prominent fills, text, and icons against surface
  onSecondary:
      Color.fromRGBO(0, 0, 0, 1), // On secondary – Text and icons against secondary
  secondaryContainer: Color.fromRGBO(255, 255, 255,
      1), // Secondary container – Less prominent fill color against surface, for recessive components like tonal buttons
  onSecondaryContainer: Color.fromRGBO(
      0, 0, 0, 1), // On secondary container – Text and icons against secondary container
  tertiary: Color.fromRGBO(255, 255, 255,
      1), // Tertiary – Complementary fills, text, and icons against surface
  onTertiary: Color.fromRGBO(0, 0, 0, 1), // On tertiary – Text and icons against tertiary
  tertiaryContainer: Color.fromRGBO(255, 255, 255,
      1), // Tertiary container – Complementary container color against surface, for components like input fields
  onTertiaryContainer: Color.fromRGBO(
      0, 0, 0, 1), // On tertiary container – Text and icons against tertiary container
  error: Color.fromRGBO(252, 125, 86,
      1), // Error – Attention-grabbing color against surface for fills, icons, and text, indicating urgency
  onError: Color.fromRGBO(255, 240, 235, 1), // On error – Text and icons against error
  errorContainer: Color(
      0xFFFFDAD6), // Error container – Attention-grabbing fill color against surface
  onErrorContainer:
      Color(0xFF410002), // On error container – Text and icons against error container
  outline: Color.fromARGB(
      166, 166, 166, 1), // Outline – Important boundaries, such as a text field outline
  outlineVariant: Color.fromARGB(
      255, 255, 255, 255), // Outline variant – Decorative elements, such as dividers
  surface: Color.fromRGBO(255, 255, 255, 1), // Surface – Default color for backgrounds
  onSurface:
      Color.fromRGBO(0, 0, 0, 1), // On surface – Text and icons against any surface color
  onSurfaceVariant: Color.fromRGBO(0, 0, 0,
      1), // On surface variant – Lower-emphasis color for text and icons against any surface color
  inverseSurface: Color.fromARGB(255, 0, 0, 0),
  onInverseSurface: Color(0xFFD4FF97),
  inversePrimary: Color(0xFFFFB783),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF934B00),
  scrim: Color(0xFF000000),
);
