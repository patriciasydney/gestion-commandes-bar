import 'package:flutter_test/flutter_test.dart';
import 'package:front_boisson/core/constants/depense_categories.dart';

void main() {
  group('DepenseCategories', () {
    test('normalise les anciens codes seed', () {
      expect(DepenseCategories.normaliser('electricite'), 'Charges fixes');
      expect(DepenseCategories.normaliser('eau'), 'Charges fixes');
      expect(DepenseCategories.normaliser('transport'), 'Carburant');
    });

    test('filtre par catégorie normalisée', () {
      expect(
        DepenseCategories.correspondFiltre('electricite', 'Charges fixes'),
        isTrue,
      );
      expect(
        DepenseCategories.correspondFiltre('transport', 'Carburant'),
        isTrue,
      );
      expect(
        DepenseCategories.correspondFiltre('electricite', 'Carburant'),
        isFalse,
      );
    });
  });
}
