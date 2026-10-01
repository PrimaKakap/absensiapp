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
  final DateTime? clockInTime;

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
    this.clockInTime,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    // 1. Ekstraksi Objek Utama (Root dari /employees atau /users)
    final empObj = (json['employee'] as Map<String, dynamic>?) ?? json;
    final userObj = (json['user'] as Map<String, dynamic>?) ?? json;

    // 2. Objek Profile (dari employeeProfile, profile, atau root)
    final profileObj = (json['employeeProfile'] ??
        empObj['employeeProfile'] ??
        userObj['employeeProfile'] ??
        json['profile']) as Map<String, dynamic>?;

    // 3. Objek Relasi Master Data
    final branchObj = (empObj['branch'] ?? json['branch']) as Map<String, dynamic>?;
    final deptObj = (empObj['department'] ?? json['department']) as Map<String, dynamic>?;
    final posObj = (empObj['position'] ?? empObj['jobPosition'] ?? json['jobPosition'] ?? json['position']) as Map<String, dynamic>?;

    // 4. Ekstraksi Log Absensi Hari Ini (Support Objek tunggal maupun List)
    final attendanceData = json['todayAttendance'] ??
        json['attendance'] ??
        (json['attendances'] != null && (json['attendances'] as List).isNotEmpty
            ? json['attendances'][0]
            : null);

    DateTime? parsedClockIn;
    String status = 'ABSENT';
    int lateness = 0;

    if (attendanceData != null) {
      final clockInRaw = attendanceData['clock_in_time'] ??
          attendanceData['clockInTime'] ??
          attendanceData['created_at'] ??
          attendanceData['createdAt'];

      if (clockInRaw != null) {
        parsedClockIn = DateTime.tryParse(clockInRaw.toString());
        status = attendanceData['status'] ?? 'PRESENT';
      }

      lateness = attendanceData['lateness_minutes'] ??
          attendanceData['latenessMinutes'] ??
          0;
    }

    // 5. Ekstraksi Nama
    String extractedName = 'karyawan_nodata';
    if (profileObj != null) {
      extractedName = profileObj['full_name'] ??
          profileObj['fullName'] ??
          profileObj['namaLengkap'] ??
          '';
    }
    if (extractedName.isEmpty) {
      extractedName = json['name'] ??
          userObj['username'] ??
          empObj['employeeNumber'] ??
          'karyawan_nodata';
    }

    // 6. Ekstraksi Email
    String extractedEmail = userObj['companyEmail'] ??
        userObj['email'] ??
        userObj['workEmail'] ??
        profileObj?['personalEmail'] ??
        profileObj?['emailPribadi'] ??
        'No data (email)';

    // 7. Ekstraksi Nomor HP
    String extractedPhone = profileObj?['phoneNumber'] ??
        profileObj?['noHp'] ??
        'No data (no hp)';

    // 8. Ekstraksi Tanggal Lahir
    String extractedBirthDate = profileObj?['dateOfBirth'] ??
        profileObj?['birthDate'] ??
        profileObj?['tanggalLahir'] ??
        'No data (tanggal lahir)';

    // 9. Ekstraksi Cabang
    String extractedBranch = '-';
    if (branchObj != null) {
      extractedBranch = branchObj['branch_name'] ??
          branchObj['branchName'] ??
          branchObj['namaCabang'] ??
          '-';
    }

    // 10. Ekstraksi Departemen / Organisasi
    String extractedDept = '-';
    if (deptObj != null) {
      extractedDept = deptObj['department_name'] ??
          deptObj['departmentName'] ??
          deptObj['namaDepartemen'] ??
          '-';
    }

    // 11. Ekstraksi Jabatan / Posisi
    String extractedPosition = '-';
    if (posObj != null) {
      extractedPosition = posObj['position_name'] ??
          posObj['positionName'] ??
          '-';
    } else if (empObj['employmentStatus'] != null) {
      extractedPosition = empObj['employmentStatus'];
    }

    return Employee(
      id: json['employee_id'] ?? json['id'] ?? empObj['employee_id'] ?? empObj['id'] ?? '',
      name: extractedName,
      email: extractedEmail,
      phone: extractedPhone,
      birthDate: extractedBirthDate,
      position: extractedPosition,
      branch: extractedBranch,
      organizations: extractedDept,
      joinDate: empObj['join_date'] ??
          empObj['joinDate'] ??
          empObj['startDate'] ??
          'No data (tanggal join)',
      photoUrl: profileObj?['photo_url'] ??
          profileObj?['photoUrl'] ??
          'https://i.pravatar.cc/300?img=${(json['id'] ?? json['employee_id'] ?? '').hashCode.abs() % 70}',
      attendanceStatus: status,
      latenessMinutes: lateness,
      clockInTime: parsedClockIn,
    );
  }
}