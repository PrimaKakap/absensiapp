class Employee {
  final String id;
  final String name;
  final String position;
  final String branch;
  final String email;
  final String phone;
  final String organizations;
  final String joinDate;
  final String birthDate;
  final String photoUrl;

  Employee({
    required this.id,
    required this.name,
    required this.position,
    required this.branch,
    required this.email,
    required this.phone,
    required this.organizations,
    required this.joinDate,
    required this.birthDate,
    required this.photoUrl,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    // 1. Tangani hierarki root (apakah dari /employees atau dari /users)
    final empObj = (json['employee'] as Map<String, dynamic>?) ?? json;
    final userObj = (json['user'] as Map<String, dynamic>?) ?? json;
    
    // Objek Profile (bisa di root, di dalam employee, atau di dalam user)
    final profileObj = (json['employeeProfile'] ?? empObj['employeeProfile'] ?? userObj['employeeProfile']) as Map<String, dynamic>?;

    // Objek Branch & Department
    final branchObj = empObj['branch'] as Map<String, dynamic>?;
    final deptObj = empObj['department'] as Map<String, dynamic>?;

    // 2. Extraksi Nama
    String extractedName = 'No data (nama)';
    if (profileObj != null && profileObj['fullName'] != null && profileObj['fullName'].toString().isNotEmpty) {
      extractedName = profileObj['fullName'];
    } else if (profileObj != null && profileObj['namaLengkap'] != null && profileObj['namaLengkap'].toString().isNotEmpty) {
      extractedName = profileObj['namaLengkap'];
    } else if (userObj['username'] != null && userObj['username'].toString().isNotEmpty) {
      extractedName = userObj['username'];
    } else if (empObj['employeeNumber'] != null) {
      extractedName = empObj['employeeNumber'];
    }

    // 3. Extraksi Email
    String extractedEmail = userObj['email'] ??
        userObj['workEmail'] ??
        profileObj?['personalEmail'] ??
        profileObj?['emailPribadi'] ??
        'No data (email)';

    // 4. Extraksi No HP (Cek phoneNumber dan noHp)
    String extractedPhone = profileObj?['phoneNumber'] ??
        profileObj?['noHp'] ??
        'No data (no hp)';

    // 5. Extraksi Tanggal Lahir
    String extractedBirthDate = profileObj?['birthDate'] ??
        profileObj?['tanggalLahir'] ??
        'No data (tanggal lahir)';

    // 6. Extraksi Cabang (Cek branchName dan namaCabang)
    String extractedBranch = 'No data (cabang)';
    if (branchObj != null) {
      extractedBranch = branchObj['branchName'] ?? branchObj['namaCabang'] ?? 'No data (cabang)';
    }

    // 7. Extraksi Departemen (Cek departmentName dan namaDepartemen)
    String extractedDept = 'No data (departemen)';
    if (deptObj != null) {
      extractedDept = deptObj['departmentName'] ?? deptObj['namaDepartemen'] ?? 'No data (departemen)';
    }

    // 8. Extraksi Posisi / Jabatan
    String extractedPosition = empObj['positionId'] ?? empObj['employmentStatus'] ?? 'No data (posisi)';

    return Employee(
      id: json['id'] ?? '',
      name: extractedName,
      email: extractedEmail,
      phone: extractedPhone,
      birthDate: extractedBirthDate,
      position: extractedPosition,
      branch: extractedBranch,
      organizations: extractedDept,
      joinDate: empObj['startDate'] ?? empObj['tanggalMasuk'] ?? 'No data (tanggal join)',
      photoUrl: 'https://i.pravatar.cc/300?img=${(json['id'] ?? '').hashCode.abs() % 70}',
    );
  }
}

//   factory Employee.fromJson(Map<String, dynamic> json) {
//     // Hireraki root apakah dari /employees atau dari
//     final empObj = json['employee'] as Map<String, dynamic>?;
//     final profileObj = (json['employeeProfile'] ?? json['profile']) as Map<String, dynamic>?;
//     final branchObj = empObj?['branch'] as Map<String, dynamic>?;
//     final deptObj = empObj?['department'] as Map<String, dynamic>?;

//     // 1. Extraction Nama (Prioritas: profile -> username -> nik -> fallback)
//     String extractedName = 'No data (nama)';
//     if (profileObj != null && profileObj['namaLengkap'] != null && profileObj['namaLengkap'].toString().isNotEmpty) {
//       extractedName = profileObj['namaLengkap'];
//     } else if (json['username'] != null && json['username'].toString().isNotEmpty) {
//       extractedName = json['username'];
//     } else if (empObj?['nikKaryawan'] != null) {
//       extractedName = empObj!['nikKaryawan'];
//     }

//     // 2. Extraction Email (Prioritas: workEmail -> email -> profile.emailPribadi)
//     String extractedEmail = json['workEmail'] ??
//         json['email'] ??
//         profileObj?['emailPribadi'] ??
//         'No data (email)';

//     // 3. Extraction No HP
//     String extractedPhone = profileObj?['noHp'] ?? json['phone'] ?? 'No data (no hp)';

//     // 4. Extraction Tanggal Lahir
//     String extractedBirthDate = profileObj?['tanggalLahir'] ?? json['birthDate'] ?? 'No data (tanggal lahir)';

//     // 5. Extraction Posisi & Cabang & Organisasi
//     String extractedPosition = empObj?['positionId'] ?? empObj?['employmentStatus'] ?? 'no data (posisi/jabatan)';
//     String extractedBranch = branchObj?['namaCabang'] ?? 'no data (cabang)';
//     String extractedDept = deptObj?['namaDepartemen'] ?? 'no data (departemen)';

//     return Employee(
//       id: json['id'] ?? '',
//       name: extractedName,
//       email: extractedEmail,
//       phone: extractedPhone,
//       birthDate: extractedBirthDate,
//       position: extractedPosition,
//       branch: extractedBranch,
//       organizations: extractedDept,
//       joinDate: empObj?['tanggalMasuk'] ?? json['createdAt']?.toString().split('T')[0] ?? 'No data (tanggal join)',
//       photoUrl: 'https://i.pravatar.cc/300?img=${(json['id'] ?? '').hashCode.abs() % 70}',
//     );
//   }
// }