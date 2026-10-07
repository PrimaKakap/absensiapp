import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../models/attendance_model.dart';

class AttendanceCard extends StatelessWidget {
  final AttendanceModel? attendanceData;
  final VoidCallback onClockInPressed;
  final VoidCallback onClockOutPressed; // Handler khusus Clock Out
  final String userName;

  const AttendanceCard({
    super.key,
    this.attendanceData,
    required this.onClockInPressed,
    required this.onClockOutPressed,
    this.userName = 'User',
  });

  @override
  Widget build(BuildContext context) {
    final String todayFormatted = DateFormat('EEE, d MMM yyyy', 'id_ID').format(DateTime.now());

    final bool isClockedIn = attendanceData?.clockInTime != null;
    final bool isClockedOut = attendanceData?.clockOutTime != null;

    final String clockInTimeStr = isClockedIn
        ? DateFormat('HH.mm').format(attendanceData!.clockInTime)
        : '--.--';
    final String clockOutTimeStr = isClockedOut
        ? DateFormat('HH.mm').format(attendanceData!.clockOutTime!)
        : '--.--';

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: const BoxDecoration(
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
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selamat datang,',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        userName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                todayFormatted,
                style: const TextStyle(
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

          // 3. Tombol Action Clock In & Clock Out
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.accentOrange, width: 1.5),
            ),
            child: Row(
              children: [
                // Tombol Clock In
                Expanded(
                  child: InkWell(
                    onTap: isClockedIn ? null : onClockInPressed,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/clock_in.svg',
                          height: 20,
                          width: 20,
                          colorFilter: ColorFilter.mode(
                            isClockedIn ? Colors.grey : AppColors.clockInBlue,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isClockedIn ? clockInTimeStr : 'Clock In',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isClockedIn ? AppColors.textSecondary : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 24,
                  width: 1,
                  color: AppColors.accentOrange,
                ),
                // Tombol Clock Out
                Expanded(
                  child: InkWell(
                    onTap: onClockOutPressed,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/clock_out.svg',
                          height: 20,
                          width: 20,
                          colorFilter: ColorFilter.mode(
                            (isClockedIn && !isClockedOut) ? AppColors.accentOrange : const Color.fromARGB(255, 223, 21, 21), //JADIKAN GREY NANTI
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isClockedOut ? clockOutTimeStr : 'Clock Out',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: (isClockedIn && !isClockedOut) ? AppColors.textPrimary : AppColors.textPrimary, //JADIKAN TEKST SECONDAARY NANTI
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

          // 4. Keterangan Status
          Center(
            child: Text(
              isClockedOut
                  ? 'Anda telah selesai bekerja dan clock out pada pukul $clockOutTimeStr'
                  : isClockedIn
                      ? 'Anda telah berhasil clock in pada pukul $clockInTimeStr'
                      : 'Anda belum melakukan clock in hari ini',
              style: const TextStyle(
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