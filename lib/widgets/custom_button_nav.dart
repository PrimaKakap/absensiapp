import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../theme/app_colors.dart';

class CustomButtonNav extends StatelessWidget {
final int currentIndex;
final Function(int)onTap;

const CustomButtonNav({
  super.key,
  required this.currentIndex,
  required this.onTap,
});

@override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(
          top: BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 1. Beranda
          Expanded(
          child: _buildNavItem(
            index: 0,
            label: 'Beranda',
            assetName: 'home',
          ),
          ),

          // 2. Karyawan
          Expanded(child:
          _buildNavItem(
            index: 1,
            label: 'Karyawan',
            assetName: 'karyawan',
          ),
          ),
          // 3. Pengajuan 
          Expanded(child:
          _buildNavItem(
            index: 2,
            label: 'Pengajuan',
            assetName: 'add',
            isCenterAction: true,
          ),
          ),
          // 4. Inbox (Dengan Notification dot)
          Expanded(child: 
          _buildNavItem(
            index: 3,
            label: 'Inbox',
            assetName: 'inbox',
            badgeCount: 2,
          ),
          ),

          // 5. Akun 
          Expanded(child: 
          _buildNavItem(
            index: 4,
            label: 'Akun',
            isProfile: true,
            photoUrl: 'https://i.pravatar.cc/100?img=12', // Nanti bisa diisi dynamic
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    String? assetName,
    bool isCenterAction = false,
    bool isProfile = false,
    int badgeCount = 0,
    String? photoUrl,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.primaryRed : AppColors.iconInactive;

    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Render Ikon atau Foto Profil
          Stack(
            clipBehavior: Clip.none,
            children: [
              if (isProfile)
                Container(
                  padding: const EdgeInsets.all(1.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primaryRed : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 12,
                    backgroundImage: NetworkImage(photoUrl ?? ''),
                  ),
                )
              else if (isCenterAction)
                SvgPicture.asset(
                  'assets/icons/${assetName ?? "add"}.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                )
              else
                SvgPicture.asset(
                  'assets/icons/${assetName ?? "home"}.svg',
                  width: 22,
                  height: 22,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                ),

              // Notification Badge Merah
              if (badgeCount > 0)
                Positioned(
                  top: -4,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryRed,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
