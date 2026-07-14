import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_helpers.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

/// Écran de connexion — cahier des charges §10.2
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomUtilisateurController = TextEditingController();
  final _motDePasseController = TextEditingController();

  @override
  void dispose() {
    _nomUtilisateurController.dispose();
    _motDePasseController.dispose();
    super.dispose();
  }

  Future<void> _seConnecter() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final succes = await auth.connecter(
      _nomUtilisateurController.text.trim(),
      _motDePasseController.text,
    );

    if (succes && mounted) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.erreur ?? "Erreur de connexion")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/logo_atsys.png',
                        height: 96,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.local_bar, size: 48, color: AppColors.orange),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "ATSYS_POS",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: ThemeHelpers.accent(context),
                            ),
                      ),
                      Text(
                        "Système de gestion des débits de boissons",
                        style: ThemeHelpers.mutedTextStyle(context, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      AppTextField(
                        label: "Nom d'utilisateur",
                        controller: _nomUtilisateurController,
                        validator: (v) => Validators.requis(v, champ: "Le nom d'utilisateur"),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: "Mot de passe",
                        controller: _motDePasseController,
                        motDePasse: true,
                        validator: Validators.motDePasse,
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        label: "Se connecter",
                        chargement: auth.chargement,
                        onPressed: _seConnecter,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
