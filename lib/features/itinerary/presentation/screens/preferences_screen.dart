import 'package:flutter/material.dart';
import 'package:flutter_app/core/itinerary_exceptions.dart';
import 'package:flutter_app/data/repositories/catalog_repository.dart';
import 'package:flutter_app/data/repositories/preference_repository.dart';
import 'package:flutter_app/shared/models/member_preference.dart';
import 'package:flutter_app/shared/models/user_role.dart';
import 'package:flutter_app/shared/widgets/error_view.dart';
import 'package:flutter_app/shared/widgets/loading_view.dart';
import 'package:flutter_app/validators/preference_rules.dart';

/// Datos que necesita la pantalla: categorías del catálogo y resumen.
class _PreferencesData {
  final List<String> categories;
  final PreferencesSummary summary;

  const _PreferencesData({required this.categories, required this.summary});
}

/// Preferencias de los miembros. El miembro elige sus categorías favoritas y
/// deja una nota; todos los roles ven el resumen del grupo para planear.
class PreferencesScreen extends StatefulWidget {
  final String uid;
  final UserRole role;
  final CatalogRepository catalogRepo;
  final PreferenceRepository preferenceRepo;

  const PreferencesScreen({
    super.key,
    required this.uid,
    required this.role,
    required this.catalogRepo,
    required this.preferenceRepo,
  });

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _noteController = TextEditingController();
  final Set<String> _selected = <String>{};
  late Future<_PreferencesData> _future;
  bool _saving = false;

  bool get _canEdit => widget.role == UserRole.member;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<_PreferencesData> _load() async {
    final categories = await widget.catalogRepo.getCategories();
    final summary = await widget.preferenceRepo.loadSummary(widget.uid);
    // Si la pantalla se cerró mientras cargaba, el controller ya fue liberado.
    if (mounted) {
      _fillForm(summary.mine);
    }
    return _PreferencesData(categories: categories, summary: summary);
  }

  /// Pone en el formulario lo que el miembro ya había guardado.
  void _fillForm(MemberPreference? mine) {
    _selected.clear();
    if (mine == null) return;
    _selected.addAll(mine.favoriteCategories);
    _noteController.text = mine.note;
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  void _toggleCategory(String category, bool selected) {
    setState(() {
      if (selected) {
        _selected.add(category);
      } else {
        _selected.remove(category);
      }
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() => _saving = true);
    try {
      await widget.preferenceRepo.save(
        uid: widget.uid,
        categories: _selected.toList(),
        note: _noteController.text,
      );
      if (!mounted) return;
      _showMessage('Preferencias guardadas');
      _reload();
    } on ItineraryException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ---------- Mis preferencias (solo miembros) ----------

  Widget _buildCategoryChips(List<String> categories) {
    final chips = <Widget>[];
    for (final category in categories) {
      chips.add(
        FilterChip(
          label: Text(category),
          selected: _selected.contains(category),
          onSelected: _saving
              ? null
              : (selected) => _toggleCategory(category, selected),
        ),
      );
    }
    return Wrap(spacing: 8, runSpacing: 8, children: chips);
  }

  Widget _buildSaveButton() {
    Widget icon = const Icon(Icons.save_outlined);
    if (_saving) {
      icon = const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return FilledButton.icon(
      // Mientras se guarda el botón queda deshabilitado: evita envíos repetidos.
      onPressed: _saving ? null : _save,
      icon: icon,
      label: const Text('Guardar preferencias'),
    );
  }

  Widget _buildMyPreferences(List<String> categories) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Mis preferencias', style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                'Elige hasta ${PreferenceRules.maxCategories} tipos de '
                'actividad que te gustaría hacer en el viaje.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              _buildCategoryChips(categories),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                enabled: !_saving,
                maxLines: 3,
                maxLength: PreferenceRules.maxNoteLength,
                validator: PreferenceRules.validateNote,
                decoration: const InputDecoration(
                  labelText: 'Nota para la coordinación (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Resumen del grupo (todos los roles) ----------

  Widget _buildGroupSummary(PreferencesSummary summary) {
    final theme = Theme.of(context);
    final rows = <Widget>[];
    for (final count in summary.groupCounts) {
      rows.add(
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.favorite_border),
          title: Text(count.category),
          trailing: Text('${count.members} miembro(s)'),
        ),
      );
    }
    if (rows.isEmpty) {
      rows.add(const Text('Todavía nadie ha registrado preferencias.'));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Preferencias del grupo', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              '${summary.membersWithPreferences} miembro(s) han respondido.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            ...rows,
          ],
        ),
      ),
    );
  }

  Widget _buildContent(_PreferencesData data) {
    final children = <Widget>[];
    if (_canEdit) {
      children.add(_buildMyPreferences(data.categories));
    }
    children.add(_buildGroupSummary(data.summary));

    return ListView(padding: const EdgeInsets.all(16), children: children);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_PreferencesData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingView();
        }

        final data = snapshot.data;
        if (snapshot.hasError || data == null) {
          return ErrorView(
            message:
                'No se pudieron cargar las preferencias. '
                'Revisa tu conexión e intenta de nuevo.',
            retryLabel: 'Reintentar',
            onRetry: _reload,
          );
        }

        return _buildContent(data);
      },
    );
  }
}
