import 'package:flutter/material.dart';

// Your existing base colors
const seedColor = Color(0xFF11a7f2); // Your original primary color

const primaryColour = Color(0xFF11a7f2);
const primaryColourLight = Color(0xFFf0fafe);
const primaryColourDark = Color(0xFF3366cc);
const secondaryColour = Color(0xFFe00087);
const secondaryColourLight = Color(0xFFFFDEEA);

const background = Color(0xFFFFFFFF);
const textColor = Color(0xFF000000);

// New class for colors used specifically in the app, including chart colors
class AppColours {
  // Colors for centile lines
  static const Color centileLineColorNormal = primaryColour; // Using your primary color for normal lines
  static const Color centileLineColorSDS = Colors.red; // Distinct color for extreme centiles (e.g., 0.4th, 99.6th)

  // Colors for growth data points
  static const Color chronologicalPointColor = Colors.black; // Color for chronological measurement points
  static const Color correctedPointColor = Colors.black; // Using your secondary color for corrected points

  // Utility function to get color based on centile value
  static Color centileLineColor(double? centile) {
    if (centile == null) {
      return Colors.grey; // Default color for null or undefined centile
    }
    // Example might return grey for SDS lines rendered on BMI chart for example
    // if (centile == 0.4 || centile == 99.6) {
    //   return centileLineColorSDS;
    // }
    return centileLineColorNormal;
  }
}


// Your existing theme definition
class DigitalGrowthChartsTheme {
  static final ThemeData defaultTheme = _buildDigitalGrowthChartsTheme();

  static ThemeData _buildDigitalGrowthChartsTheme() {
    return ThemeData(
      useMaterial3: true,
      // Define the color scheme
      colorScheme: ColorScheme.fromSeed( // Use fromSeed for better M3 scheme
        seedColor: seedColor,
        brightness: Brightness.light, // Or Brightness.dark for a dark theme
        surface: background, // If your background is also your main surface
        onSurface: textColor,
        // You can also define other colors from your palette here
        primary: primaryColour,
        primaryContainer: primaryColourLight,
        // secondary: secondaryColour, // Uncomment and set if you want to use secondary color in the M3 scheme
        // secondaryContainer: secondaryColourLight, // Uncomment and set
        // error: Colors.red, // Example error color
        // onPrimary: Colors.white, // Example color on primary
        // onSurface: textColor, // Already set above
        // onError: Colors.white, // Example color on error
      ),
      // You can add other theme properties here, like typography, shapes, etc.
      // textTheme: const TextTheme(...),
      // appBarTheme: const AppBarTheme(...),
      // buttonTheme: const ButtonThemeData(...),
    );
  }
}