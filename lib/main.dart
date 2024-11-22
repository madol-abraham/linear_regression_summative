import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crop Yield Prediction',
      theme: ThemeData(
        primaryColor: Colors.green,
        hintColor: Colors.greenAccent,
        fontFamily: 'Roboto',
      ),
      home: CropYieldForm(),
    );
  }
}

class CropYieldForm extends StatefulWidget {
  @override
  _CropYieldFormState createState() => _CropYieldFormState();
}

class _CropYieldFormState extends State<CropYieldForm> {
  final _formKey = GlobalKey<FormState>();

  // State for dropdown values
  int? _selectedArea;
  int? _selectedItem;

  // Dropdown options mapped to integers
  final Map<int, String> _areaOptions = {
    1: 'Albania',
    2: 'Kenya',
    3: 'India',
    4: 'USA',
    5: 'Brazil',
    6: 'China',
    7: 'Nigeria',
  };

  final Map<int, String> _itemOptions = {
    1: 'Rice',
    2: 'Potatoes',
    3: 'Maize',
  };

  // Controllers for text fields
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _rainfallController = TextEditingController();
  final TextEditingController _pesticidesController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();

  // State for API response
  String? _predictionResult;
  bool _isLoading = false;

  // Submit form and make API call
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _predictionResult = null; // Clear previous result
      });

      // Prepare data for the API
      Map<String, dynamic> data = {
        'Area': _selectedArea,
        'Item': _selectedItem,
        'Year': int.parse(_yearController.text),
        'average_rain_fall_mm_per_year': double.parse(_rainfallController.text),
        'pesticides_tonnes': double.parse(_pesticidesController.text),
        'avg_temp': double.parse(_temperatureController.text),
      };

      try {
        // Make API call
        final response = await http.post(
          Uri.parse('https://summative-regression.onrender.com/predict'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data),
        );

        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);
          setState(() {
            _predictionResult = 'Predicted Yield: ${result['predicted_yield']} hg/ha';
          });
        } else {
          setState(() {
            _predictionResult = 'Error: ${response.reasonPhrase}';
          });
        }
      } catch (e) {
        setState(() {
          _predictionResult = 'Error: Failed to connect to the server.';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crop Yield Prediction'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Page Title
              Center(
                child: Text(
                  'Predict Crop Yield',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Area Dropdown
              _buildDropdownField(
                label: 'Area',
                value: _selectedArea,
                items: _areaOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedArea = value;
                  });
                },
              ),

              // Item Dropdown
              _buildDropdownField(
                label: 'Item',
                value: _selectedItem,
                items: _itemOptions,
                onChanged: (value) {
                  setState(() {
                    _selectedItem = value;
                  });
                },
              ),

              // Year Input
              _buildTextField(
                label: 'Year',
                controller: _yearController,
                hint: 'Enter year',
              ),

              // Average Rainfall Input
              _buildTextField(
                label: 'Average Rainfall (mm/year)',
                controller: _rainfallController,
                hint: 'Enter rainfall in mm',
              ),

              // Pesticides Used Input
              _buildTextField(
                label: 'Pesticides Used (tonnes)',
                controller: _pesticidesController,
                hint: 'Enter pesticides in tonnes',
              ),

              // Average Temperature Input
              _buildTextField(
                label: 'Average Temperature (°C)',
                controller: _temperatureController,
                hint: 'Enter temperature in °C',
              ),

              // Submit Button
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text('Predict Yield'),
              ),

              // Display Prediction Result
              if (_predictionResult != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Center(
                    child: Text(
                      _predictionResult!,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for building styled text fields
  Widget _buildTextField({required String label, required TextEditingController controller, required String hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: const Color.fromRGBO(238, 238, 238, 1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  // Helper method for building styled dropdown fields
  Widget _buildDropdownField({
    required String label,
    required int? value,
    required Map<int, String> items,
    required ValueChanged<int?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<int>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color.fromRGBO(238, 238, 238, 1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        items: items.entries
            .map((entry) => DropdownMenuItem<int>(
                  value: entry.key,
                  child: Text(entry.value),
                ))
            .toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Please select $label' : null,
      ),
    );
  }
}
