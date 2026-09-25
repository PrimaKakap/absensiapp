import 'package:flutter/material.dart';
// import 'pages/main_page.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/login_page.dart';
// import 'pages/attendance_camera_page.dart';
import 'pages/employee_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID, null');
  //cek status login 
  final prefs =await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Absensi Karyawan',
    theme: ThemeData(primarySwatch: Colors.blue),
    home: isLoggedIn ? const EmployeePage() : const LoginPage(),
    );
  }
}
