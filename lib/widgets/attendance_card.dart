import 'package:employeepage/pages/attendance_camera_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';

class AttendanceCard extends StatelessWidget {
  const AttendanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: const BoxDecoration(
        // Background disesuaikan menjadi putih sesuai revisi desain
        color: AppColors.cardBackground,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Informasi User & Tanggal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Avatar Profil
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/150?img=12',
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Sapaan dan Nama Pengguna
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat datang,',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const Text(
                        'User',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Tanggal
              const Text(
                'Sel, 22 Sep 2026',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 2. Badge Shift
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.accentOrange, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: const BoxDecoration(
                      color: AppColors.accentOrange,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(6),
                        bottomLeft: Radius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Office',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: const Text(
                      '08.30 - 17.30',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Tombol Clock In & Clock Out
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.accentOrange, width: 1.5),
            ),
            child: Row(
              children: [
                // Action Clock In
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const AttendanceCameraPage(attendanceType: 'CLOCK_IN',),),);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/clock_in.svg',
                          height: 20,
                          width: 20,
                          colorFilter: const ColorFilter.mode(
                            AppColors.clockInBlue,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Clock In',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Pemisah Vertikal
                Container(
                  height: 24,
                  width: 1,
                  color: AppColors.accentOrange,
                ),
                // Action Clock Out
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const AttendanceCameraPage(attendanceType: 'CLOCK_OUT',),),);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/clock_out.svg',
                          height: 20,
                          width: 20,
                          colorFilter: const ColorFilter.mode(
                            AppColors.accentOrange,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Clock Out',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4. Keterangan Status Absensi
          Center(
            child: Text(
              'Anda telah berhasil clock in pada pukul 08.17',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}