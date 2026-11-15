import 'package:flutter/material.dart';
import 'package:flutter_app/core/formatters.dart';
import 'package:flutter_app/core/trip_config.dart';
import 'package:flutter_app/data/repositories/itinerary_repository.dart';
import 'package:flutter_app/data/services/ui_preferences.dart';
import 'package:flutter_app/features/itinerary/presentation/widgets/activity_card.dart';
import 'package:flutter_app/features/itinerary/presentation/widgets/activity_list_view.dart';
import 'package:flutter_app/features/itinerary/presentation/widgets/budget_summary_card.dart';
import 'package:flutter_app/shared/models/activity_status.dart';
import 'package:flutter_app/shared/models/itinerary_activity.dart';
import 'package:flutter_app/shared/widgets/error_view.dart';
import 'package:flutter_app/shared/widgets/loading_view.dart';
import 'package:flutter_app/validators/activity_filters.dart';
import 'package:flutter_app/validators/itinerary_rules.dart';

/// Módulo de balance (alcance adicional del trío).
/// Muestra presupuesto total, costo reservado, gasto real y saldo disponible
/// a partir de los registros guardados en Drift, con filtros por categoría,
/// día y estado (confirmadas, realizadas, costo cerrado y canceladas).
/// El filtro de categoría se recuerda con SharedPreferences.
class BalanceScreen extends StatefulWidget {
  final String uid;
  final ItineraryRepository itineraryRepo;
  final UiPreferences uiPreferences;
  final ValueNotifier<int> refresh;

  const BalanceScreen({
    super.key,
    required this.uid,
    required this.itineraryRepo,
    required this.uiPreferences,
    required this.refresh,
  });

  @override
  State<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  // Estados que se pueden elegir en el filtro de estado.
  static const List<ActivityStatus> _statusOptions = [
    ActivityStatus.confirmed,
    ActivityStatus.done,
    ActivityStatus.costClosed,
    ActivityStatus.cancelled,
  ];

  late Future<ActivitiesResult> _future;

  // Filtros activos. null significa "todos".
  String? _category;
  DateTime? _day;
  ActivityStatus? _status;

  @override
  void initState() {
    super.initState();
    _future = widget.itineraryRepo.loadShared(uid: widget.uid);
    widget.refresh.addListener(_reload);
    _loadSavedCategory();
  }

  @override
  void dispose() {
    widget.refresh.removeListener(_reload);
    super.dispose();
  }

  Future<void> _loadSavedCategory() async {
    final saved = await widget.uiPreferences.getBalanceCategory(widget.uid);
    if (!mounted) return;
    setState(() => _category = saved);
  }

  void _reload() {
    if (!mounted) return;
    setState(() {
      _future = widget.itineraryRepo.loadShared(uid: widget.uid);
    });
  }

  Future<void> _onRefresh() async {
    _reload();
    try {
      await _future;
    } catch (_) {
      return;
    }
  }

  void _changeCategory(String? category) {
    setState(() => _category = category);
    // Se guarda para que el balance abra con el mismo filtro la próxima vez.
    widget.uiPreferences.saveBalanceCategory(widget.uid, category);
  }

  void _changeDay(DateTime? day) {
    setState(() => _day = day);
  }

  void _changeStatus(ActivityStatus? status) {
    setState(() => _status = status);
  }

  /// Aplica los tres filtros, uno detrás de otro.
  List<ItineraryActivity> _applyFilters(List<ItineraryActivity> balanceItems) {
    final byCategory = ActivityFilters.byCategory(balanceItems, _category);
    final byDay = ActivityFilters.byDay(byCategory, _day);
    final byStatus = ActivityFilters.byStatus(byDay, _status);
    return byStatus;
  }

  // ---------- Filtros ----------

  Widget _buildFilterRow(String label, Widget dropdown) {
    return Row(
      children: [
        SizedBox(width: 90, child: Text(label)),
        Expanded(child: dropdown),
      ],
    );
  }

  Widget _buildCategoryDropdown(List<String> categories) {
    final items = <DropdownMenuItem<String?>>[
      const DropdownMenuItem<String?>(value: null, child: Text('Todas')),
    ];
    for (final category in categories) {
      items.add(
        DropdownMenuItem<String?>(value: category, child: Text(category)),
      );
    }
    return DropdownButton<String?>(
      isExpanded: true,
      value: _category,
      items: items,
      onChanged: _changeCategory,
    );
  }

  Widget _buildDayDropdown() {
    final items = <DropdownMenuItem<DateTime?>>[
      const DropdownMenuItem<DateTime?>(value: null, child: Text('Todos')),
    ];
    for (final day in TripConfig.days) {
      items.add(
        DropdownMenuItem<DateTime?>(value: day, child: Text(Fmt.date(day))),
      );
    }
    return DropdownButton<DateTime?>(
      isExpanded: true,
      value: _day,
      items: items,
      onChanged: _changeDay,
    );
  }

  Widget _buildStatusDropdown() {
    final items = <DropdownMenuItem<ActivityStatus?>>[
      const DropdownMenuItem<ActivityStatus?>(
        value: null,
        child: Text('Todos'),
      ),
    ];
    for (final status in _statusOptions) {
      items.add(
        DropdownMenuItem<ActivityStatus?>(
          value: status,
          child: Text(status.label),
        ),
      );
    }
    return DropdownButton<ActivityStatus?>(
      isExpanded: true,
      value: _status,
      items: items,
      onChanged: _changeStatus,
    );
  }

  Widget _buildFilters(List<String> categories) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filtros', style: Theme.of(context).textTheme.titleMedium),
            _buildFilterRow('Categoría', _buildCategoryDropdown(categories)),
            _buildFilterRow('Día', _buildDayDropdown()),
            _buildFilterRow('Estado', _buildStatusDropdown()),
          ],
        ),
      ),
    );
  }

  /// Categorías para el filtro. Si la categoría guardada ya no aparece en los
  /// datos, se agrega igual para que el DropdownButton pueda mostrarla.
  List<String> _categoryOptions(List<ItineraryActivity> balanceItems) {
    final categories = ActivityFilters.categoriesOf(balanceItems);
    final selected = _category;
    if (selected != null && !categories.contains(selected)) {
      categories.add(selected);
    }
    return categories;
  }

  // ---------- Pantalla ----------

  Widget _buildHeader({
    required BudgetSummary general,
    required BudgetSummary filtered,
    required List<String> categories,
  }) {
    return Column(
      children: [
        BudgetSummaryCard(title: 'Balance general del viaje', summary: general),
        _buildFilters(categories),
        BudgetSummaryCard(
          title: 'Según los filtros',
          summary: filtered,
          showTotals: false,
        ),
      ],
    );
  }

  Widget _buildCard(ItineraryActivity activity) {
    return ActivityCard(activity: activity, showSync: false);
  }

  Widget _buildContent(ActivitiesResult result) {
    final synced = ActivityFilters.onlySynced(result.items);
    final balanceItems = ActivityFilters.forBalance(synced);
    final filtered = _applyFilters(balanceItems);

    final header = _buildHeader(
      general: ItineraryRules.summarize(synced),
      filtered: ItineraryRules.summarize(filtered),
      categories: _categoryOptions(balanceItems),
    );

    return ActivityListView(
      items: filtered,
      fromCache: result.fromCache,
      emptyMessage: 'No hay actividades con estos filtros',
      onRefresh: _onRefresh,
      cardBuilder: _buildCard,
      header: header,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ActivitiesResult>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingView();
        }

        final result = snapshot.data;
        if (snapshot.hasError || result == null) {
          return ErrorView(
            message: 'No se pudo cargar el balance',
            retryLabel: 'Reintentar',
            onRetry: _reload,
          );
        }

        return _buildContent(result);
      },
    );
  }
}
