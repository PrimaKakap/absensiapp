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

  final String attendanceStatus; // 'PRESENT', 'LATE', 'LEAVE', 'ABSENT'
  final int latenessMinutes;

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
    this.attendanceStatus = 'ABSENT',
    this.latenessMinutes = 0,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    // 1. Ekstraksi Objek Utama (Root dari /employees atau /users)
    final empObj = (json['employee'] as Map<String, dynamic>?) ?? json;
    final userObj = (json['user'] as Map<String, dynamic>?) ?? json;

    // Objek Profile (dari employeeProfile atau profile)
    final profileObj = (json['employeeProfile'] ??
        empObj['employeeProfile'] ??
        userObj['employeeProfile']) as Map<String, dynamic>?;

    // Objek Relasi Organisasi & Posisi
    final branchObj = empObj['branch'] as Map<String, dynamic>?;
    final deptObj = empObj['department'] as Map<String, dynamic>?;
    final posObj = empObj['position'] as Map<String, dynamic>?;

    // 2. Ekstraksi Data Presensi (dari array attendances jika ada)
    String extractedStatus = 'ABSENT';
    int extractedLateness = 0;

    final attendancesList = (json['attendances'] ??
        empObj['attendances'] ??
        userObj['attendances']) as List<dynamic>?;

    if (attendancesList != null && attendancesList.isNotEmpty) {
      final latestAttendance = attendancesList.first as Map<String, dynamic>;
      extractedStatus = latestAttendance['status'] ?? 'PRESENT';
      extractedLateness = latestAttendance['latenessMinutes'] ??
          latestAttendance['lateness_minutes'] ??
          0;
    }

    // 3. Ekstraksi Nama (Prioritas: profile.fullName -> profile.namaLengkap -> user.username -> employeeNumber)
    String extractedName = 'No data (nama)';
    if (profileObj != null &&
        profileObj['fullName'] != null &&
        profileObj['fullName'].toString().isNotEmpty) {
      extractedName = profileObj['fullName'];
    } else if (profileObj != null &&
        profileObj['namaLengkap'] != null &&
        profileObj['namaLengkap'].toString().isNotEmpty) {
      extractedName = profileObj['namaLengkap'];
    } else if (userObj['username'] != null &&
        userObj['username'].toString().isNotEmpty) {
      extractedName = userObj['username'];
    } else if (empObj['employeeNumber'] != null) {
      extractedName = empObj['employeeNumber'];
    }

    // 4. Ekstraksi Email
    String extractedEmail = userObj['email'] ??
        userObj['workEmail'] ??
        profileObj?['personalEmail'] ??
        profileObj?['emailPribadi'] ??
        'No data (email)';

    // 5. Ekstraksi Nomor HP
    String extractedPhone = profileObj?['phoneNumber'] ??
        profileObj?['noHp'] ??
        'No data (no hp)';

    // 6. Ekstraksi Tanggal Lahir
    String extractedBirthDate = profileObj?['birthDate'] ??
        profileObj?['tanggalLahir'] ??
        'No data (tanggal lahir)';

    // 7. Ekstraksi Cabang
    String extractedBranch = 'No data (cabang)';
    if (branchObj != null) {
      extractedBranch =
          branchObj['branchName'] ?? branchObj['namaCabang'] ?? 'No data (cabang)';
    }

    // 8. Ekstraksi Departemen / Organisasi
    String extractedDept = 'No data (departemen)';
    if (deptObj != null) {
      extractedDept = deptObj['departmentName'] ??
          deptObj['namaDepartemen'] ??
          'No data (departemen)';
    }

    // 9. Ekstraksi Jabatan / Posisi
    String extractedPosition = 'No data (posisi)';
    if (posObj != null && posObj['positionName'] != null) {
      extractedPosition = posObj['positionName'];
    } else if (empObj['positionName'] != null) {
      extractedPosition = empObj['positionName'];
    } else if (empObj['employmentStatus'] != null) {
      extractedPosition = empObj['employmentStatus'];
    }

    return Employee(
      id: json['id'] ?? empObj['id'] ?? '',
      name: extractedName,
      email: extractedEmail,
      phone: extractedPhone,
      birthDate: extractedBirthDate,
      position: extractedPosition,
      branch: extractedBranch,
      organizations: extractedDept,
      joinDate: empObj['startDate'] ??
          empObj['tanggalMasuk'] ??
          'No data (tanggal join)',
      photoUrl:
          'https://i.pravatar.cc/300?img=${(json['id'] ?? '').hashCode.abs() % 70}',
      attendanceStatus: extractedStatus,
      latenessMinutes: extractedLateness,
    );
  }
}