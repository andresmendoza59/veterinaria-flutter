import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/core/formatters.dart';
import 'package:flutter_app/core/itinerary_exceptions.dart';
import 'package:flutter_app/core/trip_config.dart';
import 'package:flutter_app/data/repositories/itinerary_repository.dart';
import 'package:flutter_app/shared/models/catalog_activity.dart';
import 'package:flutter_app/shared/models/itinerary_activity.dart';
import 'package:flutter_app/validators/itinerary_rules.dart';

class ProposalFormScreen extends StatefulWidget {
  final String uid;
  final ItineraryRepository itineraryRepo;
  final ValueNotifier<int> refresh;
  final CatalogActivity? option;
  final ItineraryActivity? existing;

  const ProposalFormScreen({
    super.key,
    required this.uid,
    required this.itineraryRepo,
    required this.refresh,
    this.option,
    this.existing,
  }) : assert(option != null || existing != null);

  @override
  State<ProposalFormScreen> createState() => _ProposalFormScreenState();
}

class _ProposalFormScreenState extends State<ProposalFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _costController = TextEditingController();
  DateTime? _day;
  int? _hour;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    final option = widget.option;
    if (existing != null) {
      _costController.text = existing.estimatedCost.toString();
      for (final day in TripConfig.days) {
        if (_sameDay(day, existing.startAt)) {
          _day = day;
        }
      }
      if (TripConfig.slotStartHours.contains(existing.startAt.hour)) {
        _hour = existing.startAt.hour;
      }
    } else if (option != null) {
      _costController.text = option.estimatedCost.toString();
    }
  }

  @override
  void dispose() {
    _costController.dispose();
    super.dispose();
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String get _title => widget.existing?.title ?? widget.option?.name ?? '';

  String get _category =>
      widget.existing?.category ?? widget.option?.category ?? '';

  String get _location =>
      widget.existing?.location ?? widget.option?.location ?? '';

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final day = _day;
    final hour = _hour;
    if (day == null || hour == null) {
      _showMessage('Elige un día y una franja');
      return;
    }

    final cost = ItineraryRules.parseCost(_costController.text);
    if (cost == null) return;

    final startAt = TripConfig.slotStart(day, hour);
    final existing = widget.existing;
    final option = widget.option;

    setState(() => _saving = true);

    try {
      final ItineraryActivity saved;
      if (existing != null) {
        saved = await widget.itineraryRepo.editProposal(
          uid: widget.uid,
          activity: existing,
          startAt: startAt,
          estimatedCost: cost,
        );
      } else if (option != null) {
        saved = await widget.itineraryRepo.createProposal(
          ownerUid: widget.uid,
          option: option,
          startAt: startAt,
          estimatedCost: cost,
        );
      } else {
        setState(() => _saving = false);
        return;
      }

      if (!mounted) return;
      widget.refresh.value++;
      _showMessage(
        saved.syncState == SyncState.synced
            ? 'Propuesta guardada y enviada'
            : 'Propuesta guardada. Se enviará cuando haya conexión',
      );
      if (existing != null) {
        Navigator.pop(context);
      } else {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } on ItineraryException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showMessage(e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showMessage('No se pudo guardar la propuesta. Intenta de nuevo');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final existing = widget.existing;
    final syncError = existing?.syncError ?? '';
    final referenceDay = _day ?? TripConfig.startDate;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          existing == null
              ? 'Proponer actividad'
              : existing.syncState == SyncState.rejected
                  ? 'Corregir propuesta'
                  : 'Editar propuesta',
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(_title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.category_outlined, size: 18),
                  label: Text(_category),
                ),
                Chip(
                  avatar: const Icon(Icons.place_outlined, size: 18),
                  label: Text(_location),
                ),
              ],
            ),
            if (syncError.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                color: theme.colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'No se aceptó al enviar: $syncError',
                    style: TextStyle(color: theme.colorScheme.onErrorContainer),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text('Día', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final day in TripConfig.days)
                  ChoiceChip(
                    label: Text(Fmt.date(day)),
                    selected: _day == day,
                    onSelected: _saving
                        ? null
                        : (_) => setState(() => _day = day),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Franja de 2 horas', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final hour in TripConfig.slotStartHours)
                  ChoiceChip(
                    label: Text(
                      Fmt.slotLabel(TripConfig.slotStart(referenceDay, hour)),
                    ),
                    selected: _hour == hour,
                    onSelected: _saving
                        ? null
                        : (_) => setState(() => _hour = hour),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _costController,
              enabled: !_saving,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: ItineraryRules.validateCostText,
              decoration: const InputDecoration(
                labelText: 'Costo estimado (COP)',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'La propuesta no ocupa la franja ni gasta presupuesto hasta que '
              'sea aprobada.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: const Text('Guardar propuesta'),
            ),
          ],
        ),
      ),
    );
  }
}
