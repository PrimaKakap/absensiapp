class UserSession {
  final String userId;
  final String employeeId;
  final String fullName;
  final String email;
  final String token;

  UserSession({
    required this.userId,
    required this.employeeId,
    required this.fullName,
    required this.email,
    required this.token,
  });

  factory UserSession.fromJson(Map<String, dynamic> json) {
   final userData = json['user'] ?? json['data']?['user'] ?? {};
   final employeeData = json['employee'] ?? json['data']?['employee'] ?? {};
   final profileData = userData['employeeProfile'] ?? {};

    return UserSession(
      userId: userData['id'] ?? '',
      employeeId: employeeData['id'] ?? json['employeeId'] ?? '',
      fullName: profileData['fullName'] ?? userData['username'] ?? 'Karyawan',
      email: userData['email'] ?? userData['companyEmail'] ?? '',
      token: json['accessToken'] ?? json['token'] ?? '',
    );
  }
}