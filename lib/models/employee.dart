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
    // Extract nested objects dari response API jika ada
    final empObj = json['employee'] as Map<String, dynamic>?;
    final profileObj = (json['employeeProfile'] ?? json['profile']) as Map<String, dynamic>?;
    final branchObj = empObj?['branch'] as Map<String, dynamic>?;
    final deptObj = empObj?['department'] as Map<String, dynamic>?;

    // 1. Extraction Nama (Prioritas: profile -> username -> nik -> fallback)
    String extractedName = 'No data (nama)';
    if (profileObj != null && profileObj['namaLengkap'] != null && profileObj['namaLengkap'].toString().isNotEmpty) {
      extractedName = profileObj['namaLengkap'];
    } else if (json['username'] != null && json['username'].toString().isNotEmpty) {
      extractedName = json['username'];
    } else if (empObj?['nikKaryawan'] != null) {
      extractedName = empObj!['nikKaryawan'];
    }

    // 2. Extraction Email (Prioritas: workEmail -> email -> profile.emailPribadi)
    String extractedEmail = json['workEmail'] ??
        json['email'] ??
        profileObj?['emailPribadi'] ??
        'No data (email)';

    // 3. Extraction No HP
    String extractedPhone = profileObj?['noHp'] ?? json['phone'] ?? 'No data (no hp)';

    // 4. Extraction Tanggal Lahir
    String extractedBirthDate = profileObj?['tanggalLahir'] ?? json['birthDate'] ?? 'No data (tanggal lahir)';

    // 5. Extraction Posisi & Cabang & Organisasi
    String extractedPosition = empObj?['positionId'] ?? empObj?['employmentStatus'] ?? 'General Staff';
    String extractedBranch = branchObj?['namaCabang'] ?? 'Head Office';
    String extractedDept = deptObj?['namaDepartemen'] ?? 'General';

    return Employee(
      id: json['id'] ?? '',
      name: extractedName,
      email: extractedEmail,
      phone: extractedPhone,
      birthDate: extractedBirthDate,
      position: extractedPosition,
      branch: extractedBranch,
      organizations: extractedDept,
      joinDate: empObj?['tanggalMasuk'] ?? json['createdAt']?.toString().split('T')[0] ?? 'No data (tanggal join)',
      photoUrl: 'https://i.pravatar.cc/300?img=${(json['id'] ?? '').hashCode.abs() % 70}',
    );
  }
}