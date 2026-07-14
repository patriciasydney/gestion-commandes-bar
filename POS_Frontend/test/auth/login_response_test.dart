import 'package:flutter_test/flutter_test.dart';
import 'package:front_boisson/models/utilisateur.dart';

import '../fixtures/api_fixtures.dart';

void main() {
  group('Login response (SimpleJWT + utilisateur)', () {
    test('parse access, refresh et bloc utilisateur', () {
      final data = ApiFixtures.loginResponse;

      expect(data['access'], isNotEmpty);
      expect(data['refresh'], isNotEmpty);

      final utilisateur = Utilisateur.fromJson(
        data['utilisateur'] as Map<String, dynamic>,
      );

      expect(utilisateur.id, 1);
      expect(utilisateur.username, 'admin');
      expect(utilisateur.nomRole, 'Administrateur');
      expect(utilisateur.isAdministrateur, isTrue);
    });

    test('rejet si utilisateur absent du JSON', () {
      final data = {'access': 'token', 'refresh': 'refresh'};
      expect(data['utilisateur'], isNull);
    });
  });
}
