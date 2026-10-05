import 'package:employeepage/widgets/request_type_sheet.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'employee_page.dart';
import '../widgets/custom_button_nav.dart';
import '../widgets/attendance_card.dart';
import '../theme/app_colors.dart';
import 'account_page.dart';
import 'attendance_camera_page.dart';
import '../models/attendance_model.dart';
import '../services/api_service.dart';
import 'inbox_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0; // Default di Tab 'Beranda'

  // Variable menyimpan nama user & state absensi today
  String _userName = 'User';
  AttendanceModel? _todayAttendance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchTodayAttendance();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('fullName') ?? 'User';
    });
  }

  Future<void> _fetchTodayAttendance() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Ambil token tersimpan dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? prefs.getString('token') ?? '';

      if (token.isNotEmpty) {
        final data = await ApiService.getTodayAttendance(token);
        setState(() {
          _todayAttendance = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Gagal mengambil data absensi: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleClockIn() async {
    final String type = _todayAttendance?.clockInTime == null ? 'CLOCK_IN' : 'CLOCK_OUT';
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        // Perbaikan: tambahkan parameter attendanceType yang dibutuhkan
        builder: (context) => AttendanceCameraPage(attendanceType: type),
      ),
    );

    if (result == true) {
      await _fetchTodayAttendance();
    }
  }

  // Helper tampilan untuk Halaman Beranda
  Widget _buildHomePage() {
    return Column(
      children: [
        // Widget Header Absensi
        _isLoading
            ? const Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              )
            : AttendanceCard(
                userName: _userName, // 2. Teruskan _userName ke AttendanceCard
                attendanceData: _todayAttendance,
                onClockInPressed: _handleClockIn,
              ),

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
      const InboxPage(),
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
            if (index == 2) {
              RequestTypeSheet.show(context);
            } else {
              setState(() {
                _currentIndex = index;
              });
            }
          },
        ),
      ),
    );
  }
}