import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../theme/app_colors.dart';

class UnabsentEmployeeCard extends StatelessWidget {
  final List<Employee> absentList;

  const UnabsentEmployeeCard({
    super.key,
    required this.absentList,
  });

  @override
  Widget build(BuildContext context) {
    if (absentList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
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
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: absentList.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final employee = absentList[index];
                return Column(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(employee.photoUrl),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 60,
                      child: Text(
                        employee.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import '../models/employee.dart';
// import '../theme/app_colors.dart';
// import '../pages/employee_detail_page.dart';

// class AbsentEmployeesCard extends StatelessWidget {
//   final List<Employee> absentList;

//   const AbsentEmployeesCard({super.key, required this.absentList});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.cardBackground,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Tidak Hadir Hari ini',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: AppColors.textPrimary,
//             ),
//           ),
//           const SizedBox(height: 12),
          
//           // Tampilan jika SEMUA karyawan HADIR (absentList kosong)
//           if (absentList.isEmpty)
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8.0),
//               child: Row(
//                 children: [
//                   const Icon(
//                     Icons.check_circle_outline_rounded,
//                     color: Colors.green,
//                     size: 24,
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: Text(
//                       'Semua karyawan hadir hari ini!',
//                       style: TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.green.shade700,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           // Tampilan daftar avatar jika ADA karyawan yang TIDAK HADIR
//           else
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: absentList.map((employee) {
//                   return Padding(
//                     padding: const EdgeInsets.only(right: 16),
//                     child: GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) =>
//                                 EmployeeDetailPage(employee: employee),
//                           ),
//                         );
//                       },
//                       child: Column(
//                         children: [
//                           CircleAvatar(
//                             radius: 26,
//                             backgroundImage: NetworkImage(employee.photoUrl),
//                           ),
//                           const SizedBox(height: 6),
//                           SizedBox(
//                             width: 70,
//                             child: Text(
//                               employee.name,
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 fontSize: 11,
//                                 color: AppColors.textSecondary,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }