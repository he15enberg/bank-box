import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/permission_screen.dart';

void main() {
  runApp(const BankboxApp());
}

class BankboxApp extends StatelessWidget {
  const BankboxApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use JetBrains Mono as the monospace font
    final monoTextTheme = GoogleFonts.jetBrainsMonoTextTheme(
      ThemeData.dark().textTheme,
    );

    return MaterialApp(
      title: 'Bankbox',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        textTheme: monoTextTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.jetBrainsMono(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          onPrimary: Colors.black,
          surface: Color(0xFF111111),
          onSurface: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: GoogleFonts.jetBrainsMono(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFF2A2A2A)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: GoogleFonts.jetBrainsMono(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            textStyle: GoogleFonts.jetBrainsMono(),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF1A1A1A),
          contentTextStyle: GoogleFonts.jetBrainsMono(color: Colors.white),
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          textStyle: GoogleFonts.jetBrainsMono(color: Colors.white),
        ),
      ),
      home: const PermissionScreen(),
    );
  }
}
