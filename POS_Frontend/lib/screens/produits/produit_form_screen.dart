import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../models/fournisseur.dart';
import '../../models/produit.dart';
import '../../providers/categorie_provider.dart';
import '../../providers/produit_provider.dart';
import '../../services/fournisseur_service.dart';

/// Écran : Ajouter / modifier un produit — cahier des charges §10.5
class ProduitFormScreen extends StatefulWidget {
  const ProduitFormScreen({super.key});

  @override
  State<ProduitFormScreen> createState() => _ProduitFormScreenState();
}

class _ProduitFormScreenState extends State<ProduitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FournisseurService _fournisseurService = FournisseurService();

  Produit? _produitExistant;
  bool _initialise = false;
  bool _enregistrement = false;

  final _codeCtrl = TextEditingController();
  final _codeBarresCtrl = TextEditingController();
  final _nomCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _prixAchatCtrl = TextEditingController();
  final _prixVenteCtrl = TextEditingController();
  final _contenanceCtrl = TextEditingController();
  final _stockMinimumCtrl = TextEditingController(text: '0');

  int? _categorie;
  int? _fournisseur;
  bool _actif = true;

  String? _image;
  List<Fournisseur> _fournisseurs = [];
  bool _chargementFournisseurs = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialise) {
      _initialise = true;
      final arg = ModalRoute.of(context)?.settings.arguments;
      if (arg is Produit) {
        _produitExistant = arg;
        _codeCtrl.text = arg.code;
        _codeBarresCtrl.text = arg.codeBarres ?? '';
        _nomCtrl.text = arg.nom;
        _descriptionCtrl.text = arg.description ?? '';
        _prixAchatCtrl.text = arg.prixAchat.toStringAsFixed(0);
        _prixVenteCtrl.text = arg.prixVente.toStringAsFixed(0);
        _contenanceCtrl.text = arg.contenance ?? '';
        _stockMinimumCtrl.text = arg.stockMinimum.toString();
        _categorie = arg.categorie;
        _fournisseur = arg.fournisseur;
        _actif = arg.actif;
        _image = arg.image;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<CategorieProvider>().chargerCategories();
      });
      _chargerFournisseurs();
    }
  }

  Future<void> _chargerFournisseurs() async {
    try {
      final liste = await _fournisseurService.getAll();
      if (mounted) setState(() { _fournisseurs = liste; _chargementFournisseurs = false; });
    } catch (_) {
      if (mounted) setState(() => _chargementFournisseurs = false);
    }
  }

  Future<void> _choisirImage() async {
    final picker = ImagePicker();
    final fichier = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (fichier == null) return;

    final Uint8List octets = await fichier.readAsBytes();
    setState(() => _image = base64Encode(octets));
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categorie == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisissez une catégorie'), backgroundColor: AppColors.rouge),
      );
      return;
    }

    setState(() => _enregistrement = true);

    final produit = Produit(
      idProduit: _produitExistant?.idProduit ?? 0,
      code: _codeCtrl.text.trim(),
      codeBarres: _codeBarresCtrl.text.trim().isEmpty ? null : _codeBarresCtrl.text.trim(),
      nom: _nomCtrl.text.trim(),
      description: _descriptionCtrl.text.trim().isEmpty ? null : _descriptionCtrl.text.trim(),
      prixAchat: double.parse(_prixAchatCtrl.text.trim()),
      prixVente: double.parse(_prixVenteCtrl.text.trim()),
      contenance: _contenanceCtrl.text.trim().isEmpty ? null : _contenanceCtrl.text.trim(),
      stockMinimum: int.parse(_stockMinimumCtrl.text.trim()),
      actif: _actif,
      categorie: _categorie!,
      fournisseur: _fournisseur,
      image: _image,
    );

    try {
      final provider = context.read<ProduitProvider>();
      if (_produitExistant != null) {
        await provider.modifier(_produitExistant!.idProduit, produit);
      } else {
        await provider.creer(produit);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: AppColors.rouge),
        );
      }
    } finally {
      if (mounted) setState(() => _enregistrement = false);
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _codeBarresCtrl.dispose();
    _nomCtrl.dispose();
    _descriptionCtrl.dispose();
    _prixAchatCtrl.dispose();
    _prixVenteCtrl.dispose();
    _contenanceCtrl.dispose();
    _stockMinimumCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategorieProvider>().categories;
    final modification = _produitExistant != null;

    return Scaffold(
      appBar: AppBar(title: Text(modification ? 'Modifier le produit' : 'Ajouter un produit')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: GestureDetector(
                onTap: _choisirImage,
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.fond,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0x1A000000)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _image != null
                          ? Image.memory(base64Decode(_image!), fit: BoxFit.cover)
                          : const Icon(Icons.add_a_photo_outlined, size: 32, color: AppColors.texteClair),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: AppColors.orange, shape: BoxShape.circle),
                        child: const Icon(Icons.edit, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nomCtrl,
              decoration: const InputDecoration(labelText: 'Nom du produit'),
              validator: (v) => Validators.requis(v, champ: 'Le nom'),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _codeCtrl,
                    decoration: const InputDecoration(labelText: 'Code produit'),
                    validator: (v) => Validators.requis(v, champ: 'Le code'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _codeBarresCtrl,
                    decoration: const InputDecoration(labelText: 'Code-barres (optionnel)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _descriptionCtrl,
              decoration: const InputDecoration(labelText: 'Description (optionnel)'),
              maxLines: 2,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _prixAchatCtrl,
                    decoration: const InputDecoration(labelText: 'Prix d\'achat (FCFA)'),
                    keyboardType: TextInputType.number,
                    validator: (v) => Validators.nombrePositif(v, champ: 'Le prix d\'achat'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _prixVenteCtrl,
                    decoration: const InputDecoration(labelText: 'Prix de vente (FCFA)'),
                    keyboardType: TextInputType.number,
                    validator: (v) => Validators.nombrePositif(v, champ: 'Le prix de vente'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _contenanceCtrl,
                    decoration: const InputDecoration(labelText: 'Contenance (ex: 65cl)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _stockMinimumCtrl,
                    decoration: const InputDecoration(labelText: 'Stock minimum'),
                    keyboardType: TextInputType.number,
                    validator: (v) => Validators.nombrePositif(v, champ: 'Le stock minimum'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<int>(
              initialValue: _categorie,
              decoration: const InputDecoration(labelText: 'Catégorie'),
              items: [
                for (final c in categories) DropdownMenuItem(value: c.idCategorie, child: Text(c.nom)),
              ],
              onChanged: (v) => setState(() => _categorie = v),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<int?>(
              initialValue: _fournisseur,
              decoration: InputDecoration(
                labelText: 'Fournisseur (optionnel)',
                suffixIcon: _chargementFournisseurs
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : null,
              ),
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text('Aucun')),
                for (final f in _fournisseurs) DropdownMenuItem<int?>(value: f.idFournisseur, child: Text(f.raisonSociale)),
              ],
              onChanged: (v) => setState(() => _fournisseur = v),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Produit actif'),
              subtitle: const Text('Visible dans le catalogue du POS', style: TextStyle(fontSize: 12)),
              value: _actif,
              onChanged: (v) => setState(() => _actif = v),
              activeThumbColor: AppColors.vert,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _enregistrement ? null : _enregistrer,
                child: _enregistrement
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(modification ? 'Enregistrer les modifications' : 'Ajouter le produit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
