import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CameraOverlayWidget extends StatelessWidget {
  final bool isLivenessPassed;
  final String statusMessage;

  const CameraOverlayWidget({
    super.key,
    required this.isLivenessPassed,
    required this.statusMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Container(
            width: 260,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(160),
              border: Border.all(
                color: isLivenessPassed
                    ? Colors.green
                    : AppColors.accentOrange,
                width: 4,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              statusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}