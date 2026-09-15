

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
  final branchObj = json['branch'] as Map<String, dynamic>?;
  final deptObj = json['department'] as Map<String, dynamic>?;


    return Employee(
      id: json['id'] ?? '',
      name: json['nikKaryawan'] ?? 'No data (nik karyawan)',
      email: json['email'] ?? 'No data (email)',
      position: json['employmentStatus'] ?? 'No data (status pekerjaan)',
      branch: branchObj != null ? branchObj['namaCabang'] ?? 'No data (cabang)' : 'No data (cabang)',
      organizations: deptObj != null ? deptObj['namaDepartemen'] ?? 'No data (dept)' : 'No data (dept)',
      phone: json['phone'] ?? 'No data (no hp)',
      joinDate: json['tanggalMasuk'] ?? 'No data (tanggal join)',
      birthDate: json['birthDate'] ?? 'No data (tanggal lahir)',
      
      photoUrl: 'https://i.pravatar.cc/300?img=${(json['id'] ?? '').hashCode % 70}',
    );
  }
}