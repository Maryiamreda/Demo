import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/table.dart';
import 'package:http/http.dart' as http;

class address {
  String Country;
  String City;
  String Street1;
  String Street2;

  address(
      {required this.Country,
      required this.City,
      required this.Street1,
      required this.Street2});

  factory address.fromJson(Map<String, dynamic> json) {
    return address(
      Country: json['Country'],
      City: json['City'],
      Street1: json['Street1'],
      Street2: json['Street2'],
    );
  }
  @override
  String toString() {
    return '{ ${this.Country}, ${this.City}, ${this.Street1}, ${this.Street2} }';
  }

  Map<String, dynamic> toJson() {
    return {
      'Country': Country,
      'City': City,
      'Street1': Street1,
      'Street2': Street2,
    };
  }
}

class Student {
  final String FirstName;
  final String LastName;
  List<address> Adress;
  List<String> Skills;
  Student(
      // ignore: non_constant_identifier_names
      {required this.FirstName,
      required this.LastName,
      required this.Skills,
      required this.Adress});

  factory Student.fromJson(Map<String, dynamic> json) {
    var skill = json['Skills'];

    List<String> skillsList = skill.cast<String>();
    List<address> _Address = [];
    if (json['Adress'] != null) {
      var AdressJson = json['Adress'] as List;
      _Address =
          AdressJson.map((tagJson) => address.fromJson(tagJson)).toList();
    }

    return Student(
      FirstName: json['FirstName'],
      LastName: json['LastName'],
      Skills: skillsList,
      Adress: _Address,
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
  final List<address> addresses = [];

  final List<TextEditingController> countryControllers = [
    TextEditingController()
  ];
  final List<TextEditingController> cityControllers = [TextEditingController()];
  final List<TextEditingController> street1Controllers = [
    TextEditingController()
  ];
  final List<TextEditingController> street2Controllers = [
    TextEditingController()
  ];

  void addAddressField() {
    setState(() {
      countryControllers.add(TextEditingController());
      cityControllers.add(TextEditingController());
      street1Controllers.add(TextEditingController());
      street2Controllers.add(TextEditingController());
    });
  }

  void addAddress() {
    setState(() {
      if (countryControllers.last.text.isNotEmpty &&
          cityControllers.last.text.isNotEmpty &&
          street1Controllers.last.text.isNotEmpty &&
          street2Controllers.last.text.isNotEmpty) {
        addresses.add(address(
          Country: countryControllers.last.text,
          City: cityControllers.last.text,
          Street1: street1Controllers.last.text,
          Street2: street2Controllers.last.text,
        ));

        // Add a new set of controllers for the next address
        addAddressField();
      }
    });
  }

  void addSkill() {
    setState(() {
      if (skillController.text.isNotEmpty) {
        print('Adding skill: ${skillController.text}');
        skills.add(skillController.text);
        print('Current skills list: $skills');
        skillController.clear();
      }
    });
  }

  String result = '';
  Future<void> create() async {
    addSkill();
    addAddress();
    try {
      final requestBody = {
        'FirstName': firstController.text,
        'LastName': lastController.text,
        'Skills': skills,
        'Address': addresses.map((addr) => addr.toJson()).toList(),
      };
      print('Request body: $requestBody');

      final response = await http.post(
        Uri.parse('http://localhost:3000/students/Create'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          result =
              'ID: ${responseData['_id']}\nFirstName: ${responseData['FirstName']}\nLastName: ${responseData['LastName']}\nSkills: ${responseData['Skills'].join(', ')}';
          skills.clear();
          skillController.clear();
          countryControllers.clear();
          cityControllers.clear();
          street1Controllers.clear();
          street2Controllers.clear();
          addresses.clear();
          // Re-initialize with one set of address controllers
          countryControllers.add(TextEditingController());
          cityControllers.add(TextEditingController());
          street1Controllers.add(TextEditingController());
          street2Controllers.add(TextEditingController());
        });

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => dataTable()),
        );
      } else {
        throw Exception('Failed to create student: ${response.body}');
      }
    } catch (e) {
      setState(() {
        result = 'Error: $e';
      });
    }
  }

  Widget buildAddressFields() {
    return Column(
      children: [
        for (int i = 0; i < countryControllers.length; i++)
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: countryControllers[i],
                      decoration: InputDecoration(labelText: 'Country'),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: cityControllers[i],
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
                      controller: street1Controllers[i],
                      decoration: InputDecoration(labelText: 'Street 1'),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: street2Controllers[i],
                      decoration: InputDecoration(labelText: 'Street 2'),
                    ),
                  ),
                ],
              ),
              // if (i < countryControllers.length - 1) SizedBox(height: 20),
            ],
          ),
      ],
    );
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
              buildAddressFields(),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  addAddress();
                  print('Address added');
                },
                child: Text('Add New Address'),
              ),
              // buildAddedAddresses(),
              SizedBox(height: 20),
              TextFormField(
                controller: skillController,
                decoration: InputDecoration(
                  labelText: 'Skills',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: addSkill,
                  ),
                ),
                onFieldSubmitted: (value) {
                  addSkill();
                },
              ),
              Wrap(
                spacing: 8.0,
                children: skills
                    .map((skill) => Chip(
                          label: Text(skill),
                          onDeleted: () {
                            setState(() {
                              skills.remove(skill);
                            });
                          },
                        ))
                    .toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  create();
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
