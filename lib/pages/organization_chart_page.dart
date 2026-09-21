import 'package:flutter/material.dart';
import '../dummy_data/employee_dummy.dart';
import '../theme/app_colors.dart';

class OrganizationChartPage extends StatelessWidget{
  const OrganizationChartPage({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      appBar: AppBar(
        backgroundColor: AppColors.headerBackground,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bagan organisasi',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
      ),
    ),
actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textPrimary),
            onPressed: () {}, // Belum difungsikan sesuai instruksi
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: AppColors.textPrimary),
            onPressed: () {}, // Belum difungsikan sesuai instruksi
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              'Anda telah mencapai atas bagan',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),

            // Render Node Hirarki
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dummyOrgHierarchy.length,
              itemBuilder: (context, index) {
                final node = dummyOrgHierarchy[index];
                final isLast = index == dummyOrgHierarchy.length - 1;

                return Column(
                  children: [
                    // Avatar / Icon Node
                    _buildNodeAvatar(node),
                    const SizedBox(height: 8),

                    // Detail Teks Node
                    _buildNodeDetails(node),

                    // Garis Penghubung & Badge Angka
                    if (!isLast) _buildConnectorLine(node.childCount),
                  ],
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Widget Avatar dengan Bingkai Lingkaran Biru
  Widget _buildNodeAvatar(OrgNode node) {
    if (node.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.blue.shade600, width: 2),
        ),
        child: CircleAvatar(
          radius: 28,
          backgroundColor: Colors.blue.shade50,
          child: Icon(
            Icons.person_outline,
            size: 32,
            color: Colors.blue.shade600,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: node.isUser ? Colors.blue.shade700 : Colors.blue.shade600,
          width: 3,
        ),
      ),
      child: CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(node.photoUrl),
      ),
    );
  }

  // Widget Teks Informasi Karyawan
  Widget _buildNodeDetails(OrgNode node) {
    if (node.isEmpty) {
      return Text(
        node.name,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
      );
    }

    return Column(
      children: [
        Text(
          node.nik,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          node.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          node.position,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        Text(
          node.department,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // Widget Garis Penghubung Vertikal dan Badge Angka
  Widget _buildConnectorLine(int count) {
    return Column(
      children: [
        Container(
          width: 1,
          height: 24,
          color: Colors.grey.shade300,
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.blue.shade600,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          width: 1,
          height: 24,
          color: Colors.grey.shade300,
        ),
      ],
    );
  }
}