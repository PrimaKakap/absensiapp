import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/employee.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.149:5000/api/v1';

  static Future<List<Employee>> fetchEmployees() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/employees'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Ambil array dari key 'data'
        List<dynamic> listData = jsonResponse['data'] ?? [];
      return listData
      .map((item) => Employee.fromJson(item as Map<String, dynamic>))
            .toList();
    
      } else {
        throw Exception('Gagal mengambil data karyawan');
      }
    } catch (e) {
      throw Exception('Error koneksi API: $e');
    }
  }
}