import 'package:flutter/material.dart';
import '../themes/colours.dart';
import '../definitions/enums.dart';


class RCPCHSegmentedButtonWidget extends StatelessWidget {
  final AgeCorrectionMethod selectedPlotType;
  final ValueChanged<AgeCorrectionMethod> onPlotTypeChanged;

  const RCPCHSegmentedButtonWidget({
    super.key,
    required this.selectedPlotType,
    required this.onPlotTypeChanged,
  });

  @override
  Widget build(BuildContext context) {

    return SegmentedButton<AgeCorrectionMethod>(
      showSelectedIcon: false,
      segments: const <ButtonSegment<AgeCorrectionMethod>>[
        ButtonSegment<AgeCorrectionMethod>(
          value: AgeCorrectionMethod.chronological,
          label: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('Chronological'),
          ),
        ),
        ButtonSegment<AgeCorrectionMethod>(
          value: AgeCorrectionMethod.corrected,
          label: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('Corrected'),
          ),
        ),
        ButtonSegment<AgeCorrectionMethod>(
          value: AgeCorrectionMethod.both,
          label: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('Both'),
          ),
        ),
      ],
      // In StatelessWidget, you directly access the final fields.
      selected: <AgeCorrectionMethod>{selectedPlotType},
      onSelectionChanged: (Set<AgeCorrectionMethod> newSelection) {
        if (newSelection.isNotEmpty) {
          onPlotTypeChanged(newSelection.first); // Call the callback from the parent
        }
      },
      style: ButtonStyle(
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0), // Zero border radius
          ),
        ),
        backgroundColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return primaryColourDark; // Selected background color
            }
            return primaryColour;      // Unselected background color
          },
        ),
        foregroundColor: WidgetStateProperty.all<Color?>(
          Colors.white, // Text color for all states
        ),
        textStyle: WidgetStateProperty.all<TextStyle>(
          const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        side: WidgetStateProperty.all<BorderSide>(
          const BorderSide(
            color: Colors.transparent, // Set border color to transparent
            width: 0,                  // Set border width to 0 (optional but good practice)
          ),
        ),
      ),
      multiSelectionEnabled: false,
      emptySelectionAllowed: false,
    );
  }
}
