import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../models/account_profile.dart';
import 'login_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late Future<AccountProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() async {
    final activeId = await ApiService.getSavedEmployeeId();
    setState(() {
      _profileFuture = ApiService.fetchEmployeeDetail(activeId);
    });
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text(
          'Akun & Profil',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        centerTitle: false,
      ),
      body: FutureBuilder<AccountProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = snapshot.data;
          if (profile == null) {
            return const Center(child: Text('Gagal memuat profil karyawan.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. KARTU PROFIL KARYAWAN
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 32,
                        backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.fullName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${profile.positionName} • ${profile.employeeNumber}',
                              style: TextStyle( // DIHAPUS const
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                // MENGGUNAKAN withValues(alpha: ...) PENGGANTI withOpacity
                                color: AppColors.clockInBlue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                profile.employmentStatus,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.clockInBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. DETAILED INFORMATION SECTIONS
                Text( // DIHAPUS const
                  'Informasi Pekerjaan',
                  style: TextStyle( // DIHAPUS const
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),

                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      _buildInfoTile(
                        icon: Icons.business_rounded,
                        title: 'Perusahaan',
                        subtitle: profile.companyName,
                      ),
                      const Divider(height: 1),
                      _buildInfoTile(
                        icon: Icons.account_tree_rounded,
                        title: 'Departemen',
                        subtitle: profile.departmentName,
                      ),
                      const Divider(height: 1),
                      _buildInfoTile(
                        icon: Icons.location_on_rounded,
                        title: 'Cabang Kantor',
                        subtitle: profile.branchName,
                      ),
                      const Divider(height: 1),
                      _buildInfoTile(
                        icon: Icons.email_outlined,
                        title: 'Email Kantor',
                        subtitle: profile.companyEmail,
                      ),
                      const Divider(height: 1),
                      _buildInfoTile(
                        icon: Icons.phone_android_rounded,
                        title: 'Nomor Telepon',
                        subtitle: profile.phoneNumber,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 3. PENGATURAN AKUN SEDERHANA
                Text( // DIHAPUS const
                  'Pengaturan Akun',
                  style: TextStyle( // DIHAPUS const
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),

                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.lock_reset_rounded, color: AppColors.textPrimary),
                        title: const Text('Ubah Kata Sandi'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Fitur Ubah Password segera hadir.')),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.verified_user_outlined, color: AppColors.textPrimary),
                        title: const Text('NIK / No. KTP'),
                        subtitle: Text(profile.nationalIdNumber),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 4. TOMBOL LOGOUT
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.logout_rounded, color: Colors.white),
                    label: const Text(
                      'KELUAR AKUN',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.accentOrange),
      title: Text(
        title,
        style: TextStyle(fontSize: 12, color: AppColors.textSecondary), // DIHAPUS const
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}