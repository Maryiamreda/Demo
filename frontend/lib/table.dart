import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Student {
  final String FirstName;
  final String LastName;
  // final String Address[];
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
    data = Data(_students);
    getAll();
  }

  Future<void> getAll() async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/students'));
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      setState(() {
        _students = json.map((item) => Student.fromJson(item)).toList();
        data.updateData(_students); // Update data in Data class
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
      data.updateData(_students); // Update data in Data class
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student'),
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
            ],
            source: data,
          ),
        ],
      ),
    );
  }
}

class Data extends DataTableSource {
  List<Student> _student;

  Data(this._student);

  void updateData(List<Student> newStudents) {
    _student = newStudents;
    notifyListeners();
  }

  @override
  DataRow? getRow(int index) {
    return DataRow(cells: [
      DataCell(Text(_student[index].FirstName)),
      DataCell(Text(_student[index].LastName)),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _student.length;

  @override
  int get selectedRowCount => 0;
}
