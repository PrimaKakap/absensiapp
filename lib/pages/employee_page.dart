import 'package:employeepage/pages/employee_filter_page.dart';
import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../services/api_service.dart';
import '../widgets/header.dart';
import '../widgets/unabsent_employee_card.dart';
import '../widgets/present_employee_card.dart';
import '../theme/app_colors.dart';

class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  late Future<List<Employee>> _employeeFuture;

  List<Employee> _allEmployees = [];
  List<Employee> _presentEmployees = []; // Karyawan yang Hadir / Clock In / Clock Out
  List<Employee> _absentEmployees = [];  // Karyawan yang Tidak Hadir (ABSENT)
  List<Employee> _filteredPresentEmployees = []; // Hasil pencarian & filter dari karyawan hadir

  List<String> _selectedBranches = [];
  List<String> _selectedPositions = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    _employeeFuture = ApiService.fetchEmployees().then((data) {
      setState(() {
        _allEmployees = data;

        // Filter Karyawan HADIR (Mengecek clockInTime != null ATAU status bukan ABSENT)
        _presentEmployees = data.where((emp) {
          final st = emp.attendanceStatus.toUpperCase().trim();
          final hasClockIn = emp.clockInTime != null;
          
          final isNotAbsentStatus = st != 'ABSENT' && 
                                    st != 'NOT_PRESENT' && 
                                    st != '' && 
                                    st != 'NO DATA';

          return hasClockIn || isNotAbsentStatus;
        }).toList();

        // Filter Karyawan TIDAK HADIR
        _absentEmployees = data.where((emp) {
          return !_presentEmployees.contains(emp);
        }).toList();

        _applyFilter();
      });
      return data;
    });
  }

  // 1. Filter (Search + Cabang + Posisi) pada Karyawan yang Hadir
  void _applyFilter() {
    setState(() {
      _filteredPresentEmployees = _presentEmployees.where((emp) {
        // Filter Nama
        final matchesSearch = _searchQuery.isEmpty ||
            emp.name.toLowerCase().contains(_searchQuery.toLowerCase());

        // Filter Cabang
        final matchesBranch = _selectedBranches.isEmpty ||
            _selectedBranches.contains(emp.branch);

        // Filter Posisi / Organisasi
        final matchesPosition = _selectedPositions.isEmpty ||
            _selectedPositions.contains(emp.position);

        return matchesSearch && matchesBranch && matchesPosition;
      }).toList();
    });
  }

  // 2. Handler untuk Search Bar
  void _filterEmployees(String query) {
    _searchQuery = query;
    _applyFilter();
  }

  // 3. Handler untuk Membuka Laman Filter
  Future<void> _openFilterPage() async {
    final result = await Navigator.push<FilterResult>(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeFilterPage(
          allEmployees: _allEmployees,
          initialSelectedBranches: _selectedBranches,
          initialSelectedPositions: _selectedPositions,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedBranches = result.selectedBranches;
        _selectedPositions = result.selectedPositions;
      });
      _applyFilter();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _fetchData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header & Search Bar (Jumlah karyawan yang hadir)
                EmployeeHeader(
                  totalEmployees: _filteredPresentEmployees.length,
                  onSearchChanged: _filterEmployees,
                  onFilterTap: _openFilterPage,
                ),

                const SizedBox(height: 16),

                // 2. Card Karyawan Tidak Hadir Hari ini
                UnabsentEmployeeCard(absentList: _absentEmployees),

                const SizedBox(height: 16),

                // 3. Container Karyawan yang Sudah Clock In / Clock Out (DI SINI LETAKNYA)
                FutureBuilder<List<Employee>>(
                  future: _employeeFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.0),
                        child: Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 3,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Memuat data presensi karyawan...',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'Gagal terhubung ke backend:\n${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textError),
                          ),
                        ),
                      );
                    }

                    // Panggilan ke PresentEmployeesCard menggunakan presentList
                    return PresentEmployeesCard(
                      presentList: _filteredPresentEmployees,
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}