import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/table.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Edit extends StatefulWidget {
  final Students student;
  const Edit({super.key, required this.student});

  @override
  State<Edit> createState() => _EditState();
}

class _EditState extends State<Edit> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;

  List<TextEditingController> skillControllers = [];
  List<Map<String, TextEditingController>> addresses = [];
  List<String> addressIds = [];
  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.student.FirstName);
    lastNameController = TextEditingController(text: widget.student.LastName);

    // Initialize address controllers with empty values

    getStudent();
  }

  Future<void> getStudent() async {
    final response = await http
        .get(Uri.parse('http://localhost:3000/students/${widget.student.id}'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      print('Received data: $json'); // Debug print
      setState(() {
        firstNameController.text = json['FirstName'];
        lastNameController.text = json['LastName'];
//addresses
        if (json['Adress'] != null && json['Adress'] is List) {
          addresses =
              json['Adress'].map<Map<String, TextEditingController>>((address) {
            return {
              'Country': TextEditingController(text: address['Country'] ?? ''),
              'City': TextEditingController(text: address['City'] ?? ''),
              'Street1': TextEditingController(text: address['Street1'] ?? ''),
              'Street2': TextEditingController(text: address['Street2'] ?? ''),
            };
          }).toList();
        }
        // Update skills if they exist
        if (json['Skills'] != null) {
          print('Skills: ${json['Skills']}'); // Debug print
          if (json['Skills'] is List) {
            skillControllers = json['Skills']
                .map<TextEditingController>(
                    (skill) => TextEditingController(text: skill['_id']))
                .toList();
          } else if (json['Skills'] is String) {
            skillControllers = [TextEditingController(text: json['Skills'])];
          }
        }
      });
    } else {
      throw Exception('Failed to load students');
    }
  }

  Future<void> updateStudent() async {
    try {
      Map<String, dynamic> updateData = {
        'FirstName': firstNameController.text,
        'LastName': lastNameController.text,
        'Skills':
            skillControllers.map((controller) => controller.text).toList(),
        'Adress': addresses
            .map((addr) => {
                  '_id': addr['_id']?.text, // Include _id if it exists
                  'Country': addr['Country']!.text,
                  'City': addr['City']!.text,
                  'Street1': addr['Street1']!.text,
                  'Street2': addr['Street2']!.text,
                })
            .toList(),
      };

      final response = await http.put(
        Uri.parse('http://localhost:3000/students/Edit/${widget.student.id}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        final updatedStudent = jsonDecode(response.body);
        print('Updated student: $updatedStudent');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Student updated successfully')),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Failed to update student: ${response.body}');
      }
    } catch (e) {
      print('Error updating student: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update student: $e')),
      );
    }
  }

  @override
  Widget buildAddressFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < addresses.length; i++)
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: addresses[i]['Country'],
                      decoration: InputDecoration(labelText: 'Country'),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: addresses[i]['City'],
                      decoration: InputDecoration(labelText: 'City'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: addresses[i]['Street1'],
                      decoration: InputDecoration(labelText: 'Street 1'),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: addresses[i]['Street2'],
                      decoration: InputDecoration(labelText: 'Street 2'),
                    ),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  Widget buildSkillsFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        for (int i = 0; i < skillControllers.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: TextField(
              controller: skillControllers[i],
              decoration: InputDecoration(
                labelText: 'Skill ${i + 1}',
                border: OutlineInputBorder(),
              ),
            ),
          )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Student'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                controller: lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
              ),
              SizedBox(height: 20),
              buildAddressFields(),
              SizedBox(height: 20),
              buildSkillsFields(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Add save logic here
                  updateStudent();
                },
                child: Text('Save'),
              ),
              // Display the result of the save operation if necessary
            ],
          ),
        ),
      ),
    );
  }
}
