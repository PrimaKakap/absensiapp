import 'package:flutter/material.dart';
import 'pages/employee_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Employee page',
    theme: ThemeData(primarySwatch: Colors.blue),
    home: const EmployeePage(),
    );
  }
}
