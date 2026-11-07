import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/trip_config.dart';
import 'package:flutter_app/data/repositories/itinerary_repository.dart';
import 'package:flutter_app/data/services/auth_service.dart';
import 'package:flutter_app/data/services/catalog_source.dart';
import 'package:flutter_app/data/services/crash/crash_service.dart';
import 'package:flutter_app/features/itinerary/presentation/screens/my_proposals_screen.dart';
import 'package:flutter_app/features/itinerary/presentation/screens/options_screen.dart';
import 'package:flutter_app/shared/models/user_role.dart';
import 'package:flutter_app/shared/widgets/empty_view.dart';

class ItineraryHomeScreen extends StatefulWidget {
  final String uid;
  final UserRole role;
  final AuthService authService;
  final CrashService crashService;
  final CatalogSource catalogSource;
  final ItineraryRepository itineraryRepo;

  const ItineraryHomeScreen({
    super.key,
    required this.uid,
    required this.role,
    required this.authService,
    required this.crashService,
    required this.catalogSource,
    required this.itineraryRepo,
  });

  @override
  State<ItineraryHomeScreen> createState() => _ItineraryHomeScreenState();
}

class _ItineraryHomeScreenState extends State<ItineraryHomeScreen> {
  final ValueNotifier<int> refresh = ValueNotifier<int>(0);
  int _index = 0;

  @override
  void dispose() {
    refresh.dispose();
    super.dispose();
  }

  NavigationDestination? get _roleDestination {
    switch (widget.role) {
      case UserRole.coordinator:
        return const NavigationDestination(
          icon: Icon(Icons.fact_check_outlined),
          selectedIcon: Icon(Icons.fact_check),
          label: 'Aprobaciones',
        );
      case UserRole.finance:
        return const NavigationDestination(
          icon: Icon(Icons.account_balance_outlined),
          selectedIcon: Icon(Icons.account_balance),
          label: 'Revisión',
        );
      case UserRole.member:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleDestination = _roleDestination;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(TripConfig.name),
            Text(
              widget.role.label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          if (kDebugMode)
            PopupMenuButton<String>(
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
            ),
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await widget.authService.logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: [
          OptionsScreen(
            catalogSource: widget.catalogSource,
            uid: widget.uid,
            itineraryRepo: widget.itineraryRepo,
            refresh: refresh,
          ),
          MyProposalsScreen(
            uid: widget.uid,
            itineraryRepo: widget.itineraryRepo,
            refresh: refresh,
          ),
          if (roleDestination != null)
            const EmptyView(message: 'Disponible pronto'),
          const EmptyView(message: 'Disponible pronto'),
          const EmptyView(message: 'Disponible pronto'),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Opciones',
          ),
          const NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_note),
            label: 'Mis propuestas',
          ),
          if (roleDestination != null) roleDestination,
          const NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Itinerario',
          ),
          const NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Balance',
          ),
        ],
      ),
    );
  }
}
