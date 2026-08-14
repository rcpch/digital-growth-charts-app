import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// RCPCH imports
import 'package:digital_growth_charts_app/themes/colours.dart';
import 'package:digital_growth_charts_app/classes/log_levels.dart';
import 'package:provider/provider.dart';
import '../definitions/enums.dart';
import './results.dart';
import '../widgets/enum_radio_group.dart';
import '../classes/app_state.dart';
import '../definitions/helpers.dart';

class InputFormState extends State<InputForm> {
  // A GlobalKey to uniquely identify the Form widget
  final _formKey = GlobalKey<FormState>();
  bool _canSubmit = false;

  // Controllers for the input fields
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _observationDateController =
      TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ofcController = TextEditingController();

  final TextEditingController _bmiController = TextEditingController();
  final TextEditingController _derivedBmiController = TextEditingController();

  // Variables to hold the selected dates (stored as DateTime objects for comparisons)
  DateTime? _selectedDob;
  DateTime? _selectedClinicDate;

  // Variable to hold the selected Sex
  Sex _selectedSex = Sex.male; // Default to Male

  // State variables for the collapsable gestation section
  bool _showGestationFields = false;
  int _selectedGestationWeeks = 40; // Default to 40 weeks
  int _selectedGestationDays = 0; // Default to 0 days

  bool _loading = false;

  void _checkFormValidity() {
    // Validate the form and update the _canSubmit state
    // The null check for currentState is important if the form might not be built yet.
    final formValid =
        _formKey.currentState != null && _formKey.currentState!.validate();
    // At least one measurement (height, weight, or OFC) must be supplied.
    final hasMeasurement =
        _heightController.text.isNotEmpty ||
        _weightController.text.isNotEmpty ||
        _ofcController.text.isNotEmpty ||
        _bmiController.text.isNotEmpty;
    final canSubmit = formValid && hasMeasurement;
    if (canSubmit != _canSubmit) {
      setState(() {
        _canSubmit = canSubmit;
      });
    }
  }

  void _updateBmi() {
    if (_heightController.text.isNotEmpty &&
        _weightController.text.isNotEmpty) {
      final height = double.tryParse(_heightController.text);
      final weight = double.tryParse(_weightController.text);
      if (height != null && weight != null) {
        final bmi = calculateBmi(weight, height);
        if (bmi != null) {
          _derivedBmiController.text = bmi.toStringAsFixed(2);
        }
      }
    } else {
      _derivedBmiController.clear();
    }
  }

  @override
  void initState() {
    super.initState();

    var appState = Provider.of<AppState>(context, listen: false);

    // Check if fixed data exists (meaning we are returning from a submission)
    if (appState.dob != null) {
      // Populate the Date of Birth field (for display, it's locked to edits)
      _dobController.text = DateFormat('yyyy-MM-dd').format(appState.dob!);
      _selectedDob = appState.dob;
    }
    if (appState.sex != null) {
      // Populate the Sex selection (for display, it's locked to edits)
      _selectedSex = appState.sex!;
    }
    if (appState.gestationWeeks != null) {
      // Populate Gestation fields and state
      _selectedGestationWeeks = appState.gestationWeeks!;
      _selectedGestationDays = appState.gestationDays!;
      _showGestationFields = true; // Expand gestation section if data exists
    }

    _heightController.addListener(_updateBmi);
    _weightController.addListener(_updateBmi);
  }

  // Function to show the date picker and update the text field and state
  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller, {
    required bool isDob,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isDob
          ? (_selectedDob ?? // Use selected DOB if available
                DateTime(
                  DateTime.now().year - 1,
                  DateTime.now().month,
                  DateTime.now().day,
                )) // Otherwise suggest a recent year
          : (_selectedClinicDate ?? // Use selected clinic date if available
                DateTime.now())), // Otherwise suggest today
      firstDate: DateTime(1900), // Adjust as needed
      lastDate: DateTime.now(), // Cannot select a future date for either
    );
    if (picked != null) {
      setState(() {
        // Format the selected date for the text field display
        final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
        controller.text = formattedDate;
        // Store the selected date as DateTime for validation comparisons
        if (isDob) {
          _selectedDob = picked;
        } else {
          _selectedClinicDate = picked;
        }
      });
    }
  }

  void _resetForm() {
    _heightController.clear();
    _weightController.clear();
    _ofcController.clear();
    _bmiController.clear();

    setState(() {
      // Don't reset the observation date, it's annoying to have to select it again
      // https://github.com/rcpch/digital-growth-charts-app/issues/21
      _canSubmit = false;
    });
  }

  void _hardResetForm() {
    var appState = Provider.of<AppState>(context, listen: false);
    appState.reset();

    _observationDateController.clear();
    _heightController.clear();
    _weightController.clear();
    _ofcController.clear();
    _bmiController.clear();
    _dobController.clear();
    _selectedClinicDate = null;
    _selectedDob = null;
    _selectedSex = Sex.male;
    setState(() {
      _selectedClinicDate = null;
    });
  }

  // Function to handle the submit button press
  void _submitForm() async {
    setState(() {});

    var appState = Provider.of<AppState>(context, listen: false);

    // Validate the form using the _formKey
    if (_formKey.currentState!.validate()) {
      // If the form is valid, process the data
      _formKey.currentState!
          .save(); // Save the form fields (not strictly necessary for TextFormFields with controllers, but good practice)

      // Access the entered values:
      final String clinicDate = _observationDateController.text;

      if (appState.organizedGrowthData.isNotEmpty) {
        // If there's existing data, check if the current demographics match the fixed ones
        if (_selectedDob != appState.dob ||
            _selectedSex != appState.sex ||
            _selectedGestationWeeks != appState.gestationWeeks ||
            _selectedGestationDays != appState.gestationDays) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Date of Birth, Sex, and Gestation must remain the same for the same child.',
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
          return; // Stop the submission process
        }
      } else {
        // This is the first submission, so store the demographics as fixed
        appState.dob = _selectedDob;
        appState.sex = _selectedSex;
        appState.gestationWeeks = _selectedGestationWeeks;
        appState.gestationDays = _selectedGestationDays;
      }

      setState(() => _loading = true);

      final List<Future> tasks = [];
      MeasurementMethod? firstMeasurementMethod;

      if (_heightController.text.isNotEmpty) {
        firstMeasurementMethod ??= MeasurementMethod.height;

        tasks.add(
          appState.addMeasurement(
            observationDate: clinicDate,
            method: MeasurementMethod.height,
            value: _heightController.text,
          ),
        );
      }

      if (_weightController.text.isNotEmpty) {
        firstMeasurementMethod ??= MeasurementMethod.weight;

        tasks.add(
          appState.addMeasurement(
            observationDate: clinicDate,
            method: MeasurementMethod.weight,
            value: _weightController.text,
          ),
        );
      }

      if (_ofcController.text.isNotEmpty) {
        firstMeasurementMethod ??= MeasurementMethod.ofc;

        tasks.add(
          appState.addMeasurement(
            observationDate: clinicDate,
            method: MeasurementMethod.ofc,
            value: _ofcController.text,
          ),
        );
      }

      if (_bmiController.text.isNotEmpty) {
        firstMeasurementMethod ??= MeasurementMethod.bmi;

        tasks.add(
          appState.addMeasurement(
            observationDate: clinicDate,
            method: MeasurementMethod.bmi,
            value: _bmiController.text,
          ),
        );
      } else if (_weightController.text.isNotEmpty &&
          _heightController.text.isNotEmpty) {
        final bmi = calculateBmi(
          double.tryParse(_weightController.text) ?? 0,
          double.tryParse(_heightController.text) ?? 0,
        );

        if (bmi != null) {
          tasks.add(
            appState.addMeasurement(
              observationDate: clinicDate,
              method: MeasurementMethod.bmi,
              value: bmi.toStringAsFixed(2),
            ),
          );
        }
      }

      try {
        await Future.wait(tasks);

        _resetForm();

        // If the API call is successful and returns a response, navigate to the results page
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ResultsPage(initialMeasurementMethod: firstMeasurementMethod),
            ),
          );
        }
      } catch (e) {
        // Handle API call errors
        developer.log(
          'Error during API submission: $e',
          level: LogLevel.warning,
          name: 'DigitalGrowthChartsService',
          error: e,
          stackTrace: StackTrace.current,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to submit data: ${e.toString()}'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } finally {
        setState(() => _loading = false);
      }
    } else {
      // If the form is invalid, show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors in the form.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    _dobController.dispose();
    _observationDateController.dispose();
    _heightController.removeListener(_updateBmi);
    _heightController.dispose();
    _weightController.removeListener(_updateBmi);
    _weightController.dispose();
    _ofcController.dispose();
    _bmiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    return Form(
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
            // Date of Birth Field
            TextFormField(
              controller: _dobController,
              readOnly: appState.organizedGrowthData.isNotEmpty,
              decoration: const InputDecoration(
                labelText: 'Date of Birth',
                suffixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              enabled: appState.organizedGrowthData.isEmpty,
              onTap: appState.organizedGrowthData.isNotEmpty
                  ? null
                  : () => _selectDate(context, _dobController, isDob: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a Date of Birth';
                }
                // No need to check for future date here as showDatePicker's lastDate is DateTime.now()
                return null; // Valid
              },
            ),
            const SizedBox(height: 16),

            // Clinic Date Field
            TextFormField(
              controller: _observationDateController,
              decoration: const InputDecoration(
                labelText: 'Measurement Date',
                suffixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () => _selectDate(
                context,
                _observationDateController,
                isDob: false,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a Measurement Date';
                }
                if (_selectedDob == null) {
                  // This case should ideally be caught by the DOB validator, but is a safeguard
                  return 'Please select Date of Birth first';
                }
                // Clinic date cannot be before date of birth
                if (_selectedClinicDate != null &&
                    _selectedDob != null &&
                    _selectedClinicDate!.isBefore(_selectedDob!)) {
                  return 'Clinic Date cannot be before Date of Birth';
                }
                // Clinic date cannot be more than 20 years after date of birth
                if (_selectedClinicDate != null && _selectedDob != null) {
                  final ageAtClinic =
                      _selectedClinicDate!.difference(_selectedDob!).inDays /
                      365.25;
                  if (ageAtClinic > 20) {
                    return 'Child cannot be older than 20 years at clinic visit';
                  }
                }
                // No need to check for future date here as showDatePicker's lastDate is DateTime.now()

                return null; // Valid
              },
            ),
            const SizedBox(height: 16),

            // --- Start of New Gestation Section ---
            ExpansionTile(
              title: const Text('Add gestation if known'),
              onExpansionChanged: (bool expanded) {
                setState(() {
                  _showGestationFields = expanded;
                });
              },
              initiallyExpanded: _showGestationFields,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                  child: Column(
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
                          // Validation if this section is expanded
                          if (_showGestationFields && value == null) {
                            return 'Please select gestation weeks';
                          }
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
                          // Validation if this section is expanded
                          if (_showGestationFields && value == null) {
                            return 'Please select gestation days';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // --- End of New Gestation Section ---

            // Sex Radio Buttons
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

            Builder(
              // Use Builder to get a context that can find the Form ancestor
              builder: (BuildContext context) {
                return const SizedBox.shrink(); // Hide the error message when a Sex is selected or form not validated yet
              },
            ),
            const SizedBox(height: 8),
            // Spacing after Sex validation

            // Height Input Field
            TextFormField(
              controller: _heightController,
              enabled: _bmiController.text.isEmpty,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ), // Allow decimal input
              decoration: InputDecoration(
                labelText: 'Height (cm)',
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                // TODO MRB: validate up front (SDS validation as per Python package)
                if (value != null &&
                    value.isNotEmpty &&
                    double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null; // Valid
              },
            ),
            const SizedBox(height: 16),
            // Spacing after Height validation

            // Weight Input Field
            TextFormField(
              controller: _weightController,
              enabled: _bmiController.text.isEmpty,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ), // Allow decimal input
              decoration: InputDecoration(
                labelText: 'Weight (kg)',
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                // TODO MRB: validate up front (SDS validation as per Python package)
                if (value != null &&
                    value.isNotEmpty &&
                    double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null; // Valid
              },
            ),
            const SizedBox(height: 16),
            // Spacing after Weight validation

            ExpansionTile(
              title: const Text('Other measurement types'),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Head Circumference (ofc) Input Field
                      TextFormField(
                        controller: _ofcController,
                        enabled: _bmiController.text.isEmpty,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ), // Allow decimal input
                        decoration: InputDecoration(
                          labelText: 'Head Circumference (cm)',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          // TODO MRB: validate up front (SDS validation as per Python package)
                          if (value != null &&
                              value.isNotEmpty &&
                              double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null; // Valid
                        },
                      ),
                      const SizedBox(height: 16),
                      // Derived BMI if height and weight set otherwise
                      _heightController.text.isEmpty &&
                              _weightController.text.isEmpty &&
                              _ofcController.text.isEmpty
                          ? // BMI Input Field
                            TextFormField(
                              controller: _bmiController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                labelText: 'BMI (kg/m²)',
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) {
                                // TODO MRB: validate up front (SDS validation as per Python package)
                                if (value != null &&
                                    value.isNotEmpty &&
                                    double.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null; // Valid
                              },
                            )
                          : TextFormField(
                              controller: _derivedBmiController,
                              enabled: false,
                              decoration: InputDecoration(
                                labelText: 'BMI (kg/m²)',
                                helperText:
                                    _weightController.text.isEmpty ||
                                        _heightController.text.isEmpty
                                    ? 'Calculated automatically from weight and height'
                                    : '',
                                helperMaxLines: 2,
                                border: const OutlineInputBorder(),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: _canSubmit && !_loading ? _submitForm : null,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color?>((
                  Set<WidgetState> states,
                ) {
                  if (states.contains(WidgetState.disabled)) {
                    return Colors.grey; // Optional: custom disabled color
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
            const SizedBox(height: 12.0),
            // Reset Button
            ElevatedButton(
              onPressed: _hardResetForm,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color?>((
                  Set<WidgetState> states,
                ) {
                  if (states.contains(WidgetState.pressed)) {
                    return secondaryColour;
                  } else {
                    return primaryColour; // Use the component's default.
                  }
                }),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
              ),
              child: const Text('Reset', style: TextStyle(color: Colors.white)),
            ),
            // Conditionally visible button to navigate to ResultsPage
            if (appState
                .organizedGrowthData
                .isNotEmpty) // Check if there's data
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color?>((
                    Set<WidgetState> states,
                  ) {
                    if (states.contains(WidgetState.pressed)) {
                      return secondaryColour;
                    } else {
                      return primaryColour; // Use the component's default.
                    }
                  }),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ResultsPage()),
                  );
                },
                child: const Text(
                  'View Charts',
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class InputForm extends StatefulWidget {
  const InputForm({super.key});

  @override
  InputFormState createState() => InputFormState();
}
