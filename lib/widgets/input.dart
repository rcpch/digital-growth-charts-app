import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting

// Enum to represent the different measurement types
enum MeasurementType { height, weight, headCircumference, bmi }
// Enum to represent Gender
enum Gender { male, female }

class InputForm extends StatefulWidget {
  const InputForm({Key? key}) : super(key: key);

  @override
  _InputFormState createState() => _InputFormState();
}

class _InputFormState extends State<InputForm> {
  // A GlobalKey to uniquely identify the Form widget
  final _formKey = GlobalKey<FormState>();

  // Controllers for the input fields
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _clinicDateController = TextEditingController();
  final TextEditingController _measurementController = TextEditingController();

  // Variables to hold the selected dates (stored as DateTime objects for comparisons)
  DateTime? _selectedDob;
  DateTime? _selectedClinicDate;

  // Variable to hold the selected measurement type
  MeasurementType _selectedMeasurementType = MeasurementType
      .height; // Default to Height

  // Variable to hold the selected Gender
  Gender? _selectedGender; // Gender is required, so nullable initially
  bool _formSubmitted = false;

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
    switch (_selectedMeasurementType) {
      case MeasurementType.height:
        return 'Enter height in cm';
      case MeasurementType.weight:
        return 'Enter weight in kg';
      case MeasurementType.headCircumference:
        return 'Enter head circumference in cm';
      case MeasurementType.bmi:
        return 'Enter BMI in kg/m²';
      default:
        return 'Enter measurement';
    }
  }

  // Function to handle the submit button press
  void _submitForm() {
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
      final String clinicDate = _clinicDateController.text;
      final String measurement = _measurementController.text;
      final MeasurementType selectedType = _selectedMeasurementType;
      final Gender? selectedGender = _selectedGender; // Access the selected gender

      // You can now process this data. For example, print it:
      print('Date of Birth: $dob');
      print('Clinic Date: $clinicDate');
      print('Gender: ${selectedGender?.name}'); // Print gender name
      print('Measurement Type: $selectedType');
      print('Measurement Value: $measurement');

      // You would typically perform more advanced processing here,
      // like calculating the child's age, plotting on growth charts, etc.

      // For demonstration, show a success message:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Form submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // You might clear the form or navigate to a new screen here.
      // _formKey.currentState?.reset(); // Resets the form fields (doesn't reset controllers or other state)
      // To clear everything, you would need to manually clear controllers and reset state variables:
      // _dobController.clear();
      // _clinicDateController.clear();
      // _measurementController.clear();
      // setState(() {
      //   _selectedDob = null;
      //   _selectedClinicDate = null;
      //   _selectedMeasurementType = MeasurementType.height;
      //   _selectedGender = null; // Reset gender selection
      // });
    } else {
      // If the form is invalid, show an error message (optional, as error text appears on fields)
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
    _clinicDateController.dispose();
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
              controller: _clinicDateController,
              decoration: const InputDecoration(
                labelText: 'Clinic Date',
                suffixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () =>
                  _selectDate(context, _clinicDateController, isDob: false),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a Clinic Date';
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

            // Gender Radio Buttons
            const Text('Select Gender:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              children: <Widget>[
                Expanded( // Use Expanded to make the RadioListTiles take up available space
                  child: RadioListTile<Gender>(
                    title: const Text('Male'),
                    value: Gender.male,
                    groupValue: _selectedGender,
                    // This variable holds the currently selected Gender
                    onChanged: (Gender? value) {
                      setState(() {
                        _selectedGender =
                            value; // Update the state with the selected gender
                      });
                    },
                  ),
                ),
                Expanded( // Use Expanded for the Female radio button as well
                  child: RadioListTile<Gender>(
                    title: const Text('Female'),
                    value: Gender.female,
                    groupValue: _selectedGender, // Use the same groupValue
                    onChanged: (Gender? value) {
                      setState(() {
                        _selectedGender = value; // Update the state
                      });
                    },
                  ),
                ),
              ],
            ),
            // Add a SizedBox for spacing below the radio buttons
            const SizedBox(height: 16),

            // You need a TextFormField or a custom widget to handle the validation display for gender
            // Since RadioListTile doesn't have a built-in validator text,
            // we can add a small helper widget or a Text below the Row.
            Builder( // Use Builder to get a context that can find the Form ancestor
              builder: (BuildContext context) {
                // We can't directly validate RadioListTile, so we check the _selectedGender state
                // and display an error message if needed.
                // This is a common workaround for widgets without a built-in validator.
                if (_selectedGender == null &&
                    _formSubmitted) {
                  // Only show error if validation has been triggered and gender is null
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Please select a gender',
                      style: TextStyle(color: Theme
                          .of(context)
                          .colorScheme
                          .error, fontSize: 12),
                    ),
                  );
                }
                return const SizedBox
                    .shrink(); // Hide the error message when a gender is selected or form not validated yet
              },
            ),
            const SizedBox(height: 16),
            // Spacing after gender validation

            // Measurement Type Radio Buttons
            const Text('Select Measurement Type:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              children: <Widget>[
                Expanded(
                  child: RadioListTile<MeasurementType>(
                    title: const Text('Height'),
                    value: MeasurementType.height,
                    groupValue: _selectedMeasurementType,
                    onChanged: (MeasurementType? value) {
                      setState(() {
                        _selectedMeasurementType = value!;
                        _measurementController
                            .clear(); // Clear input when type changes
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<MeasurementType>(
                    title: const Text('Weight'),
                    value: MeasurementType.weight,
                    groupValue: _selectedMeasurementType,
                    onChanged: (MeasurementType? value) {
                      setState(() {
                        _selectedMeasurementType = value!;
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
                  child: RadioListTile<MeasurementType>(
                    title: const Text('Head Circ.'),
                    value: MeasurementType.headCircumference,
                    groupValue: _selectedMeasurementType,
                    onChanged: (MeasurementType? value) {
                      setState(() {
                        _selectedMeasurementType = value!;
                        _measurementController
                            .clear(); // Clear input when type changes
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<MeasurementType>(
                    title: const Text('BMI'),
                    value: MeasurementType.bmi,
                    groupValue: _selectedMeasurementType,
                    onChanged: (MeasurementType? value) {
                      setState(() {
                        _selectedMeasurementType = value!;
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
                // You could add more specific validation here based on MeasurementType (e.g., check if it's a valid number, within a reasonable range)
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
