import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nft_sea/constant.dart';

class AppTheme {
  ThemeData darkTheme = ThemeData.dark().copyWith(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: Color(primaryColor),
    textTheme: TextTheme(
      displaySmall: GoogleFonts.openSans(
          color: Color(primaryColor), fontWeight: FontWeight.w500),
      titleLarge: GoogleFonts.poppins(color: Colors.white),
      titleSmall: GoogleFonts.openSans(color: Colors.white),
      bodySmall: GoogleFonts.openSans(color: Colors.white),
    ),

    //  cardColor: const Color(0xFF232323),
  );
  ThemeData lightTheme = ThemeData.light().copyWith(
    useMaterial3: true,
    brightness: Brightness.light,
    textTheme: TextTheme(
      displaySmall: GoogleFonts.openSans(color: Color(primaryColor)),
      titleLarge: GoogleFonts.openSans(color: Colors.black),
      titleSmall: GoogleFonts.openSans(color: Colors.black),
      bodySmall: GoogleFonts.openSans(color: Colors.black),
    ),
  );
}
