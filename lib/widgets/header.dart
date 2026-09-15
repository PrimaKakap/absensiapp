import 'package:flutter/material.dart';

class EmployeeHeader extends StatelessWidget {
  final int totalEmployees;

  const EmployeeHeader({super.key, required this.totalEmployees});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Title & Icon Top Bar
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  child: Row(
  children: [
  const SizedBox(width: 48),
              
  Expanded(
  child: Center(
  child: RichText(
    text: TextSpan(
    text: 'Employees ',
    style: const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.black,
                      ),
    children: [
    TextSpan(
    text: '$totalEmployees',
    style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
              
              // Ikon di sebelah kanan
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.account_tree_outlined, color: Colors.grey),
                    onPressed: () {},
                    padding: EdgeInsets.zero, // Kurangi padding agar lebih rapat
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.tune, color: Colors.grey),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Search Bar 
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cari Karyawan',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ),
      ],
    );
  }
}