import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/employee.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.149:5000/api/v1';

  static Future<List<Employee>> fetchEmployees() async {
    try {
      // timeout 30 second
final response = await http
    .get(Uri.parse('$baseUrl/users'))
    .timeout(const Duration(seconds: 15)); 

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> body = jsonDecode(response.body);

        return body.map((dynamic item) => Employee.fromJson(item)).toList();
            // .map((item) => Employee.fromJson(item as Map<String, dynamic>))
            // .toList();
      } else {
        throw Exception('Gagal mengambil data karyawan (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error koneksi API: $e');
    }
  }
}