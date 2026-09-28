import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import 'login_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus session login lokal

    if (!context.mounted) return;

    // Pindah kembali ke LoginPage dan hapus semua tumpukan navigasi
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
        title: const Text('Akun Saya'),
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dummy Profil Sederhana
            Card(
              color: AppColors.cardBackground,
              child: const ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
                ),
                title: Text('John Doe', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('e29bb03b-825d-41cb-a6c3-493d63b1cb00'),
              ),
            ),
            const Spacer(),
            
            // Tombol Logout
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _handleLogout(context),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('LOGOUT / KELUAR', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}