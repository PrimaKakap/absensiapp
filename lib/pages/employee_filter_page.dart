import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../theme/app_colors.dart';

class FilterResult {
  final List<String> selectedBranches;
  final List<String> selectedPositions;

  FilterResult({
    required this.selectedBranches,
    required this.selectedPositions,
  });
}

class EmployeeFilterPage extends StatefulWidget {
  final List<Employee> allEmployees;
  final List<String> initialSelectedBranches;
  final List<String> initialSelectedPositions;

  const EmployeeFilterPage({
    super.key,
    required this.allEmployees,
    required this.initialSelectedBranches,
    required this.initialSelectedPositions,
  });

  @override
  State<EmployeeFilterPage> createState() => _EmployeeFilterPageState();
}

class _EmployeeFilterPageState extends State<EmployeeFilterPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late List<String> _branchOptions;
  late List<String> _positionOptions;

  late List<String> _selectedBranches;
  late List<String> _selectedPositions;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Ambil opsi unik secara dinamis dari daftar karyawan
    _branchOptions = widget.allEmployees
        .map((e) => e.branch)
        .where((b) => b.isNotEmpty)
        .toSet()
        .toList();

    _positionOptions = widget.allEmployees
        .map((e) => e.position)
        .where((p) => p.isNotEmpty)
        .toSet()
        .toList();

    _selectedBranches = List.from(widget.initialSelectedBranches);
    _selectedPositions = List.from(widget.initialSelectedPositions);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _resetAll() {
    setState(() {
      _selectedBranches.clear();
      _selectedPositions.clear();
    });
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
          'Filter berdasarkan',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue.shade700,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: Colors.blue.shade700,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Cabang'),
            Tab(text: 'Organisasi'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Filter Cabang
                _buildFilterList(
                  options: _branchOptions,
                  selectedList: _selectedBranches,
                ),
                // Tab 2: Filter Organisasi / Posisi
                _buildFilterList(
                  options: _positionOptions,
                  selectedList: _selectedPositions,
                ),
              ],
            ),
          ),

          // Action Buttons di Bagian Bawah
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        FilterResult(
                          selectedBranches: _selectedBranches,
                          selectedPositions: _selectedPositions,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Terapkan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _resetAll,
                  child: const Text(
                    'Atur ulang semua',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterList({
    required List<String> options,
    required List<String> selectedList,
  }) {
    final bool isAllSelected =
        options.isNotEmpty && selectedList.length == options.length;

    return Column(
      children: [
        // Header Jumlah Dipilih & Pilih Semua
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${selectedList.length} dipilih',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (isAllSelected) {
                      selectedList.clear();
                    } else {
                      selectedList.clear();
                      selectedList.addAll(options);
                    }
                  });
                },
                child: Text(
                  isAllSelected ? 'Batal pilih semua' : 'Pilih semua',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // List Opsi Checkbox
        Expanded(
          child: ListView.builder(
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              final isChecked = selectedList.contains(option);

              return CheckboxListTile(
                title: Text(
                  option,
                  style: const TextStyle(fontSize: 15),
                ),
                value: isChecked,
                activeColor: Colors.blue.shade700,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (bool? val) {
                  setState(() {
                    if (val == true) {
                      selectedList.add(option);
                    } else {
                      selectedList.remove(option);
                    }
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }
}