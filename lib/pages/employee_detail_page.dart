import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../widgets/action_button.dart';
import '../widgets/detail_info_row.dart';

class EmployeeDetailPage extends StatelessWidget {
  final Employee employee;

  const EmployeeDetailPage({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    // Definisi warna krem untuk bagian profil atas
    const headerColor = Color.fromARGB(255, 255, 251, 242);

    return Scaffold(
      backgroundColor: Colors.white, // Ubah Scaffold jadi putih murni
      appBar: AppBar(
        backgroundColor: headerColor, // Menyesuaikan warna AppBar dengan header
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Bagian Header Profil (Berwarna Krem)
            Container(
              color: headerColor,
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
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    employee.position,
                    maxLines: 2,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
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