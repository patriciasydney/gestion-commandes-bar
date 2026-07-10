# Guide de programmation — POS Frontend (Flutter)

**Emplacement monorepo :** `gestion-commandes-bar/POS_Frontend/`

Ce guide sert de référence d'installation et de feuille de route pour l'équipe. Cochez les cases (`[x]`) au fur et à mesure de l'avancement et committez ce fichier régulièrement pour que tout le monde suive la progression.

---

## 1. Installation (à faire une seule fois, par personne)

### 1.1 Installer Flutter

```bash
# Cloner le SDK Flutter (channel stable)
git clone https://github.com/flutter/flutter.git -b stable ~/flutter

# Ajouter Flutter au PATH (ajouter cette ligne dans ~/.bashrc ou ~/.zshrc)
export PATH="$PATH:$HOME/flutter/bin"

# Recharger le shell
source ~/.bashrc
```

### 1.2 Vérifier l'installation

```bash
flutter --version
flutter doctor
```

`flutter doctor` doit afficher au minimum :
- `[✓] Flutter`
- `[✓] Chrome` (suffisant pour développer en web, pas besoin d'Android Studio pour l'instant)

Si `flutter doctor` reste bloqué longtemps sans rien afficher : c'est probablement un `git fetch` lent en arrière-plan (connexion limitée), pas un vrai blocage. Relancez avec `flutter --version -v` pour voir le détail, et laissez tourner plusieurs minutes avant d'interrompre.

### 1.3 Éditeur recommandé

VS Code avec l'extension **Flutter** (installe automatiquement l'extension Dart). Alternative : Android Studio avec le plugin Flutter.

- [ ] Flutter installé et `flutter doctor` propre (ou warnings mineurs uniquement)
- [ ] Éditeur configuré avec l'extension Flutter/Dart

---

## 2. Récupérer le projet (monorepo)

```bash
# 1. Cloner le monorepo (ou git pull si déjà cloné)
git clone <url-du-monorepo-gestion-commandes-bar>.git
cd gestion-commandes-bar/POS_Frontend

# 2. Installer les dépendances déclarées dans pubspec.yaml (provider, http, etc.)
flutter pub get

# 3. Vérifier les appareils disponibles
flutter devices

# 4. Lancer l'application (web = le plus rapide pour développer en groupe)
flutter run -d chrome
```

Pendant que `flutter run` tourne, dans le même terminal :

| Touche | Action |
|---|---|
| `r` | Hot reload — recharge le code modifié en gardant l'état de l'app |
| `R` | Hot restart — redémarre l'app depuis zéro (utile après un changement de structure) |
| `q` | Quitter |

- [ ] Chaque membre de l'équipe a cloné le repo et lancé l'app avec succès

---

## 3. Workflow Git de l'équipe

Pour éviter les conflits, chaque membre travaille sur sa propre branche et ne touche qu'aux fichiers de son module.

```bash
# Avant de commencer à coder, se mettre à jour
git checkout main
git pull origin main

# Créer une branche pour la fonctionnalité en cours
git checkout -b feature/dashboard
# ou : feature/login, feature/pos, feature/produits, feature/stocks...

# Après avoir codé, ajouter et committer
git add .
git commit -m "feat(dashboard): ajout des cartes statistiques"

# Pousser la branche
git push origin feature/dashboard
```

Ensuite, ouvrir une Pull Request sur GitHub vers `main` pour que le reste de l'équipe relise avant fusion.

**Règle importante** : ne jamais committer les dossiers `build/` et `.dart_tool/` (déjà exclus par le `.gitignore` généré par Flutter — à vérifier une fois avec `cat .gitignore`).

- [ ] Convention de nommage des branches définie et suivie
- [ ] `.gitignore` vérifié (`build/`, `.dart_tool/` bien exclus)

---

## 4. Commandes Flutter utiles au quotidien

```bash
flutter pub get              # installe/synchronise les dépendances
flutter pub add <package>    # ajoute une nouvelle dépendance à pubspec.yaml
flutter clean                # nettoie le cache si un bug étrange apparaît après un pull
flutter analyze              # vérifie le code (erreurs, style) avant de committer
flutter test                 # lance les tests automatisés (dossier test/)
dart run flutter_launcher_icons   # régénère les icônes de l'app (si configuré)
```

En cas de comportement bizarre après un `git pull` (erreurs qui n'ont pas de sens) :

```bash
flutter clean
flutter pub get
flutter run -d chrome
```

---

## 5. Architecture du projet (rappel rapide)

```
lib/
├── main.dart          → point d'entrée, branche le thème et les Providers
├── core/               → thème (app_colors.dart, app_theme.dart), constantes API, utils
├── models/              → une classe Dart par table PostgreSQL (Produit, Vente, Client...)
├── services/             → appels HTTP vers l'API Django (un fichier par module)
├── providers/             → état partagé de l'app (auth, dashboard, panier, stocks)
├── screens/                → un dossier par écran du cahier des charges (10.2 à 10.9)
├── widgets/                 → composants réutilisables (boutons, cartes, tuiles)
└── routes/                   → déclaration des routes nommées
```

Flux de données : `screens/` → lit un `providers/` → qui appelle un `services/` → qui appelle l'API Django → JSON converti en `models/`.

---

## 6. Charte graphique (à respecter dans tous les écrans)

| Rôle | Couleur | Code hex |
|---|---|---|
| Principale (navigation, en-têtes) | Bleu foncé | `#0D1B4C` |
| Secondaire (actions principales) | Orange | `#FF7A00` |
| Validation | Vert | `#2ECC71` |
| Alerte | Jaune | `#F1C40F` |
| Erreur | Rouge | `#E74C3C` |
| Fond | Blanc / gris très clair | `#F5F6FA` |

Ces couleurs sont centralisées dans `lib/core/theme/app_colors.dart` — ne jamais coder une couleur en dur dans un écran, toujours référencer `AppColors.xxx`.

---

## 7. Plan de développement — Session du jour

### Objectif du jour : Base (thème + auth) et Tableau de bord

- [ ] **Étape 1 — Thème**
  - [ ] `lib/core/theme/app_colors.dart` codé
  - [ ] `lib/core/theme/app_theme.dart` codé
  - [ ] Thème branché dans `main.dart` (`MaterialApp(theme: AppTheme.theme)`)

- [ ] **Étape 2 — Authentification**
  - [ ] `lib/models/utilisateur.dart` (fromJson/toJson)
  - [ ] `lib/services/api_service.dart` (client HTTP de base)
  - [ ] `lib/services/auth_service.dart` (login/logout)
  - [ ] `lib/providers/auth_provider.dart` (ChangeNotifier)
  - [ ] `lib/screens/auth/login_screen.dart` (formulaire + validation)
  - [ ] Provider branché dans `main.dart` (`MultiProvider`)
  - [ ] Test : connexion réussie redirige vers le dashboard

- [ ] **Étape 3 — Tableau de bord**
  - [ ] `lib/services/dashboard_service.dart` (appel API stats du jour)
  - [ ] `lib/providers/dashboard_provider.dart`
  - [ ] `lib/widgets/dashboard/stat_card.dart` (composant réutilisable)
  - [ ] `lib/screens/dashboard/dashboard_screen.dart` (assemblage)
  - [ ] Test : les chiffres (CA, ventes, alertes stock) s'affichent après connexion

### Prochaines sessions (non prioritaire aujourd'hui)

- [ ] **Interface de vente (POS)** — écran 10.4
  - [ ] `lib/models/vente.dart`, `lib/models/detail_vente.dart`, `lib/models/paiement.dart`
  - [ ] `lib/services/vente_service.dart` (créer vente, encaisser paiement)
  - [ ] `lib/providers/panier_provider.dart` (articles du panier, total, remise)
  - [ ] `lib/providers/produit_provider.dart` (catalogue + recherche/scan code-barres)
  - [ ] `lib/widgets/pos/product_card.dart` (carte produit du catalogue)
  - [ ] `lib/widgets/pos/cart_item_tile.dart` (ligne d'article dans le panier)
  - [ ] `lib/screens/pos/pos_screen.dart` (assemblage : recherche, catalogue, panier, paiement)
  - [ ] `lib/screens/clients/clients_screen.dart` (rattacher un client existant à la vente, optionnel)
  - [ ] Test : créer une vente, ajouter/retirer des articles, encaisser, impression du reçu (mock)

- [ ] **Gestion des produits** — écran 10.5
  - [ ] `lib/models/produit.dart`, `lib/models/categorie.dart`, `lib/models/fournisseur.dart`
  - [ ] `lib/services/produit_service.dart` (CRUD + recherche)
  - [ ] `lib/services/categorie_service.dart` (CRUD catégories)
  - [ ] `lib/providers/produit_provider.dart` (partagé avec le POS — liste, filtres, recherche)
  - [ ] `lib/screens/produits/produits_screen.dart` (tableau + recherche + filtre catégorie)
  - [ ] `lib/screens/produits/produit_form_screen.dart` (formulaire ajout/modification)
  - [ ] `lib/screens/categories/categories_screen.dart` (CRUD catégories)
  - [ ] `lib/screens/fournisseurs/fournisseurs_screen.dart` (rattachement produit ↔ fournisseur)
  - [ ] Test : ajouter un produit, le voir apparaître dans le catalogue POS

- [ ] **Gestion des stocks** — écran 10.6
  - [ ] `lib/models/stock.dart`, `lib/models/mouvement_stock.dart`
  - [ ] `lib/services/stock_service.dart` (quantités, entrées/sorties, inventaire)
  - [ ] `lib/providers/stock_provider.dart` (état des stocks + alertes)
  - [ ] `lib/screens/stocks/stocks_screen.dart` (quantités, seuils, alertes rupture, historique)
  - [ ] `lib/screens/achats/achats_screen.dart` (réception livraison → mise à jour stock auto)
  - [ ] `lib/screens/depenses/depenses_screen.dart` (dépenses courantes, indépendant du stock)
  - [ ] Test : enregistrer une entrée de stock, vérifier la mise à jour de la quantité disponible

- [ ] **Gestion des utilisateurs (admin)** — écran 10.7
  - [ ] `lib/models/role.dart` (déjà couvert par `utilisateur.dart` de l'étape Auth)
  - [ ] `lib/services/utilisateur_service.dart` (CRUD comptes, attribution des rôles)
  - [ ] `lib/screens/utilisateurs/utilisateurs_screen.dart` (liste, ajout, modification, désactivation)
  - [ ] Test : uniquement visible/accessible si le rôle connecté est Administrateur

- [ ] **Rapports et statistiques** — écran 10.8
  - [ ] `lib/services/rapport_service.dart` (rapports jour/semaine/mois/année, export PDF/Excel)
  - [ ] `lib/screens/rapports/rapports_screen.dart` (sélection période, affichage, export)
  - [ ] Test : générer un rapport journalier et vérifier la cohérence avec le tableau de bord

- [ ] **Paramètres** — écran 10.9
  - [ ] `lib/screens/parametres/parametres_screen.dart` (infos entreprise, taxes, imprimantes, sauvegardes)
  - [ ] Test : modification d'un paramètre persistée côté API

---

## 8. Ressources

- Cours Flutter (PDF) : voir `cours_flutter.pdf` — bases Dart, widgets, Provider, appels API
- Documentation officielle Flutter : https://docs.flutter.dev
- Documentation Provider : https://pub.dev/packages/provider
- Cahier des charges : chapitre 10 (maquettes des écrans), chapitre 9 (schéma relationnel)

---

*Dernière mise à jour : à compléter à chaque session par la personne qui clôture le travail du jour.*
