import 'package:flutter/material.dart';
import 'package:frontend/add_student.dart';
import 'package:frontend/edit-student.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Students {
  final String id;
  final String FirstName;
  final String LastName;

  Students({required this.id, required this.FirstName, required this.LastName});

  factory Students.fromJson(Map<String, dynamic> json) {
    return Students(
      id: json['_id'],
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
  List<Students> _students = [];

  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    data = Data(_students, context);
    getAll();
  }

  Future<void> getAll() async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/students'));
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      setState(() {
        _students = json.map((item) => Students.fromJson(item)).toList();
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

  void _filterStudents(String query) {
    setState(() {
      if (query.isEmpty) {
        data.updateData(_students);
      } else {
        List<Students> filteredStudents = _students
            .where((student) =>
                student.FirstName.toLowerCase().contains(query.toLowerCase()) ||
                student.LastName.toLowerCase().contains(query.toLowerCase()))
            .toList();
        data.updateData(filteredStudents);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
        backgroundColor: Colors.purple[200],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search ',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filterStudents,
            ),
          ),
          Expanded(
            child: PaginatedDataTable(
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
  List<Students> _student;
  BuildContext context;
  Data(this._student, this.context);

  void updateData(List<Students> newStudents) {
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Edit(student: _student[index]),
              ),
            );
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
