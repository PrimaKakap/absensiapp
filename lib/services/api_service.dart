import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/employee.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.149:5000/api/v1';

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

  /// Method baru untuk Mengirim Payload Absensi ke NestJS
  static Future<Map<String, dynamic>> submitAttendance({
    required String employeeId,
    required double latitude,
    required double longitude,
    required List<double> faceEmbedding,
    required String type, // 'CLOCK_IN' atau 'CLOCK_OUT'
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/attendance'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'employee_id': employeeId,
              'latitude': latitude,
              'longitude': longitude,
              'type': type,
              'face_embedding': faceEmbedding, // Array Vektor 128-D
            }),
          )
          .timeout(const Duration(seconds: 15));

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Gagal melakukan absensi');
      }
    } catch (e) {
      throw Exception('Gagal menghubungi server absensi: $e');
    }
  }
}