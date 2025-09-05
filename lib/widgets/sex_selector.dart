import 'package:flutter/material.dart';
import 'package:digital_growth_charts_app/definitions/enums.dart';

class SexSelector extends StatefulWidget {
  final Map<dynamic, dynamic> organizedGrowthData;

  const SexSelector({super.key, required this.organizedGrowthData});

  @override
  State<SexSelector> createState() => _SexSelectorState();
}

class _SexSelectorState extends State<SexSelector> {
  Sex? _selectedSex;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.organizedGrowthData.isNotEmpty;

    return RadioGroup<Sex>(
      groupValue: _selectedSex,
      onChanged: (Sex? value) {
        if (isDisabled) return;
        setState(() => _selectedSex = value);
      },
      child: Row(
        children: [
          Expanded(
            child: RadioListTile<Sex>(
              title: const Text('Male'),
              value: Sex.male,
              enabled: !isDisabled,        // greys out when disabled
            ),
          ),
          Expanded(
            child: RadioListTile<Sex>(
              title: const Text('Female'),
              value: Sex.female,
              enabled: !isDisabled,
            ),
          ),
        ],
      ),
    );
  }
}