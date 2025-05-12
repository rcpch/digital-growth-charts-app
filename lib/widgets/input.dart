import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/digital_growth_charts_services.dart';
import '../classes/digital_growth_charts_api_response.dart';
import '../classes/digital_growth_charts_chart_coordinates_response.dart';
import '../definitions/enums.dart';
import './results.dart';

class InputForm extends StatefulWidget {
  const InputForm({Key? key}) : super(key: key);

  @override
  _InputFormState createState() => _InputFormState();
}

class _InputFormState extends State<InputForm> {
  // A GlobalKey to uniquely identify the Form widget
  final _formKey = GlobalKey<FormState>();

  final DigitalGrowthChartsService _digitalGrowthChartsService = DigitalGrowthChartsService();// API service
  List<GrowthDataResponse> _growthDataList = []; // list to store growth calculation API responses

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

  // Function to show the date picker and update the text field and state
  Future<void> _selectDate(BuildContext context,
      TextEditingController controller, {required bool isDob}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isDob ? DateTime(DateTime
          .now()
          .year - 1, DateTime
          .now()
          .month, DateTime
          .now()
          .day) : DateTime.now()),
      // Suggest a recent year for DOB, current for clinic date
      firstDate: DateTime(1900),
      // Adjust as needed
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
    _formKey.currentState?.reset(); // Resets the form fields (doesn't reset controllers or other state)
    _dobController.clear();
    _observationDateController.clear();
    _measurementController.clear();
    setState(() {
      _selectedDob = null;
      _selectedClinicDate = null;
      _selectedMeasurementMethod = MeasurementMethod.height;
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

        // store the response
        _growthDataList.add(apiResponse);

        // get the chart coordinates
        final DigitalGrowthChartsCentileLines chartData =
        await _digitalGrowthChartsService.getChartCoordinates(
          sex: selectedSex,
          measurementMethod: measurementMethod,
        );

        _resetForm();

        // If the API call is successful and returns a response, navigate to the results page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsPage(growthDataList: _growthDataList, chartData: chartData, sex: selectedSex, measurementMethod: measurementMethod),
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
              onPressed: _submitForm,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
