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
    _normalizeUrls(json);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        json['message']?.toString() ?? 'Realtime authorization imeshindikana.',
        statusCode: response.statusCode,
      );
    }
    return json;
  }

  Future<Map<String, dynamic>> uploadProfilePhoto(File photo) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/profile'),
    );
    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });
    request.files.add(
      await http.MultipartFile.fromPath('profile_photo', photo.path),
    );
    final streamed = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamed);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    _normalizeUrls(json);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        json['message']?.toString() ?? 'Profile photo upload failed.',
        statusCode: response.statusCode,
      );
    }
    return json;
  }

  Future<Map<String, dynamic>> postMultipart(
    String path,
    Map<String, String> fields, {
    File? file,
    String fileField = 'video',
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$path'));
    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });
    request.fields.addAll(fields);
    if (file != null) {
      request.files.add(
        await http.MultipartFile.fromPath(fileField, file.path),
      );
    }
    final streamed = await request.send().timeout(const Duration(seconds: 60));
    final response = await http.Response.fromStream(streamed);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    _normalizeUrls(json);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        json['message']?.toString() ?? 'Upload failed.',
        statusCode: response.statusCode,
      );
    }
    return json;
  }

  String absoluteUrl(String path) {
    final origin = Uri.parse(baseUrl).origin;
    return '$origin${path.startsWith('/') ? path : '/$path'}';
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
      _normalizeUrls(json);

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

  void _normalizeUrls(dynamic value) {
    if (value is Map) {
      for (final entry in value.entries.toList()) {
        if (entry.key == 'profile_photo_url' &&
            entry.value is String &&
            (entry.value as String).startsWith('/')) {
          value[entry.key] = absoluteUrl(entry.value as String);
        } else {
          _normalizeUrls(entry.value);
        }
      }
    } else if (value is List) {
      for (final item in value) {
        _normalizeUrls(item);
      }
    }
  }
}
