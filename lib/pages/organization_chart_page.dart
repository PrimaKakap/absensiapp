import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class OrganizationChartPage extends StatefulWidget {
  const OrganizationChartPage({super.key});

  @override
  State<OrganizationChartPage> createState() => _OrganizationChartPageState();
}

class _OrganizationChartPageState extends State<OrganizationChartPage> {
  bool _isLoading = true;
  String? _errorMessage;

  String _personInCharge = 'Pimpinan Cabang';
  String _branchName = 'Cabang Perusahaan';
  List<Employee> _teamMembers = [];

  @override
  void initState() {
    super.initState();
    _fetchOrganizationData();
  }

  Future<void> _fetchOrganizationData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Fetch data Karyawan & Cabang secara paralel
      final employees = await ApiService.fetchEmployees();
      final branches = await ApiService.fetchBranches();

      // 2. Ambil detail profil user aktif untuk mencocokkan cabang tempatnya bekerja
      final activeEmployeeId = await ApiService.getSavedEmployeeId();
      final userProfile = await ApiService.fetchEmployeeDetail(activeEmployeeId);

      // 3. Cari cabang yang sesuai dengan cabang user
      final userBranch = branches.firstWhere(
        (b) => b['branchName'].toString().trim().toLowerCase() ==
            userProfile.branchName.trim().toLowerCase(),
        orElse: () => branches.isNotEmpty ? branches.first : {},
      );

      _branchName = userBranch['branchName'] ?? userProfile.branchName;
      _personInCharge = userBranch['personInCharge'] ?? 'Person in Charge';

      // 4. Filter anggota tim/karyawan yang berada di cabang tersebut
      _teamMembers = employees.where((emp) {
        return emp.branch.trim().toLowerCase() == _branchName.trim().toLowerCase();
      }).toList();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.headerBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bagan Organisasi',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accentOrange),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchOrganizationData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentOrange,
                          ),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        'Puncak Hirarki Organisasi Cabang',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 1. NODE ATASAN (Person In Charge Cabang)
                      _buildPiconNode(
                        name: _personInCharge,
                        position: 'Person In Charge (PIC)',
                        branch: _branchName,
                      ),

                      // Garis Penghubung ke Tim
                      if (_teamMembers.isNotEmpty) ...[
                        _buildConnectorLine(_teamMembers.length),

                        // 2. NODE DAFTAR ANGGOTA TIM / KARYAWAN
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _teamMembers.length,
                          itemBuilder: (context, index) {
                            final emp = _teamMembers[index];
                            final isLast = index == _teamMembers.length - 1;

                            return Column(
                              children: [
                                _buildEmployeeNode(emp),
                                if (!isLast) _buildSmallConnector(),
                              ],
                            );
                          },
                        ),
                      ] else ...[
                        const SizedBox(height: 30),
                        const Text(
                          'Belum ada anggota tim lain di cabang ini',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
    );
  }

  // Node untuk Pimpinan / PIC Cabang
  Widget _buildPiconNode({
    required String name,
    required String position,
    required String branch,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.accentOrange, width: 3),
          ),
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.orange.shade50,
            child: const Icon(
              Icons.stars_rounded,
              size: 36,
              color: AppColors.accentOrange,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          position,
          style: const TextStyle(
            color: AppColors.accentOrange,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          branch,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // Node untuk Karyawan Tim
  Widget _buildEmployeeNode(Employee employee) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blue.shade600, width: 2),
          ),
          child: CircleAvatar(
            radius: 26,
            backgroundImage: NetworkImage(employee.photoUrl),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          employee.id,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          employee.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          employee.position,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        Text(
          employee.organizations,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // Garis Penghubung Utama dengan Badge Jumlah Tim
  Widget _buildConnectorLine(int count) {
    return Column(
      children: [
        Container(
          width: 1.5,
          height: 20,
          color: Colors.grey.shade300,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.accentOrange,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count Tim',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          width: 1.5,
          height: 20,
          color: Colors.grey.shade300,
        ),
      ],
    );
  }

  // Garis Penghubung Kecil Antar Karyawan
  Widget _buildSmallConnector() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: 1.5,
      height: 16,
      color: Colors.grey.shade300,
    );
  }
}