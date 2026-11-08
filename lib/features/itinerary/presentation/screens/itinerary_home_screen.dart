import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/trip_config.dart';
import 'package:flutter_app/data/repositories/catalog_repository.dart';
import 'package:flutter_app/data/repositories/itinerary_repository.dart';
import 'package:flutter_app/data/services/auth_service.dart';
import 'package:flutter_app/data/services/crash/crash_service.dart';
import 'package:flutter_app/features/itinerary/presentation/screens/my_proposals_screen.dart';
import 'package:flutter_app/features/itinerary/presentation/screens/options_screen.dart';
import 'package:flutter_app/features/itinerary/presentation/screens/schedule_approval_screen.dart';
import 'package:flutter_app/shared/models/user_role.dart';
import 'package:flutter_app/shared/widgets/empty_view.dart';

/// Una pestaña de la barra inferior: su texto, su ícono y la vista que muestra.
class _HomeTab {
  final String label;
  final IconData icon;
  final Widget body;

  const _HomeTab({required this.label, required this.icon, required this.body});
}

class ItineraryHomeScreen extends StatefulWidget {
  final String uid;
  final UserRole role;
  final AuthService authService;
  final CrashService crashService;
  final CatalogRepository catalogRepo;
  final ItineraryRepository itineraryRepo;

  const ItineraryHomeScreen({
    super.key,
    required this.uid,
    required this.role,
    required this.authService,
    required this.crashService,
    required this.catalogRepo,
    required this.itineraryRepo,
  });

  @override
  State<ItineraryHomeScreen> createState() => _ItineraryHomeScreenState();
}

class _ItineraryHomeScreenState extends State<ItineraryHomeScreen> {
  // Avisa a las pestañas que deben volver a leer sus datos.
  final ValueNotifier<int> refresh = ValueNotifier<int>(0);
  int _index = 0;
  bool _syncing = false;

  @override
  void dispose() {
    refresh.dispose();
    super.dispose();
  }

  Future<String> _runSync() async {
    try {
      final report = await widget.itineraryRepo.syncPending(uid: widget.uid);
      final refreshed = await widget.itineraryRepo.tryRefreshFromRemote();
      final summary =
          'Enviadas: ${report.synced}. Pendientes: ${report.failed}. '
          'No aceptadas: ${report.rejected}.';
      if (refreshed) return summary;
      return '$summary No se pudo actualizar desde el servidor.';
    } catch (error, stackTrace) {
      // Error inesperado: se informa al usuario y se registra como no fatal.
      await widget.crashService.recordNonFatal(
        error,
        stackTrace,
        reason: 'Sincronización manual',
      );
      return 'No se pudo sincronizar. Revisa tu conexión.';
    }
  }

  Future<void> _sync() async {
    if (_syncing) return;
    setState(() => _syncing = true);
    final message = await _runSync();
    if (!mounted) return;
    setState(() => _syncing = false);
    refresh.value++;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _selectTab(int index) {
    setState(() => _index = index);
  }

  // ---------- Pestañas según el rol ----------

  List<_HomeTab> _buildTabs() {
    final tabs = <_HomeTab>[];
    switch (widget.role) {
      case UserRole.member:
        tabs.add(_optionsTab());
        tabs.add(_myProposalsTab());
      case UserRole.coordinator:
        tabs.add(_approvalsTab());
      case UserRole.finance:
        tabs.add(_financeTab());
    }
    tabs.add(_itineraryTab());
    tabs.add(_preferencesTab());
    tabs.add(_balanceTab());
    return tabs;
  }

  _HomeTab _optionsTab() {
    return _HomeTab(
      label: 'Opciones',
      icon: Icons.explore_outlined,
      body: OptionsScreen(
        catalogRepo: widget.catalogRepo,
        uid: widget.uid,
        itineraryRepo: widget.itineraryRepo,
        refresh: refresh,
      ),
    );
  }

  _HomeTab _myProposalsTab() {
    return _HomeTab(
      label: 'Mis propuestas',
      icon: Icons.edit_note_outlined,
      body: MyProposalsScreen(
        uid: widget.uid,
        itineraryRepo: widget.itineraryRepo,
        refresh: refresh,
      ),
    );
  }

  _HomeTab _approvalsTab() {
    return _HomeTab(
      label: 'Aprobaciones',
      icon: Icons.fact_check_outlined,
      body: ScheduleApprovalScreen(
        uid: widget.uid,
        role: widget.role,
        itineraryRepo: widget.itineraryRepo,
        refresh: refresh,
      ),
    );
  }

  _HomeTab _financeTab() {
    return const _HomeTab(
      label: 'Revisión',
      icon: Icons.account_balance_outlined,
      body: EmptyView(message: 'Disponible pronto'),
    );
  }

  _HomeTab _itineraryTab() {
    return const _HomeTab(
      label: 'Itinerario',
      icon: Icons.event_note_outlined,
      body: EmptyView(message: 'Disponible pronto'),
    );
  }

  _HomeTab _preferencesTab() {
    return const _HomeTab(
      label: 'Preferencias',
      icon: Icons.favorite_border,
      body: EmptyView(message: 'Disponible pronto'),
    );
  }

  _HomeTab _balanceTab() {
    return const _HomeTab(
      label: 'Balance',
      icon: Icons.account_balance_wallet_outlined,
      body: EmptyView(message: 'Disponible pronto'),
    );
  }

  // ---------- Interfaz ----------

  Widget _buildTitle(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(TripConfig.name),
        Text(widget.role.label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  /// Menú QA: solo existe en modo debug (kDebugMode), nunca en el APK release.
  Widget _buildQaMenu(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'QA',
      onSelected: (value) async {
        if (value == 'non-fatal') {
          await widget.crashService.simulateNonFatalError();
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error no fatal registrado')),
          );
        }
        if (value == 'fatal') {
          widget.crashService.simulateFatalCrash();
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'non-fatal', child: Text('Registrar no fatal')),
        PopupMenuItem(value: 'fatal', child: Text('Forzar crash fatal')),
      ],
    );
  }

  Widget _buildSyncButton() {
    Widget icon = const Icon(Icons.sync);
    if (_syncing) {
      icon = const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return IconButton(
      tooltip: 'Sincronizar',
      onPressed: _syncing ? null : _sync,
      icon: icon,
    );
  }

  Widget _buildLogoutButton() {
    return IconButton(
      tooltip: 'Cerrar sesión',
      // No se navega a mano: AuthGate escucha authStateChanges y muestra el login.
      onPressed: () => widget.authService.logout(),
      icon: const Icon(Icons.logout),
    );
  }

  List<NavigationDestination> _buildDestinations(List<_HomeTab> tabs) {
    final destinations = <NavigationDestination>[];
    for (final tab in tabs) {
      destinations.add(
        NavigationDestination(icon: Icon(tab.icon), label: tab.label),
      );
    }
    return destinations;
  }

  List<Widget> _buildBodies(List<_HomeTab> tabs) {
    final bodies = <Widget>[];
    for (final tab in tabs) {
      bodies.add(tab.body);
    }
    return bodies;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _buildTabs();
    final safeIndex = _index < tabs.length ? _index : 0;

    return Scaffold(
      appBar: AppBar(
        title: _buildTitle(context),
        centerTitle: true,
        actions: [
          if (kDebugMode) _buildQaMenu(context),
          _buildSyncButton(),
          _buildLogoutButton(),
        ],
      ),
      // IndexedStack conserva el estado de cada pestaña al cambiar de una a otra.
      body: IndexedStack(index: safeIndex, children: _buildBodies(tabs)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: safeIndex,
        onDestinationSelected: _selectTab,
        destinations: _buildDestinations(tabs),
      ),
    );
  }
}
