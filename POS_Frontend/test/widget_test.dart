import 'package:flutter_test/flutter_test.dart';
import 'package:front_boisson/core/constants/api_constants.dart';

void main() {
  test('ApiConstants pointe vers le backend réel', () {
    expect(ApiConstants.modeDemo, isFalse);
    expect(ApiConstants.baseUrl, contains('localhost:8000'));
    expect(ApiConstants.dashboard, '/dashboard/summary/');
    expect(ApiConstants.reportsAchats, '/reports/achats/');
  });
}
