import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../core/utils/api_exception.dart';
import 'mock_data.dart';

/// Client HTTP partagé : centralise les appels GET/POST/PUT/DELETE,
/// le token JWT et la gestion des erreurs.
class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  factory ApiService() => instance;

  String? _token;

  String? get token => _token;

  void setToken(String? token) => _token = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<dynamic> get(String endpoint) async {
    if (ApiConstants.modeDemo) return MockApi.handle('GET', endpoint);
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: _headers,
    );
    return _traiter(response);
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    if (ApiConstants.modeDemo) return MockApi.handle('POST', endpoint, body: data);
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: _headers,
      body: jsonEncode(data),
    );
    return _traiter(response);
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    if (ApiConstants.modeDemo) return MockApi.handle('PUT', endpoint, body: data);
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: _headers,
      body: jsonEncode(data),
    );
    return _traiter(response);
  }

  Future<dynamic> delete(String endpoint) async {
    if (ApiConstants.modeDemo) return MockApi.handle('DELETE', endpoint);
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      headers: _headers,
    );
    return _traiter(response);
  }

  dynamic _traiter(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }
    throw ApiException.fromResponse(response.statusCode, response.body);
  }
}
