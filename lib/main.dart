import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:google_fonts/google_fonts.dart';
// Screens.
import 'home_screen.dart';
// Styles
import 'theme_color_scheme.dart';
import 'theme_text_scheme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();

    const initialSize = Size(400, 700); // <-- your desired width/height

    const options = WindowOptions(
      size: initialSize, // sets size on launch
      minimumSize: Size(100, 100),
      center: true, // centers on first show
      titleBarStyle: TitleBarStyle.normal,
    );

    // Apply BEFORE the window becomes visible.
    windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.setTitle('Screen Dimmer'); // <-- window name
      await windowManager.show();
      await windowManager.focus();
    });
  }

  GoogleFonts.config.allowRuntimeFetching = false;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Screen Dimmer",
      themeMode: ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: lightColorScheme,
        textTheme: customTextTheme,
        sliderTheme: SliderThemeData(
          thumbColor: Colors.grey[800],
          activeTrackColor: Colors.grey[600],
          // inactiveTrackColor: lightColorScheme.onSurfaceVariant,
          // valueIndicatorColor: lightColorScheme.primary,
          // overlayColor: lightColorScheme.primary.withAlpha(2),
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
          trackHeight: 25,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
