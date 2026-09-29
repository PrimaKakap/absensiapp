import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/employee.dart';
import '../models/account_profile.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.149:5000/api/v1';

  /// Service Bypass Login Sementara
  static Future<void> loginBypass() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Gunakan UUID employee yang terbukti sukses absensi sebelumnya
    await prefs.setString('employeeId', 'e29bb03b-825d-41cb-a6c3-493d63b1cb00');
    await prefs.setString('fullName', 'John Doe');
    await prefs.setBool('isLoggedIn', true);
  }

/// Service Login (Target Langsung Endpoint /users/login)
  static Future<bool> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/users/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'companyEmail': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        final data = responseData['data'] ?? responseData;
        final user = data['user'] ?? data;
        final employee = data['employee'] ?? user['employee'] ?? {};
        final profile = user['employeeProfile'] ?? {};

        // Ekstraksi Employee ID
        final String employeeId = employee['id'] ??
            data['employeeId'] ??
            user['employeeId'] ??
            '';

        final String fullName = profile['fullName'] ??
            user['companyEmail'] ??
            'Karyawan';

        final String token = responseData['accessToken'] ??
            responseData['token'] ??
            data['token'] ??
            '';

        // Simpan ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('employeeId', employeeId);
        await prefs.setString('fullName', fullName);
        await prefs.setString('token', token);
        await prefs.setBool('isLoggedIn', true);

        return true;
      } else {
        final errorData = jsonDecode(response.body);
        final msg = errorData['message'];
        if (msg is List) {
          throw Exception(msg.join('\n'));
        }
        throw Exception(msg ?? 'Login gagal (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Gagal melakukan login: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  /// Ambil Employee ID yang sedang tersimpan
  static Future<String> getSavedEmployeeId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('employeeId') ?? 'e29bb03b-825d-41cb-a6c3-493d63b1cb00';
  }

  /// Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<List<Employee>> fetchEmployees() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/employees'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> listData = body['data'];
        return listData.map((item) => Employee.fromJson(item)).toList();
      } else {
        throw Exception('Gagal mengambil data karyawan (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error koneksi API: $e');
    }
  }

  /// Fetch detail profil karyawan aktif berdasarkan ID
  static Future<AccountProfile> fetchEmployeeDetail(String employeeId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/employees/$employeeId'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final data = body['data'] ?? body;
        return AccountProfile.fromJson(data);
      } else {
        return _getDummyProfileDetail();
      }
    } catch (e) {
      return _getDummyProfileDetail();
    }
  }

  /// Fallback dummy berdasarkan data JSON John Doe dari backend
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

  /// Method Absensi menggunakan Dynamic Employee ID
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
      throw Exception('Gagal menghubungi server absensi: $e');
    }
  }
}