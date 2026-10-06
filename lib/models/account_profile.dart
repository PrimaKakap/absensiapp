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
    final profile = json['profile'] ?? json['employeeProfile'] ?? {};
    final position = json['position'] ?? {};
    final department = json['department'] ?? {};
    final branch = json['branch'] ?? {};
    final company = json['company'] ?? {};
    final user = json['user'] ?? {};

    return AccountProfile(
      employeeId: (json['id'] ?? '').toString(),
      employeeNumber: (json['employeeNumber'] ?? '-').toString(),
      fullName: (profile['fullName'] ?? user['username'] ?? 'Karyawan').toString(),
      companyEmail: (user['companyEmail'] ?? profile['personalEmail'] ?? '-').toString(),
      phoneNumber: (profile['phoneNumber'] ?? '-').toString(),
      positionName: (position['positionName'] ?? 'Staf').toString(),
      departmentName: (department['departmentName'] ?? 'Umum').toString(),
      branchName: (branch['branchName'] ?? '-').toString(),
      companyName: (company['companyName'] ?? '-').toString(),
      nationalIdNumber: (profile['nationalIdNumber'] ?? '-').toString(),
      residentialAddress: (profile['residentialAddress'] ?? '-').toString(),
      employmentStatus: (json['employmentStatus'] ?? 'PERMANENT').toString(),
    );
  }
}