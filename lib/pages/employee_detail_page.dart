import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../widgets/action_button.dart';
import '../widgets/detail_info_row.dart';
import '../theme/app_colors.dart'; // Impor konstanta warna

class EmployeeDetailPage extends StatelessWidget {
  final Employee employee;

  const EmployeeDetailPage({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground, // Latar belakang utama putih
      appBar: AppBar(
        backgroundColor: AppColors.headerBackground, // Warna krem header
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Bagian Header Profil (Berwarna Krem)
            Container(
              color: AppColors.headerBackground,
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 24, top: 10),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(employee.photoUrl),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    employee.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    employee.position,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14, 
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ActionButton(assetName: 'phone', onTap: () {}),
                      const SizedBox(width: 16),
                      ActionButton(assetName: 'mail', onTap: () {}),
                      const SizedBox(width: 16),
                      ActionButton(assetName: 'whatsapp', onTap: () {}),
                    ],
                  ),
                ],
              ),
            ),

            // 2. Bagian Detail Informasi 
            DetailInfoRow(label: 'Cabang', value: employee.branch),
            DetailInfoRow(label: 'Email', value: employee.email),
            DetailInfoRow(label: 'Handphone', value: employee.phone),
            DetailInfoRow(label: 'Posisi pekerjaan', value: employee.position),
            DetailInfoRow(label: 'Nama Organisasi', value: employee.organizations),
            DetailInfoRow(label: 'Tanggal bergabung', value: employee.joinDate),
            DetailInfoRow(label: 'Tanggal Lahir', value: employee.birthDate),
          ],
        ),
      ),
    );
  }
}