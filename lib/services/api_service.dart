import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/employee.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.149:5000/api/v1';

  static Future<List<Employee>> fetchEmployees() async {
    try {
      // timeout 30 second
final response = await http
    .get(Uri.parse('$baseUrl/employees'))
    .timeout(const Duration(seconds: 15)); 

    if (response.statusCode == 200) {
  final Map<String, dynamic> body = jsonDecode(response.body);
  final List<dynamic> listData = body['data']; // Karena /employees dibungkus dalam "data": [...]
  return listData.map((item) => Employee.fromJson(item)).toList();

      // if (response.statusCode == 200 || response.statusCode == 201) {
      //   final List<dynamic> body = jsonDecode(response.body);
      //   return body.map((dynamic item) => Employee.fromJson(item)).toList();
           
      } else {
        throw Exception('Gagal mengambil data karyawan (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error koneksi API: $e');
    }
  }
}