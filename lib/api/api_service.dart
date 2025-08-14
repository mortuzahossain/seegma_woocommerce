import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://wordpress.test/wp-json';

  static Future<dynamic> get(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.get(url);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        return data;
      } else {
        final data = json.decode(response.body);

        throw Exception(data['message'] ?? 'API error');
      }
    } on SocketException {
      throw Exception('No Internet connection');
    } on HttpException catch (e) {
      throw Exception(e.message);
    } on FormatException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> post(String endpoint, {required Map<String, dynamic> body, Map<String, String>? headers}) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final defaultHeaders = {'Content-Type': 'application/json'};
      final allHeaders = {...defaultHeaders, ...?headers};

      final response = await http.post(url, headers: allHeaders, body: json.encode(body));
      // log(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        // log(data);
        return data;
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'API error');
      }
    } on SocketException {
      throw Exception('No Internet connection');
    } on HttpException catch (e) {
      throw Exception(e.message);
    } on FormatException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
