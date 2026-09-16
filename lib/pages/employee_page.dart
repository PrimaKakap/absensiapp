import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/employee.dart';
import '../services/api_service.dart';
import '../dummy_data/employee_dummy.dart'; 
import '../widgets/header.dart';
import '../widgets/unabsent_employee_card.dart';
import 'employee_detail_page.dart';

class EmployeePage extends StatelessWidget {
  const EmployeePage({super.key});

  @override
  Widget build(BuildContext context) {
    const iconColor = Color.fromARGB(255, 184, 184, 184);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 1. Header & Search Bar
              const EmployeeHeader(totalEmployees: 0), // Nanti bisa diisi dynamic count

              const SizedBox(height: 16),

              // 2. Card Tidak Hadir
              AbsentEmployeesCard(absentList: dummyAbsentEmployees),

              const SizedBox(height: 16),

              // 3. Employee List dari API Backend
              Container(
                color: Colors.white,
                child: FutureBuilder<List<Employee>>(
                  future: ApiService.fetchEmployees(),
                  builder: (context, snapshot) {
              // Loading State
if (snapshot.connectionState == ConnectionState.waiting) {
  return const Padding(
    padding: EdgeInsets.symmetric(vertical: 40.0),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Colors.blue, // Warna spinner
            strokeWidth: 3,     // Ketebalan garis spinner
          ),
          SizedBox(height: 12),
          Text(
            'Memuat data karyawan...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ),
  );
}

                    // Error State
                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'Gagal terhubung ke backend:\n${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    }

                    // Data Kosong
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: Text('Belum ada data karyawan.')),
                      );
                    }

                    // Success State
                    final employees = snapshot.data!;

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: employees.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final employee = employees[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(employee.photoUrl),
                          ),
                          title: Text(
                            employee.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text('${employee.position}\n${employee.organizations}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/phone.svg',
                                width: 20,
                                height: 20,
                                colorFilter: const ColorFilter.mode(iconColor, BlendMode.srcIn),
                              ),
                              const SizedBox(width: 12),
                              SvgPicture.asset(
                                'assets/icons/mail.svg',
                                width: 20,
                                height: 20,
                                colorFilter: const ColorFilter.mode(iconColor, BlendMode.srcIn),
                              ),
                              const SizedBox(width: 12),
                              SvgPicture.asset(
                                'assets/icons/whatsapp.svg',
                                width: 20,
                                height: 20,
                                colorFilter: const ColorFilter.mode(iconColor, BlendMode.srcIn),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EmployeeDetailPage(employee: employee),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}