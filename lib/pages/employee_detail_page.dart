import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/employee.dart';
import '../widgets/action_button.dart';
import '../widgets/detail_info_row.dart';
import '../theme/app_colors.dart';

class EmployeeDetailPage extends StatelessWidget {
  final Employee employee;

  const EmployeeDetailPage({super.key, required this.employee});

  // 1. Helper Panggilan Telepon
  Future<void> _makePhoneCall(BuildContext context) async {
    final cleanPhone = employee.phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleanPhone.isEmpty) {
      _showSnackBar(context, 'Nomor telepon tidak tersedia');
      return;
    }

    final Uri url = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (context.mounted) {
        _showSnackBar(context, 'Tidak dapat membuka aplikasi Telepon');
      }
    }
  }

  // 2. Helper Kirim Email
  Future<void> _sendEmail(BuildContext context) async {
    final email = employee.email.trim();
    if (email.isEmpty || email == '-') {
      _showSnackBar(context, 'Alamat email tidak tersedia');
      return;
    }

    final Uri url = Uri.parse('mailto:$email');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (context.mounted) {
        _showSnackBar(context, 'Tidak dapat membuka aplikasi Email');
      }
    }
  }

  // 3. Helper Chat WhatsApp
  Future<void> _openWhatsApp(BuildContext context) async {
    var phone = employee.phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (phone.isEmpty) {
      _showSnackBar(context, 'Nomor WhatsApp tidak tersedia');
      return;
    }

    // Ubah format nomor 08xx menjadi format internasional 628xx
    if (phone.startsWith('0')) {
      phone = '62${phone.substring(1)}';
    }

    final Uri url = Uri.parse('https://wa.me/$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        _showSnackBar(context, 'Aplikasi WhatsApp tidak terinstall');
      }
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primaryRed,
      ),
    );
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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Tombol Telepon
                      ActionButton(
                        assetName: 'phone',
                        onTap: () => _makePhoneCall(context),
                      ),
                      const SizedBox(width: 16),
                      // Tombol Email
                      ActionButton(
                        assetName: 'mail',
                        onTap: () => _sendEmail(context),
                      ),
                      const SizedBox(width: 16),
                      // Tombol WhatsApp
                      ActionButton(
                        assetName: 'whatsapp',
                        onTap: () => _openWhatsApp(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),

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