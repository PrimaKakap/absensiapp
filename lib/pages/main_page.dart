import 'package:flutter/material.dart';
import 'employee_page.dart';
import '../widgets/custom_button_nav.dart';
import '../widgets/attendance_card.dart';
import '../theme/app_colors.dart';
import 'account_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0; // Default di Tab 'Karyawan'

  // Helper tampilan untuk Halaman Beranda
  Widget _buildHomePage() {
    return Column(
      children: [
        // Widget Header Absensi 
        const AttendanceCard(),

        // Area Konten Putih di bawahnya
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomePage(),
      const EmployeePage(),
      const Center(child: Text('Halaman Pengajuan')),
      const Center(child: Text('Halaman Inbox')),
      const AccountPage(),
    ];

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: pages[_currentIndex],
      ),
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