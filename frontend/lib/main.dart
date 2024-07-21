import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class Student {
  final String FirstName;
  final String LastName;
  // final String Adress[];
  Student({required this.FirstName, required this.LastName});

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
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
  List<Student> _student = [];
  bool sort = true;
  late bool ascending;
  @override
  void initState() {
    super.initState();
    getall();
    ascending = false;
  }

  Future<void> getall() async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/students'));
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      setState(() {
        _student = json.map((item) => Student.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load Students');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: DataTable(
      // sortColumnIndex: 0,
      // sortAscending: ascending,
      columns: const <DataColumn>[
        DataColumn(
          label: Expanded(
            child: Text(
              'First Name',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Text(
              'Last Name',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
      rows: List.generate(_student.length, (index) {
        return DataRow(cells: [
          DataCell(Text(_student[index].FirstName)),
          DataCell(Text(_student[index].LastName)),
        ]);
      }),
    ));
  }

  // void onSortColumn({required int columnIndex, required bool ascending}) {
  //   if (columnIndex == 0) {
  //     setState(() {
  //       if (ascending) {
  //         _student.sort((a, b) => a.FirstName.compareTo(b.FirstName));
  //       } else {
  //         _student.sort((a, b) => b.FirstName.compareTo(a.FirstName));
  //       }
  //       this.ascending = ascending;
  //     });
  //   }
  // }
}
