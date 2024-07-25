import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class addStudent extends StatefulWidget {
  @override
  _addStudentState createState() => _addStudentState();
}

class _addStudentState extends State<addStudent> {
  final TextEditingController firstController = TextEditingController();
  final TextEditingController lastController = TextEditingController();

  String result = '';

  Future<void> create() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/students/Create'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'FirstName': firstController.text,
          'LastName': lastController.text,
          // Add any other data you want to send in the body
        }),
      );

      if (response.statusCode == 200) {
        // Successful POST request, handle the response here
        final responseData = jsonDecode(response.body);
        setState(() {
          result =
              'ID: ${responseData['id']}\nFirstName: ${responseData['FirstName']}\nLastName: ${responseData['LastName']}';
        });
      } else {
        // If the server returns an error response, throw an exception
        throw Exception('Failed to post data');
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: create,
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
