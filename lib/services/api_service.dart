import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/employee.dart';
import '../models/account_profile.dart';
import '../models/attendance_model.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.149:5000/api/v1';

  /// Helper Ambil Employee ID Tersimpan
  static Future<String> getSavedEmployeeId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('employeeId') ?? '';
  }

  /// Helper Ambil Bearer Token
  static Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Service Bypass Login Sementara
  static Future<void> loginBypass() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('employeeId', 'e29bb03b-825d-41cb-a6c3-493d63b1cb00');
    await prefs.setString('fullName', 'John Doe');
    await prefs.setBool('isLoggedIn', true);
  }

  /// Service Login Aman & Fleksibel
  static Future<bool> login(String email, String password) async {
    try {
      final cleanEmail = email.trim();
      final cleanPassword = password.trim();

      if (cleanEmail.isEmpty || cleanPassword.isEmpty) {
        throw Exception('Email dan password tidak boleh kosong');
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/users/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'companyEmail': cleanEmail,
              'password': cleanPassword,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        final String token = (responseData['accessToken'] ?? responseData['token'] ?? '').toString();
        
        if (kDebugMode) {
          debugPrint('===> JWT Token Berhasil Diterima: $token');
        }

        final data = responseData['data'] ?? responseData;
        final user = data['user'] ?? data;
        final employee = data['employee'] ?? user['employee'] ?? {};
        final profile = user['employeeProfile'] ?? employee['employeeProfile'] ?? {};

        final String employeeId = (employee['id'] ??
          employee['employee_id'] ??
          data['employeeId'] ??
          data['employee_id'] ??
          user['employeeId'] ??
          user['employee_id'] ??
          user['id'] ??
            '').toString();

        final String fullName = (profile['fullName'] ??
            user['companyEmail'] ??
            'Karyawan').toString();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('employeeId', employeeId);
        await prefs.setString('fullName', fullName);
        if (token.isNotEmpty) {
          await prefs.setString('token', token);
        }
        await prefs.setBool('isLoggedIn', true);

        return true;
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final msg = errorData['message'];
        if (msg is List) {
          throw Exception(msg.join('\n'));
        }
        throw Exception(msg ?? 'Login gagal (Status: ${response.statusCode})');
      }
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      if (errorMsg.contains('500')) {
        throw Exception('Terjadi kesalahan pada server (Internal Server Error 500). Harap cek log backend NestJS.');
      }
      throw Exception('Gagal melakukan login: $errorMsg');
    }
  }

/// Method Ubah Password
static Future<bool> changePassword({
  required String oldPassword,
  required String newPassword,
}) async {
  try {
    final token = await getSavedToken();

    final response = await http.patch(
      Uri.parse('$baseUrl/users/change-password'), 
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      final Map<String, dynamic> body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Gagal mengubah kata sandi');
    }
  } catch (e) {
    throw Exception('Error: ${e.toString().replaceAll('Exception: ', '')}');
  }
}

  /// Fetch Absensi Hari Ini untuk User Logged In (Single Object)
  static Future<AttendanceModel?> getTodayAttendance(String token) async {
    final url = Uri.parse('$baseUrl/attendances/today');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'] ?? body;

        if (data == null) return null;
        return AttendanceModel.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint("Error getTodayAttendance: $e");
      return null;
    }
  }

  /// Fetch Seluruh Absensi Hari Ini Karyawan (List Object)
  static Future<List<AttendanceModel>> getAllTodayAttendances(String token) async {
    final url = Uri.parse('$baseUrl/attendances/today/all');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List data = body['data'] ?? body;

        return data.map((e) => AttendanceModel.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("Error getAllTodayAttendances: $e");
      return [];
    }
  }

  /// Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Fetch daftar karyawan
  static Future<List<Employee>> fetchEmployees() async {
    try {
      final token = await getSavedToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final response = await http
          .get(Uri.parse('$baseUrl/employees'), headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> listData = body['data'] ?? [];
        return listData.map((item) => Employee.fromJson(item)).toList();
      } else {
        throw Exception('Gagal mengambil data karyawan (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error koneksi API: $e');
    }
  }

  /// Fetch detail profil karyawan aktif
  static Future<AccountProfile> fetchEmployeeDetail(String employeeId) async {
    try {
 String activeId = employeeId;
    if (activeId.isEmpty) {
      activeId = await getSavedEmployeeId();
    }

    final token = await getSavedToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final response = await http
        .get(Uri.parse('$baseUrl/employees/$activeId'), headers: headers)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final data = body['data'] ?? body;
      return AccountProfile.fromJson(data);
    } else {
      debugPrint('Fetch profile failed status: ${response.statusCode}');
      return _getDummyProfileDetail();
    }
  } catch (e) {
    debugPrint('Fetch profile error: $e');
    return _getDummyProfileDetail();
  }
}

  /// Fallback dummy profil
  static AccountProfile _getDummyProfileDetail() {
    return AccountProfile(
      employeeId: 'e29bb03b-825d-41cb-a6c3-493d63b1cb00',
      employeeNumber: 'EMP-2026-010',
      fullName: 'John Doe',
      companyEmail: 'johndoe@gmail.com',
      phoneNumber: '081234567890',
      positionName: 'UI/UX Designer',
      departmentName: 'Application Development',
      branchName: 'PT. BLiP Integrator Provider Denpasar',
      companyName: 'Semua Aplikasi Indonesia',
      nationalIdNumber: '3201234567890001',
      residentialAddress: 'NY Street 32.',
      employmentStatus: 'PERMANENT',
    );
  }

  /// Method Submit Absensi
  static Future<Map<String, dynamic>> submitAttendance({
    required String employeeId,
    required double latitude,
    required double longitude,
    required List<double> faceEmbedding,
    required String type,
  }) async {
    try {
      final isClockIn = type == 'CLOCK_IN';
      final nowIso = DateTime.now().toUtc().toIso8601String();

      final activeEmployeeId = employeeId.isNotEmpty
          ? employeeId
          : await getSavedEmployeeId();

      final token = await getSavedToken();

      final Map<String, dynamic> bodyPayload = {
        'employeeId': activeEmployeeId,
        'shiftId': 'ae3a5d82-4fc2-4e94-b4ab-7e4469093be3',
        'locationId': 'ae3a5d82-4fc2-4e94-b4ab-7e4469093be3',
        'faceEmbedding': faceEmbedding,
        'type': type,
        'status': 'PRESENT',
        'latitudeIn': isClockIn ? latitude : 0.0,
        'longitudeIn': isClockIn ? longitude : 0.0,
        'photoInUrl': 'https://example.com/photo_in.jpg',
        if (!isClockIn) ...{
          'clockOutTime': nowIso,
          'latitudeOut': latitude,
          'longitudeOut': longitude,
          'photoOutUrl': 'https://example.com/photo_out.jpg',
        }
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/attendances'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode(bodyPayload),
          )
          .timeout(const Duration(seconds: 15));

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else {
        final msg = responseData['message'];
        if (msg is List) {
          throw Exception(msg.join('\n'));
        }
        throw Exception(msg ?? 'Gagal melakukan absensi (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Gagal menghubungi server absensi: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }
}