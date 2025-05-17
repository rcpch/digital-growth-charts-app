import 'package:digital_growth_charts_app/themes/colours.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/digital_growth_charts_services.dart';
import '../classes/digital_growth_charts_api_response.dart';
import '../classes/digital_growth_charts_chart_coordinates_response.dart';
import '../definitions/enums.dart';
import './results.dart';
import '../services/centile_chart_data_utils.dart';

class _InputFormState extends State<InputForm> {
  // A GlobalKey to uniquely identify the Form widget
  final _formKey = GlobalKey<FormState>();
  bool _canSubmit = false;

  final DigitalGrowthChartsService _digitalGrowthChartsService = DigitalGrowthChartsService();// API service
  Map<MeasurementMethod, List<GrowthDataResponse>> _organizedGrowthData = {};
  OrganizedCentileLines _organizedCentileLines = {
    Sex.male: {},
    Sex.female: {},
  };

  // State variables to store the fixed demographic data after the first submission
  DateTime? _fixedDob;
  Sex? _fixedSex;
  int? _fixedGestationWeeks;
  int? _fixedGestationDays;

  // Controllers for the input fields
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _observationDateController = TextEditingController();
  final TextEditingController _measurementController = TextEditingController();

  // Variables to hold the selected dates (stored as DateTime objects for comparisons)
  DateTime? _selectedDob;
  DateTime? _selectedClinicDate;

  // Variable to hold the selected measurement type
  MeasurementMethod _selectedMeasurementMethod = MeasurementMethod
      .height; // Default to Height

  // Variable to hold the selected Sex
  Sex _selectedSex = Sex.male; // Default to Male
  bool _formSubmitted = false;

  // State variables for the collapsable gestation section
  bool _showGestationFields = false;
  int _selectedGestationWeeks = 40; // Default to 40 weeks
  int _selectedGestationDays = 0;   // Default to 0 days

  void _checkFormValidity() {
    // Validate the form and update the _canSubmit state
    // The null check for currentState is important if the form might not be built yet.
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      if (!_canSubmit) {
        setState(() {
          _canSubmit = true;
        });
      }
    } else {
      if (_canSubmit) {
        setState(() {
          _canSubmit = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Check if fixed data exists (meaning we are returning from a submission)
    if (_fixedDob != null) {
      // Populate the Date of Birth field and state
      _dobController.text = DateFormat('yyyy-MM-dd').format(_fixedDob!);
      _selectedDob = _fixedDob;
    }
    if (_fixedSex != null) {
      // Populate the Sex selection
      _selectedSex = _fixedSex!;
    }
    if (_fixedGestationWeeks != null) {
      // Populate Gestation fields and state
      _selectedGestationWeeks = _fixedGestationWeeks!;
      _selectedGestationDays = _fixedGestationDays!;
      _showGestationFields = true; // Expand gestation section if data exists
    }
  }

  // Function to show the date picker and update the text field and state
  Future<void> _selectDate(BuildContext context,
      TextEditingController controller, {required bool isDob}) async {
        final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (
          isDob ? (_selectedDob ?? // Use selected DOB if available
        DateTime(DateTime.now().year - 1, DateTime.now().month, DateTime.now().day)) // Otherwise suggest a recent year
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

  // Function to get the hint text for the measurement input based on the selected type
  String _getMeasurementHintText() {
    switch (_selectedMeasurementMethod) {
      case MeasurementMethod.height:
        return 'Enter height in cm';
      case MeasurementMethod.weight:
        return 'Enter weight in kg';
      case MeasurementMethod.ofc:
        return 'Enter head circumference in cm';
      case MeasurementMethod.bmi:
        return 'Enter BMI in kg/m²';
      default:
        return 'Enter measurement';
    }
  }

  void _resetForm() {
    _observationDateController.clear();
    _measurementController.clear();

    setState(() {
      _selectedClinicDate = null;
      _selectedMeasurementMethod = MeasurementMethod.height;
      _formSubmitted = false;
    });
  }

  void _hardResetForm() {
    _observationDateController.clear();
    _measurementController.clear();
    _dobController.clear();
    _selectedClinicDate = null;
    _selectedDob = null;
    _selectedMeasurementMethod = MeasurementMethod.height;
    _selectedSex = Sex.male;
    _formSubmitted = false;
    setState(() {
      _selectedClinicDate = null;
      _selectedMeasurementMethod = MeasurementMethod.height;
      _formSubmitted = false;
      _organizedGrowthData = {};
      _organizedCentileLines = {
        Sex.male: {},
        Sex.female: {},
      };
    });
  }

  // Function to handle the submit button press
  void _submitForm() async {
    setState(() {
      _formSubmitted = true;
    });
    // Validate the form using the _formKey
    if (_formKey.currentState!.validate()) {
      // If the form is valid, process the data
      _formKey.currentState!
          .save(); // Save the form fields (not strictly necessary for TextFormFields with controllers, but good practice)

      // Access the entered values:
      final String dob = _dobController.text;
      final String clinicDate = _observationDateController.text;
      final String observationValue = _measurementController.text;
      final MeasurementMethod measurementMethod = _selectedMeasurementMethod;
      final Sex selectedSex = _selectedSex;
      // Access gestation values
      final int gestationWeeks = _selectedGestationWeeks;
      final int gestationDays = _selectedGestationDays;

      if (_organizedGrowthData.isNotEmpty) {
        // If there's existing data, check if the current demographics match the fixed ones
        if (_selectedDob != _fixedDob ||
            _selectedSex != _fixedSex ||
            _selectedGestationWeeks != _fixedGestationWeeks ||
            _selectedGestationDays != _fixedGestationDays) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Date of Birth, Sex, and Gestation must remain the same for the same child.'),
              backgroundColor: Colors.redAccent,
            ),
          );
          return; // Stop the submission process
        }
      } else {
        // This is the first submission, so store the demographics as fixed
        _fixedDob = _selectedDob;
        _fixedSex = _selectedSex;
        _fixedGestationWeeks = _selectedGestationWeeks;
        _fixedGestationDays = _selectedGestationDays;
      }

      // Show a loading indicator (optional, but good for user experience)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Submitting data...'),
          backgroundColor: Colors.blueAccent,
          duration: Duration(seconds: 2), // Keep it brief
        ),
      );

      try {
        // Call the API service method
        final GrowthDataResponse apiResponse =
            await _digitalGrowthChartsService.submitGrowthData(
          birthDate: dob,
          observationDate: clinicDate,
          sex: selectedSex,
          measurementMethod: measurementMethod,
          observationValue: observationValue,
              gestationWeeks: gestationWeeks,
          gestationDays: gestationDays,
        );

        //  add the response to a map of lists based on measurement method
        setState(() {
          _organizedGrowthData.update(
            measurementMethod,
                (list) => list..add(apiResponse),
            ifAbsent: () => [apiResponse],
          );
        });

        // Determine if centile data for this sex and measurement method is already cached
        final bool isCentileDataCached =
            _organizedCentileLines[selectedSex]?.containsKey(measurementMethod) ?? false;

        DigitalGrowthChartsCentileLines? chartDataResponse;

        if (!isCentileDataCached) {
          // If centile data is not cached, fetch it
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fetching chart data...'),
              backgroundColor: Colors.orangeAccent,
              duration: Duration(seconds: 2),
            ),
          );
          chartDataResponse =
          await _digitalGrowthChartsService.getChartCoordinates(
            sex: selectedSex,
            measurementMethod: measurementMethod,
          );

          // Process and merge the new centile data into the organized map
          if (chartDataResponse.centileData != null) {
            setState(() {
              final newOrganizedData = organizeCentileLines(chartDataResponse!);
              // Merge new data. Prioritize new data for the same sex and measurement method
              if (newOrganizedData[selectedSex]?.containsKey(measurementMethod) ?? false) {
                _organizedCentileLines[selectedSex]![measurementMethod] = newOrganizedData[selectedSex]![measurementMethod]!;
              }
            });
          }
        }

        _resetForm();

        // If the API call is successful and returns a response, navigate to the results page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsPage(
              organizedGrowthData: _organizedGrowthData,
              organizedCentileLines: _organizedCentileLines,
              sex: _fixedSex!,
              dob: _fixedDob!,
              gestationWeeks: _fixedGestationWeeks,
              gestationDays: _fixedGestationDays,
              measurementMethod: _selectedMeasurementMethod,
            ),
          ),
        );

      } catch (e) {
        // Handle API call errors
        print('Error during API submission: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit data: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
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
    _measurementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form( // Wrap your form content in a Form widget
      key: _formKey, // Assign the GlobalKey
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (){
        setState(() {
          _canSubmit = _formKey.currentState?.validate() ?? false;
        });
        _checkFormValidity();
      },
      child: SingleChildScrollView( // Add SingleChildScrollView to prevent overflow on smaller screens
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Date of Birth Field
            TextFormField(
              controller: _dobController,
              decoration: const InputDecoration(
                labelText: 'Date of Birth',
                suffixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () => _selectDate(context, _dobController, isDob: true),
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
              onTap: () =>
                  _selectDate(context, _observationDateController, isDob: false),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a Measurement Date';
                }
                if (_selectedDob == null) {
                  // This case should ideally be caught by the DOB validator, but is a safeguard
                  return 'Please select Date of Birth first';
                }
                // Clinic date cannot be before date of birth
                if (_selectedClinicDate != null && _selectedDob != null &&
                    _selectedClinicDate!.isBefore(_selectedDob!)) {
                  return 'Clinic Date cannot be before Date of Birth';
                }
                // Clinic date cannot be more than 20 years after date of birth
                if (_selectedClinicDate != null && _selectedDob != null) {
                  final ageAtClinic = _selectedClinicDate!.difference(
                      _selectedDob!).inDays / 365.25;
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
              title: const Text('Add Gestation if Known'),
              onExpansionChanged: (bool expanded) {
                setState(() {
                  _showGestationFields = expanded;
                });
              },
              initiallyExpanded: _showGestationFields,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Gestation Weeks:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                        value: _selectedGestationWeeks,
                        items: List.generate(19, (index) => index + 24) // Weeks 24 to 42
                            .map((int weeks) {
                          return DropdownMenuItem<int>(
                            value: weeks,
                            child: Text('$weeks'),
                          );
                        }).toList(),
                        onChanged: (int? newValue) {
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
                      const Text('Gestation Days:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                        value: _selectedGestationDays,
                        items: List.generate(7, (index) => index) // Days 0 to 6
                            .map((int days) {
                          return DropdownMenuItem<int>(
                            value: days,
                            child: Text('$days'),
                          );
                        }).toList(),
                        onChanged: (int? newValue) {
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
            const SizedBox(height: 16),
            // --- End of New Gestation Section ---

            // Sex Radio Buttons
            const Text('Select Sex:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              children: <Widget>[
                Expanded( // Use Expanded to make the RadioListTiles take up available space
                  child: RadioListTile<Sex>(
                    title: const Text('Male'),
                    value: Sex.male,
                    groupValue: _selectedSex,
                    // This variable holds the currently selected Sex
                    onChanged: (Sex? value) {
                      setState(() {
                        _selectedSex =
                            value!; // Update the state with the selected Sex
                      });
                    },
                  ),
                ),
                Expanded( // Use Expanded for the Female radio button as well
                  child: RadioListTile<Sex>(
                    title: const Text('Female'),
                    value: Sex.female,
                    groupValue: _selectedSex, // Use the same groupValue
                    onChanged: (Sex? value) {
                      setState(() {
                        _selectedSex = value!; // Update the state
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Builder( // Use Builder to get a context that can find the Form ancestor
              builder: (BuildContext context) {
                if (_selectedSex == null &&
                    _formSubmitted) {
                  // Only show error if validation has been triggered and Sex is null
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Please select a Sex',
                      style: TextStyle(color: Theme
                          .of(context)
                          .colorScheme
                          .error, fontSize: 12),
                    ),
                  );
                }
                return const SizedBox
                    .shrink(); // Hide the error message when a Sex is selected or form not validated yet
              },
            ),
            const SizedBox(height: 16),
            // Spacing after Sex validation

            // Measurement Type Radio Buttons
            const Text('Select Measurement Type:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              children: <Widget>[
                Expanded(
                  child: RadioListTile<MeasurementMethod>(
                    title: const Text('Height'),
                    value: MeasurementMethod.height,
                    groupValue: _selectedMeasurementMethod,
                    onChanged: (MeasurementMethod? value) {
                      setState(() {
                        _selectedMeasurementMethod = value!;
                        _measurementController
                            .clear(); // Clear input when type changes
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<MeasurementMethod>(
                    title: const Text('Weight'),
                    value: MeasurementMethod.weight,
                    groupValue: _selectedMeasurementMethod,
                    onChanged: (MeasurementMethod? value) {
                      setState(() {
                        _selectedMeasurementMethod = value!;
                        _measurementController
                            .clear(); // Clear input when type changes
                      });
                    },
                  ),
                ),
              ],
            ),
            Row( // New row for the remaining radio buttons
              children: <Widget>[
                Expanded(
                  child: RadioListTile<MeasurementMethod>(
                    title: const Text('Head Circ.'),
                    value: MeasurementMethod.ofc,
                    groupValue: _selectedMeasurementMethod,
                    onChanged: (MeasurementMethod? value) {
                      setState(() {
                        _selectedMeasurementMethod = value!;
                        _measurementController
                            .clear(); // Clear input when type changes
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<MeasurementMethod>(
                    title: const Text('BMI'),
                    value: MeasurementMethod.bmi,
                    groupValue: _selectedMeasurementMethod,
                    onChanged: (MeasurementMethod? value) {
                      setState(() {
                        _selectedMeasurementMethod = value!;
                        _measurementController
                            .clear(); // Clear input when type changes
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Measurement Input Field (Hint changes based on selection)
            TextFormField(
              controller: _measurementController,
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true), // Allow decimal input
              decoration: InputDecoration(
                labelText: 'Measurement',
                hintText: _getMeasurementHintText(), // Dynamic hint text
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a measurement value';
                }
                // You could add more specific validation here based on MeasurementMethod (e.g., check if it's a valid number, within a reasonable range)
                // Example: check if it's a number
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null; // Valid
              },
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: _canSubmit ? _submitForm : null,
              child: const Text('Submit', style: TextStyle(color: Colors.white)),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
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
                )),
            ),
            // Reset Button
            ElevatedButton(
              onPressed: _hardResetForm,
              child: const Text('Reset', style: TextStyle(color: Colors.white),),
              style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                          (Set<WidgetState> states) {
                        if (states.contains(WidgetState.pressed)) {
                          return secondaryColour;
                        } else {
                          return primaryColour; // Use the component's default.
                        }}),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  )),
            ),
          // Conditionally visible button to navigate to ResultsPage
          if (_organizedGrowthData.isNotEmpty) // Check if there's data
            ElevatedButton(
              child: const Text('View Charts', style: TextStyle(color: Colors.white)),
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                            (Set<WidgetState> states) {
                          if (states.contains(WidgetState.pressed)) {
                            return secondaryColour;
                          } else {
                            return primaryColour; // Use the component's default.
                          }}),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    )),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ResultsPage(
                            organizedGrowthData: _organizedGrowthData,
                            organizedCentileLines: _organizedCentileLines,
                            sex: _fixedSex!,
                            // Make sure these are not null if data exists
                            dob: _fixedDob!,
                            gestationWeeks: _fixedGestationWeeks,
                            gestationDays: _fixedGestationDays,
                            // You might need to decide which measurement method to show by default
                            measurementMethod: _organizedGrowthData.keys
                                .first, // Example: show the first available method
                          ),
                    )
                );
              })
          ],
        ),
      ),
    );
  }
}

class InputForm extends StatefulWidget {
  const InputForm({Key? key}) : super(key: key);

  @override
  _InputFormState createState() => _InputFormState();
}
