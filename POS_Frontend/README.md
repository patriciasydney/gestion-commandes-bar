# POS Frontend — Débits de Boissons

Application Flutter (Provider + http) connectée au backend Django REST.

## Démarrage

```bash
cd POS_Frontend
flutter pub get
flutter run -d chrome
```

Backend requis sur `http://localhost:8000` — voir [`../POS_Backend/docs/FRONTEND_INTEGRATION.md`](../POS_Backend/docs/FRONTEND_INTEGRATION.md).

Compte dev : `admin` / `admin123`

## Tests

```bash
flutter test
flutter analyze
```

## Documentation

- [`docs/guide-front.md`](docs/guide-front.md) — guide équipe Flutter
- [`../POS_Backend/docs/FRONTEND_INTEGRATION.md`](../POS_Backend/docs/FRONTEND_INTEGRATION.md) — contrats API
- [`../POS_Backend/docs/E2E_CHECKLIST.md`](../POS_Backend/docs/E2E_CHECKLIST.md) — checklist E2E
