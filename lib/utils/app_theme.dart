
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFFB2E0E0); // Mint/Teal Green
  static const Color secondary = Color(0xFF2C3E50); // Dark Blue/Slate
  static const Color accent = Color(0xFFFF7F50);   // Orange/Coral
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color lightGrey = Color(0xFFF5F5F5);
}

class AppTextStyles {
  static TextStyle get title {
    return GoogleFonts.poppins(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.secondary,
    );
  }

  static TextStyle get subtitle {
    return GoogleFonts.poppins(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.secondary,
    );
  }

  static TextStyle get body {
    return GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: AppColors.secondary,
    );
  }

  static TextStyle get button {
    return GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: AppColors.white,
    );
  }

  static TextStyle get chip {
    return GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.secondary,
    );
  }
}
