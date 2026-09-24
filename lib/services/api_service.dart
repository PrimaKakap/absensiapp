import 'dart:convert'; // Pastikan import baku 'dart:convert'
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

  /// Method Payload Clock In & Clock Out
  static Future<Map<String, dynamic>> submitAttendance({
    required String employeeId,
    required double latitude,
    required double longitude,
    required List<double> faceEmbedding,
    required String type, // 'CLOCK_IN' atau 'CLOCK_OUT'
  }) async {
    try {
      final isClockIn = type == 'CLOCK_IN';
      final nowIso = DateTime.now().toUtc().toIso8601String();

      /// Payload JSON disesuaikan dengan aturan NOT NULL DB Diagram
      final Map<String, dynamic> bodyPayload = {
        'employeeId': employeeId,
        'shiftId': 'ae3a5d82-4fc2-4e94-b4ab-7e4469093be3',
        'locationId': 'ae3a5d82-4fc2-4e94-b4ab-7e4469093be3',
        'faceEmbedding': faceEmbedding,
        'type': type,
        'status': 'PRESENT',
        
        // FIELD WAJIB (NOT NULL): Selalu dikirim
        'latitudeIn': isClockIn ? latitude : 0.0,
        'longitudeIn': isClockIn ? longitude : 0.0,
        'photoInUrl': 'https://example.com/photo_in.jpg',

        // FIELD OPTIONAL (NULLABLE): Dikirim khusus saat Clock Out
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
        // Tampilkan pesan error spesifik dari Class Validator NestJS
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