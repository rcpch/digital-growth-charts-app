import 'package:flutter/material.dart';

class EnumRadioGroup<T extends Enum> extends StatelessWidget {
  final T? groupValue;
  final ValueChanged<T?> onChanged;
  final List<T> values;
  final String Function(T) labelBuilder;
  final int itemsPerRow;
  final bool enabled;

  const EnumRadioGroup({
    super.key,
    required this.groupValue,
    required this.onChanged,
    required this.values,
    required this.labelBuilder,
    this.itemsPerRow = 2, // default: 2 buttons per row
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return RadioGroup<T>(
      groupValue: groupValue,
      onChanged: onChanged,
      child: Column(
        children: [
          for (var i = 0; i < values.length; i += itemsPerRow)
            Row(
              children: [
                for (var j = i; j < i + itemsPerRow && j < values.length; j++)
                  Expanded(
                    child: RadioListTile<T>(
                      title: Text(labelBuilder(values[j])),
                      value: values[j],
                      enabled: enabled,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
