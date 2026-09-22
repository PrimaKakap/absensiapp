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
    final profileObj = (json['employeeProfile'] ??
        empObj['employeeProfile'] ??
        userObj['employeeProfile']) as Map<String, dynamic>?;

    // Objek Branch, Department, dan Position
    final branchObj = empObj['branch'] as Map<String, dynamic>?;
    final deptObj = empObj['department'] as Map<String, dynamic>?;
    final posObj = empObj['position'] as Map<String, dynamic>?;

    // 2. Ekstraksi Nama
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

    // 3. Ekstraksi Email
    String extractedEmail = userObj['email'] ??
        userObj['workEmail'] ??
        profileObj?['personalEmail'] ??
        profileObj?['emailPribadi'] ??
        'No data (email)';

    // 4. Ekstraksi No HP
    String extractedPhone = profileObj?['phoneNumber'] ??
        profileObj?['noHp'] ??
        'No data (no hp)';

    // 5. Ekstraksi Tanggal Lahir
    String extractedBirthDate = profileObj?['birthDate'] ??
        profileObj?['tanggalLahir'] ??
        'No data (tanggal lahir)';

    // 6. Ekstraksi Cabang
    String extractedBranch = 'No data (cabang)';
    if (branchObj != null) {
      extractedBranch =
          branchObj['branchName'] ?? branchObj['namaCabang'] ?? 'No data (cabang)';
    }

    // 7. Ekstraksi Departemen / Organisasi
    String extractedDept = 'No data (departemen)';
    if (deptObj != null) {
      extractedDept = deptObj['departmentName'] ??
          deptObj['namaDepartemen'] ??
          'No data (departemen)';
    }

    // 8. Ekstraksi Posisi / Jabatan
    String extractedPosition = 'No data (posisi)';
    if (posObj != null && posObj['positionName'] != null) {
      extractedPosition = posObj['positionName'];
    } else if (empObj['positionName'] != null) {
      extractedPosition = empObj['positionName'];
    } else if (empObj['employmentStatus'] != null) {
      extractedPosition = empObj['employmentStatus'];
    }

    return Employee(
      id: json['id'] ?? '',
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
    );
  }
}