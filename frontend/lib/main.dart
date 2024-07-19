import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class Students {
  final String FirstName;
  final String LastName;
  // final String Adress[];
  Students({required this.FirstName, required this.LastName});

  factory Students.fromJson(Map<String, dynamic> json) {
    return Students(
      FirstName: json['FirstName'],
      LastName: json['LastName'],
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List<Students> _student = [];
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();
    getall();
  }

  Future<void> getall() async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/GetAllStudents'));
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      setState(() {
        _student = json.map((item) => Students.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load Students');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Students'),
      ),
      body: ListView.builder(
        itemCount: _student.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(_student[index].FirstName),
            subtitle: Text(_student[index].LastName),
          );
        },
      ),
    );
  }
}
