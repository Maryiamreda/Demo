import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/table.dart';
import 'package:http/http.dart' as http;

class Student {
  final String FirstName;
  final String LastName;
  List<String> Skills;
  Student(
      {required this.FirstName, required this.LastName, required this.Skills});

  factory Student.fromJson(Map<String, dynamic> json) {
    var skill = json['Skills'];

    List<String> skillsList = skill.cast<String>();
    return Student(
      FirstName: json['FirstName'],
      LastName: json['LastName'],
      Skills: skillsList,
    );
  }
}

class addStudent extends StatefulWidget {
  @override
  _addStudentState createState() => _addStudentState();
}

class _addStudentState extends State<addStudent> {
  final TextEditingController firstController = TextEditingController();
  final TextEditingController lastController = TextEditingController();
  final TextEditingController skillController = TextEditingController();
  final List<String> skills = [];

  String result = '';

  Future<void> create() async {
    try {
      final requestBody = {
        'FirstName': firstController.text,
        'LastName': lastController.text,
        'Skills': skills, // This should now correctly include the skills
      };
      print(
          'Request body: $requestBody'); // This will help you verify the data being sent

      final response = await http.post(
        Uri.parse('http://localhost:3000/students/Create'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody), // Use the requestBody here
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          result =
              'ID: ${responseData['_id']}\nFirstName: ${responseData['FirstName']}\nLastName: ${responseData['LastName']}\nSkills: ${responseData['Skills'].join(', ')}';
          skills.clear(); // Clear the skills list after successful creation
          skillController.clear(); // Clear the skill input field
        });

        // Navigate to the data table screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => dataTable()),
        );
      } else {
        // If the server returns an error response, throw an exception
        throw Exception('Failed to create student: ${response.body}');
      }
    } catch (e) {
      setState(() {
        result = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Create Student'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: firstController,
                decoration: InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                controller: lastController,
                decoration: InputDecoration(labelText: 'Last Name'),
              ),
              TextField(
                controller: skillController,
                decoration: InputDecoration(labelText: 'Skills'),
                onSubmitted: (value) {
                  setState(() {
                    skills.add(value);
                    skillController.clear();
                  });
                },
              ),
              Wrap(
                children:
                    skills.map((skill) => Chip(label: Text(skill))).toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  create();
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => dataTable()),
                  // );
                },
                child: Text('Create'),
              ),
              SizedBox(height: 20),
              Text(result),
            ],
          ),
        ),
      ),
    );
  }
}
