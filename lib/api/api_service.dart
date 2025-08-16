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

  static Future<dynamic> postMultipart(
    String endpoint, {
    required Map<String, String> fields,
    required File file,
    String fileField = 'file',
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final request = http.MultipartRequest('POST', url);

      // add normal fields
      request.fields.addAll(fields);

      // add file
      request.files.add(await http.MultipartFile.fromPath(fileField, file.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Multipart POST failed: ${response.statusCode} - ${response.body}");
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
