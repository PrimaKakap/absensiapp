import 'package:employeepage/pages/employee_filter_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/employee.dart';
import '../services/api_service.dart';
import '../dummy_data/employee_dummy.dart'; 
import '../widgets/header.dart';
import '../widgets/unabsent_employee_card.dart';
import '../theme/app_colors.dart';
import 'employee_detail_page.dart';

class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  late Future<List<Employee>> _employeeFuture;
  List<Employee> _allEmployees = [];
  List<Employee> _filteredEmployees = [];
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
        _filteredEmployees = data;
      });
      return data;
    });
  }

  // 1. Filter (Search + Cabang + Posisi)
  void _applyFilter() {
    setState(() {
      _filteredEmployees = _allEmployees.where((emp) {
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
      _applyFilter(); // Panggil applyFilter agar UI langsung update!
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 1. Header & Search Bar
              EmployeeHeader(
                totalEmployees: _filteredEmployees.length,
                onSearchChanged: _filterEmployees,
                onFilterTap: _openFilterPage,
              ),

              const SizedBox(height: 16),

              // 2. Card Tidak Hadir
              AbsentEmployeesCard(absentList: dummyAbsentEmployees),

              const SizedBox(height: 16),

              // 3. Employee List dari API Backend
              Container(
                color: AppColors.cardBackground,
                child: FutureBuilder<List<Employee>>(
                  future: _employeeFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 3,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Memuat data karyawan...',
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

                    if (_filteredEmployees.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Center(
                          child: Text(
                            _searchQuery.isEmpty && _selectedBranches.isEmpty && _selectedPositions.isEmpty
                                ? 'Belum ada data karyawan.' 
                                : 'Data karyawan tidak ditemukan.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredEmployees.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final employee = _filteredEmployees[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(employee.photoUrl),
                          ),
                          title: Text(
                            employee.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${employee.position}\n${employee.organizations}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildSvgIcon('phone'),
                              const SizedBox(width: 12),
                              _buildSvgIcon('mail'),
                              const SizedBox(width: 12),
                              _buildSvgIcon('whatsapp'),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EmployeeDetailPage(employee: employee),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSvgIcon(String name) {
    return SvgPicture.asset(
      'assets/icons/$name.svg',
      width: 20,
      height: 20,
      colorFilter: const ColorFilter.mode(
        AppColors.iconInactive,
        BlendMode.srcIn,
      ),
    );
  }
}