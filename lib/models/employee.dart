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
    //Extract nested objects dari response API
    final profileObj = json['profile'] as Map<String, dynamic>?;
    final branchObj = json['branch'] as Map<String, dynamic>?;
    final deptObj = json['department'] as Map<String, dynamic>?;

    //nama
    String extractedName = 'No data (nama)';
    if (profileObj != null && profileObj['namaLengkap'] != null && profileObj['namaLengkap'].toString().isNotEmpty) {
      extractedName = profileObj['namaLengkap'];
    } else if (json['nikKaryawan'] != null && json['nikKaryawan'].toString().isNotEmpty) {
      extractedName = json['nikKaryawan'];
    }

    //email
    String extractedEmail = profileObj?['emailPribadi'] ?? json['email'] ?? 'No data (email)';

    //nomor hp
    String extractedPhone = profileObj?['noHp'] ?? json['phone'] ?? 'No data (no hp)';

    // tgl lahir
    String extractedBirthDate = profileObj?['tanggalLahir'] ?? json['birthDate'] ?? 'No data (tanggal lahir)';

    return Employee(
      id: json['id'] ?? '',
      name: extractedName,
      email: extractedEmail,
      phone: extractedPhone,
      birthDate: extractedBirthDate,
      position: json['positionId'] ?? json['employmentStatus'] ?? 'No data (posisi)',
      branch: branchObj != null ? (branchObj['namaCabang'] ?? 'No data (cabang)') : 'No data (cabang)',
      organizations: deptObj != null ? (deptObj['namaDepartemen'] ?? 'No data (dept)') : 'No data (dept)',
      joinDate: json['tanggalMasuk'] ?? 'No data (tanggal join)',
      photoUrl: 'https://i.pravatar.cc/300?img=${(json['id'] ?? '').hashCode % 70}',
    );
  }
}