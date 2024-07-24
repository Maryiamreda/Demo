import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class addStudent extends StatefulWidget {
  const addStudent({super.key});

  @override
  State<addStudent> createState() => _addStudentState();
}

class _addStudentState extends State<addStudent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add new Student'),
        ),
        body: const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Form(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    FilledButton(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                            backgroundColor: Colors.purple[200]),
                        child: const Text('Add'))
                  ],
                ))
              ],
            )));
  }
}
