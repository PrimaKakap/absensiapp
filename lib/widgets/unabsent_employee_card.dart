import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../pages/employee_detail_page.dart'; // Impor halaman detail

class AbsentEmployeesCard extends StatelessWidget {
  final List<Employee> absentList;

  const AbsentEmployeesCard({super.key, required this.absentList});

  @override
  Widget build(BuildContext context) {
    if (absentList.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tidak Hadir Hari ini',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: absentList.map((employee) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  // Bungkus item dengan GestureDetector agar bisa diklik
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EmployeeDetailPage(employee: employee),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundImage: NetworkImage(employee.photoUrl),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 70,
                          child: Text(
                            employee.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}