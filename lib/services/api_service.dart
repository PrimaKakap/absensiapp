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

/// Service Login (Simpan userId & refreshToken)
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
        final String refreshToken = (responseData['refreshToken'] ?? responseData['refresh_token'] ?? '').toString();

        final data = responseData['data'] ?? responseData;
        final user = data['user'] ?? data;
        final employee = data['employee'] ?? user['employee'] ?? {};
        final profile = user['employeeProfile'] ?? employee['employeeProfile'] ?? employee['profile'] ?? {};

        final String userId = (user['id'] ?? data['userId'] ?? '').toString();
        final String employeeId = (employee['id'] ??
          employee['employee_id'] ??
          data['employeeId'] ??
          user['employeeId'] ??
          '').toString();

        final String fullName = (profile['fullName'] ??
            employee['companyEmail'] ??
            user['companyEmail'] ??
            'Karyawan').toString();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', userId);
        await prefs.setString('employeeId', employeeId);
        await prefs.setString('fullName', fullName);
        if (token.isNotEmpty) {
          await prefs.setString('token', token);
        }
        if (refreshToken.isNotEmpty) {
          await prefs.setString('refreshToken', refreshToken);
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
      throw Exception('Gagal melakukan login: $errorMsg');
    }
  }

  /// Helper Ambil User ID (Tabel Users)
  static Future<String> getSavedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') ?? '';
  }

  /// Helper Ambil Refresh Token
  static Future<String?> getSavedRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refreshToken');
  }

/// Method Ubah Password (Menambahkan refreshToken ke Body Payload)
  static Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final token = await getSavedToken();
      final refreshToken = await getSavedRefreshToken() ?? '';

      var userId = await getSavedUserId();
      var employeeId = await getSavedEmployeeId();

      if (userId.isEmpty) {
        userId = employeeId;
      }

      // Payload lengkap dengan field refreshToken wajib untuk DTO NestJS
      final Map<String, dynamic> payload = {
        'id': userId,
        'userId': userId,
        'oldPassword': oldPassword,
        'currentPassword': oldPassword,
        'newPassword': newPassword,
        'confirmPassword': newPassword,
        'refreshToken': refreshToken, // <--- Field wajib dari validasi DTO backend
      };

      final Uri url = Uri.parse('$baseUrl/users/change-password');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          if (refreshToken.isNotEmpty) 'x-refresh-token': refreshToken,
        },
        body: jsonEncode(payload),
      );

      if (kDebugMode) {
        debugPrint('===> Change Password Request URL: $url');
        debugPrint('===> Change Password Request Payload: ${jsonEncode(payload)}');
        debugPrint('===> Change Password Status: ${response.statusCode}');
        debugPrint('===> Change Password Response: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final msg = body['message'];
        if (msg is List) {
          throw Exception(msg.join('\n'));
        }
        throw Exception(msg ?? 'Gagal mengubah kata sandi (Status: ${response.statusCode})');
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

  /// Fetch detail profil karyawan aktif dari Backend
  static Future<AccountProfile> fetchEmployeeDetail(String employeeId) async {
    try {
      String activeId = employeeId.trim();
      if (activeId.isEmpty) {
        activeId = await getSavedEmployeeId();
      }

      final token = await getSavedToken();

      if (kDebugMode) {
        debugPrint('===> Fetch Profile Employee ID: $activeId');
      }

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final response = await http
          .get(Uri.parse('$baseUrl/employees/$activeId'), headers: headers)
          .timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        debugPrint('===> Fetch Profile Response Status: ${response.statusCode}');
        debugPrint('===> Fetch Profile Response Body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final data = body['data'] ?? body;
        return AccountProfile.fromJson(data);
      } else {
        debugPrint('Fetch profile failed with status: ${response.statusCode}');
        throw Exception('Gagal mengambil profil dari server (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('Fetch profile error: $e');
      rethrow;
    }
  }

  /// Method Submit Absensi (Perbaikan Payload DTO)
  static Future<Map<String, dynamic>> submitAttendance({
    required String employeeId,
    required double latitude,
    required double longitude,
    required List<double> faceEmbedding,
    required String type,
  }) async {
    try {
      final activeEmployeeId = employeeId.isNotEmpty
          ? employeeId
          : await getSavedEmployeeId();

      final token = await getSavedToken();

      final Map<String, dynamic> bodyPayload = {
        'employeeId': activeEmployeeId,
        'locationId': '23ea7463-a1d0-4338-9023-002cb213d119',
        'latitude': latitude,
        'longitude': longitude,
        'faceEmbedding': faceEmbedding,
        'type': type,
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