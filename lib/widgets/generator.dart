import 'package:flutter/material.dart';
// RCPCH imports
import 'package:digital_growth_charts_app/themes/colours.dart';
import 'package:provider/provider.dart';
import '../definitions/enums.dart';
import '../widgets/enum_radio_group.dart';
import '../classes/app_state.dart';
import './results.dart';

class GeneratorFormState extends State<GeneratorForm> {
  // A GlobalKey to uniquely identify the Form widget
  final _formKey = GlobalKey<FormState>();
  bool _canSubmit = true;

  final List<String> _ageUnits = ['Years', 'Months', 'Weeks', 'Days'];

  int _selectedGestationWeeks = 40;
  int _selectedGestationDays = 0;
  Sex _selectedSex = Sex.male;

  final TextEditingController _startAge = TextEditingController(text: '0');
  String _startAgeUnit = 'Years';

  final TextEditingController _endAge = TextEditingController(text: '20');
  String _endAgeUnit = 'Years';

  final TextEditingController _interval = TextEditingController(text: '1');
  String _intervalUnit = 'Years';

  MeasurementMethod _measurementMethod = MeasurementMethod.height;

  bool _loading = false;

  void _checkFormValidity() {
    // Validate the form and update the _canSubmit state
    // The null check for currentState is important if the form might not be built yet.
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      setState(() {
        _canSubmit = !_canSubmit;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _loading = true;
      });
    }

    var appState = Provider.of<AppState>(context, listen: false);

    await appState.generateFictionalData(
      gestationWeeks: _selectedGestationWeeks,
      gestationDays: _selectedGestationDays,
      sex: _selectedSex,
      startChronologicalAge: double.parse(_startAge.text),
      endAge: double.parse(_endAge.text),
      measurementIntervalNumber: double.parse(_interval.text),
      measurementIntervalType: _intervalUnit.toLowerCase(),
      measurementMethod: _measurementMethod,
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ResultsPage(initialMeasurementMethod: _measurementMethod),
      ),
      (route) => route.isFirst,
    );
  }

  String _measurementMethodToString(MeasurementMethod method) {
    switch (method) {
      case MeasurementMethod.height:
        return 'Height';
      case MeasurementMethod.weight:
        return 'Weight';
      case MeasurementMethod.ofc:
        return 'Head Cm.';
      case MeasurementMethod.bmi:
        return 'BMI';
    }
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Generate data')),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Expanded(
                child: Form(
                // Wrap form content in a Form widget
                key: _formKey, // Assign the GlobalKey
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: () {
                  setState(() {
                    _canSubmit = _formKey.currentState?.validate() ?? false;
                  });
                  _checkFormValidity();
                },
                child: SingleChildScrollView(
                  // Add SingleChildScrollView to prevent overflow on smaller screens
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Gestation Weeks:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            initialValue: _selectedGestationWeeks,
                            items:
                                List.generate(
                                      19,
                                      (index) => index + 24,
                                    ) // Weeks 24 to 42
                                    .map((int weeks) {
                                      return DropdownMenuItem<int>(
                                        value: weeks,
                                        child: Text('$weeks'),
                                      );
                                    })
                                    .toList(),
                            onChanged: appState.organizedGrowthData.isNotEmpty
                                ? null
                                : (int? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _selectedGestationWeeks = newValue;
                                      });
                                    }
                                  },
                            validator: (value) {
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Gestation Days:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            initialValue: _selectedGestationDays,
                            items:
                                List.generate(7, (index) => index) // Days 0 to 6
                                    .map((int days) {
                                      return DropdownMenuItem<int>(
                                        value: days,
                                        child: Text('$days'),
                                      );
                                    })
                                    .toList(),
                            onChanged: appState.organizedGrowthData.isNotEmpty
                                ? null
                                : (int? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _selectedGestationDays = newValue;
                                      });
                                    }
                                  },
                            validator: (value) {
                              return null;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Sex Radio Buttons
                      const Text(
                        'Sex:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      EnumRadioGroup<Sex>(
                        groupValue: _selectedSex,
                        onChanged: (value) {
                          setState(() {
                            _selectedSex = value!;
                          });
                          _checkFormValidity();
                        },
                        enabled: appState.organizedGrowthData.isEmpty,
                        values: Sex.values,
                        labelBuilder: (m) {
                          switch (m) {
                            case Sex.male:
                              return 'Boy';
                            case Sex.female:
                              return 'Girl';
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Ages:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _startAge,
                              keyboardType:
                                  const TextInputType.numberWithOptions(),
                              decoration: InputDecoration(
                                labelText: 'Start (years)',
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value != null &&
                                    value.isNotEmpty &&
                                    double.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null; // Valid
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          // TODO MRB: put back once available in API
                          // https://github.com/rcpch/rcpchgrowth-python/pull/99
                          // DropdownButton<String>(
                          //   value: _startAgeUnit,
                          //   items: _ageUnits.map((String value) {
                          //     return DropdownMenuItem<String>(
                          //       value: value,
                          //       child: Text(value),
                          //     );
                          //   }).toList(),
                          //   onChanged: (value) {
                          //     setState(() {
                          //       _startAgeUnit = value!;
                          //     });
                          //   },
                          // ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _endAge,
                              keyboardType:
                                  const TextInputType.numberWithOptions(),
                              decoration: InputDecoration(
                                labelText: 'End (years)',
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value != null &&
                                    value.isNotEmpty &&
                                    double.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null; // Valid
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          // TODO MRB: put back once available in API
                          // https://github.com/rcpch/rcpchgrowth-python/pull/99
                          // DropdownButton<String>(
                          //   value: _endAgeUnit,
                          //   items: _ageUnits.map((String value) {
                          //     return DropdownMenuItem<String>(
                          //       value: value,
                          //       child: Text(value),
                          //     );
                          //   }).toList(),
                          //   onChanged: (value) {
                          //     setState(() {
                          //       _endAgeUnit = value!;
                          //     });
                          //   },
                          // ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _interval,
                              keyboardType:
                                  const TextInputType.numberWithOptions(),
                              decoration: InputDecoration(
                                labelText: 'Interval',
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value != null &&
                                    value.isNotEmpty &&
                                    double.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null; // Valid
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          DropdownButton<String>(
                            value: _intervalUnit,
                            items: _ageUnits.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _intervalUnit = value!;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      EnumRadioGroup<MeasurementMethod>(
                        groupValue: _measurementMethod,
                        onChanged: (value) {
                          setState(() {
                            _measurementMethod = value!;
                          });
                          _checkFormValidity();
                        },
                        enabled: appState.organizedGrowthData.isEmpty,
                        values: MeasurementMethod.values,
                        labelBuilder: _measurementMethodToString
                      ),
                      const SizedBox(height: 16),

                      // Submit Button
                      ElevatedButton(
                        onPressed: _canSubmit && !_loading ? _submitForm : null,
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith<Color?>((
                            Set<WidgetState> states,
                          ) {
                            if (states.contains(WidgetState.disabled)) {
                              return Colors
                                  .grey; // Optional: custom disabled color
                            }
                            if (states.contains(WidgetState.pressed)) {
                              return secondaryColour;
                            }
                            return primaryColour; // Use the component's default.
                          }),
                          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                          ),
                        ),
                        child: Text(
                          _loading ? 'Loading...' : 'Submit',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GeneratorForm extends StatefulWidget {
  const GeneratorForm({super.key});

  @override
  GeneratorFormState createState() => GeneratorFormState();
}
