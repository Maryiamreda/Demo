import 'package:flutter/material.dart';
import 'package:frontend/add_student.dart';
import 'package:frontend/edit-student.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  Student({required this.FirstName, required this.LastName});

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      FirstName: json['FirstName'],
      LastName: json['LastName'],
    );
  }
}

class dataTable extends StatefulWidget {
  dataTable({super.key});

  @override
  State<dataTable> createState() => _dataTableState();
}

class _dataTableState extends State<dataTable> {
  late Data data;
  List<Student> _students = [];
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    data = Data(_students, context, _showEditDialog);
    getAll();
  }

  Future<void> getAll() async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/students'));
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      setState(() {
        _students = json.map((item) => Student.fromJson(item)).toList();
        data.updateData(_students);
      });
    } else {
      throw Exception('Failed to load students');
    }
  }

  void onsortColum(int columnIndex, bool ascending) {
    if (columnIndex == 0) {
      if (ascending) {
        _students.sort((a, b) => a.FirstName.compareTo(b.FirstName));
      } else {
        _students.sort((a, b) => b.FirstName.compareTo(a.FirstName));
      }
    } else if (columnIndex == 1) {
      if (ascending) {
        _students.sort((a, b) => a.LastName.compareTo(b.LastName));
      } else {
        _students.sort((a, b) => b.LastName.compareTo(a.LastName));
      }
    }

    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      data.updateData(_students);
    });
  }

  void _showEditDialog(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit'),
          content: Text('Edit ${student.FirstName} ${student.LastName}'),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student'),
        backgroundColor: Colors.purple[200],
      ),
      body: Column(
        children: [
          PaginatedDataTable(
            rowsPerPage: 5,
            columns: [
              DataColumn(
                label: Text(
                  'First Name',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onSort: (columnIndex, ascending) {
                  onsortColum(columnIndex, ascending);
                },
              ),
              DataColumn(
                label: Text(
                  'Last Name',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onSort: (columnIndex, ascending) {
                  onsortColum(columnIndex, ascending);
                },
              ),
              DataColumn(label: Text(' ')),
            ],
            source: data,
          ),
          FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => addStudent()),
                );
              },
              child: const Text(' + Add New Student'))
        ],
      ),
    );
  }
}

class Data extends DataTableSource {
  List<Student> _student;
  BuildContext context;
  Function(BuildContext, Student) onEdit;

  Data(this._student, this.context, this.onEdit);

  void updateData(List<Student> newStudents) {
    _student = newStudents;
    notifyListeners();
  }

  @override
  DataRow? getRow(int index) {
    return DataRow(cells: [
      DataCell(Text(_student[index].FirstName)),
      DataCell(Text(_student[index].LastName)),
      DataCell(
        TextButton(
          onPressed: () {
            onEdit(context, _student[index]);
          },
          child: Icon(Icons.edit),
        ),
      )
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _student.length;

  @override
  int get selectedRowCount => 0;
}
