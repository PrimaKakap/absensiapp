class AccountProfile {
  final String employeeId;
  final String employeeNumber;
  final String fullName;
  final String companyEmail;
  final String phoneNumber;
  final String positionName;
  final String departmentName;
  final String branchName;
  final String companyName;
  final String nationalIdNumber;
  final String residentialAddress;
  final String employmentStatus;

  AccountProfile({
    required this.employeeId,
    required this.employeeNumber,
    required this.fullName,
    required this.companyEmail,
    required this.phoneNumber,
    required this.positionName,
    required this.departmentName,
    required this.branchName,
    required this.companyName,
    required this.nationalIdNumber,
    required this.residentialAddress,
    required this.employmentStatus,
  });

  factory AccountProfile.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    final profile = user['employeeProfile'] ?? {};
    final position = json['position'] ?? {};
    final department = json['department'] ?? {};
    final branch = json['branch'] ?? {};
    final company = json['company'] ?? {};

    return AccountProfile(
      employeeId: json['id'] ?? '',
      employeeNumber: json['employeeNumber'] ?? '-',
      fullName: profile['fullName'] ?? 'Nama Karyawan',
      companyEmail: user['companyEmail'] ?? '-',
      phoneNumber: profile['phoneNumber'] ?? '-',
      positionName: position['positionName'] ?? 'Staff',
      departmentName: department['departmentName'] ?? 'General',
      branchName: branch['branchName'] ?? 'Kantor Pusat',
      companyName: company['companyName'] ?? 'PT Semua Aplikasi Indonesia',
      nationalIdNumber: profile['nationalIdNumber'] ?? '-',
      residentialAddress: profile['residentialAddress'] ?? '-',
      employmentStatus: json['employmentStatus'] ?? 'PERMANENT',
    );
  }
}