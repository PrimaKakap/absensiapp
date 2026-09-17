import 'package:flutter/material.dart';
import 'employee_page.dart';
import '../widgets/custom_button_nav.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 1; // Default buka di Tab 'Karyawan' (Index 1)

  // Daftar halaman untuk tiap tab navigasi
  final List<Widget> _pages = [
    const Center(child: Text('Halaman Beranda')),
    const EmployeePage(),
    const Center(child: Text('Halaman Pengajuan')),
    const Center(child: Text('Halaman Inbox')),
    const Center(child: Text('Halaman Akun')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: SafeArea(
      child: CustomButtonNav(
      currentIndex: _currentIndex,
      onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    ),
  );
}
}