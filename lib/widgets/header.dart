import 'package:flutter/material.dart';
import '../theme/app_colors.dart'; 
import '../pages/organization_chart_page.dart';

class EmployeeHeader extends StatelessWidget {
  final int totalEmployees;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onFilterTap;

  const EmployeeHeader({super.key, required this.totalEmployees,
  this.onSearchChanged, this.onFilterTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Title & Icon Top Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const SizedBox(width: 48),

              Center(
                child: RichText(
                    text: TextSpan(
                      text: 'Employees ',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      children: [
                        TextSpan(
                          text: '$totalEmployees',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Ikon di sebelah kanan
              Positioned(
                right: 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.account_tree_outlined,
                        color: AppColors.iconInactive,
                      ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const OrganizationChartPage(),
                      ),
                    );
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(
                      Icons.tune,
                      color: AppColors.iconInactive,
                    ),
                    onPressed: onFilterTap,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              )
            ],
          ),
        ),

        // Search Bar 
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Cari Karyawan',
              hintStyle: TextStyle(color: AppColors.textSecondary),
              prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.cardBackground,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: AppColors.scaffoldBackground),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: AppColors.scaffoldBackground),
              ),
            ),
          ),
        ),
      ],
    );
  }
}