import 'dart:convert';

/// Exception levée par [ApiService] avec message extrait de la réponse DRF.
class ApiException implements Exception {
  ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => message;

  static ApiException fromResponse(int statusCode, String body) {
    var message = 'Erreur API $statusCode';
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        if (decoded['detail'] != null) {
          message = decoded['detail'].toString();
        } else {
          final parts = <String>[];
          decoded.forEach((key, value) {
            if (value is List) {
              parts.addAll(value.map((e) => e.toString()));
            } else {
              parts.add(value.toString());
            }
          });
          if (parts.isNotEmpty) message = parts.join('\n');
        }
      }
    } catch (_) {
      if (body.isNotEmpty) message = body;
    }
    return ApiException(statusCode, message);
  }
}
