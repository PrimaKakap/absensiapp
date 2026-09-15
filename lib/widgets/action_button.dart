import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ActionButton extends StatelessWidget {
  final String assetName;
  final VoidCallback onTap;

  const ActionButton({
    super.key,
    required this.assetName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, 
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: SvgPicture.asset(
          'assets/icons/$assetName.svg',
          width: 22,
          height: 22,
          colorFilter: ColorFilter.mode(Colors.blue.shade800, BlendMode.srcIn),
        ),
      ),
    );
  }
}