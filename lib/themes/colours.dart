import 'package:flutter/material.dart';
const seedColor = Color(0xFF11a7f2); // Your original primary color

const primaryColour = Color(0xFF11a7f2);
const primaryColourLight = Color(0xFFf0fafe);
const primaryColourDark = Color(0xFF3366cc);
const secondaryColour = Color(0xFFe00087);
const secondaryColourLight = Color(0xFFFFDEEA);

const background = Color(0xFFFFFFFF);
const textColor = Color(0xFF000000);

class DigitalGrowthChartsTheme {
  static final ThemeData defaultTheme = _buildDigitalGrowthChartsTheme();

  static ThemeData _buildDigitalGrowthChartsTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed( // Use fromSeed for better M3 scheme
        seedColor: seedColor,
        brightness: Brightness.light, // Or Brightness.dark for a dark theme
        surface: background, // If your background is also your main surface
        onSurface: textColor,
      ),
    );
  }
}