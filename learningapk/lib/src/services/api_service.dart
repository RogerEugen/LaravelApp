import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => message;
}

class ApiService {
  ApiService({
    this.baseUrl = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://10.0.2.2:8000/api/v1',
    ),
  });

  final String baseUrl;
  String? token;

  Future<Map<String, dynamic>> get(String path) => _request('GET', path);

  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, dynamic>? body,
  ]) => _request('POST', path, body);

  Future<Map<String, dynamic>> put(String path, [Map<String, dynamic>? body]) =>
      _request('PUT', path, body);

  Future<Map<String, dynamic>> patch(
    String path, [
    Map<String, dynamic>? body,
  ]) => _request('PATCH', path, body);

  Future<Map<String, dynamic>> delete(String path) => _request('DELETE', path);

  Future<Map<String, dynamic>> postForm(
    String path,
    Map<String, String> body,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: body,
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        json['message']?.toString() ?? 'Realtime authorization imeshindikana.',
        statusCode: response.statusCode,
      );
    }
    return json;
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      late http.Response response;
      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: headers);
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: jsonEncode(body ?? {}),
          );
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: jsonEncode(body ?? {}),
          );
        case 'PATCH':
          response = await http.patch(
            uri,
            headers: headers,
            body: jsonEncode(body ?? {}),
          );
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
        default:
          throw ApiException('HTTP method haitambuliwi.');
      }
      response = await Future.value(
        response,
      ).timeout(const Duration(seconds: 20));
      final json = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final errors = json['errors'];
        var message = json['message']?.toString() ?? 'Ombi halikufanikiwa.';
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) {
            message = first.first.toString();
          }
        }
        throw ApiException(message, statusCode: response.statusCode);
      }
      return json;
    } on SocketException {
      throw ApiException(
        'Server haipatikani. Hakikisha Laravel imewashwa na API ni sahihi.',
      );
    } on FormatException {
      throw ApiException('Server imerudisha taarifa zisizoeleweka.');
    }
  }
}
