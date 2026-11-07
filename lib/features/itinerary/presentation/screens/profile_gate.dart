import 'package:flutter/material.dart';
import 'package:flutter_app/core/trip_config.dart';
import 'package:flutter_app/data/repositories/user_profile_repository.dart';
import 'package:flutter_app/data/services/auth_service.dart';
import 'package:flutter_app/shared/models/user_profile.dart';
import 'package:flutter_app/shared/models/user_role.dart';
import 'package:flutter_app/shared/widgets/error_view.dart';
import 'package:flutter_app/shared/widgets/loading_view.dart';

class ProfileGate extends StatefulWidget {
  final String uid;
  final UserProfileRepository profileRepo;
  final AuthService authService;
  final Widget Function(BuildContext context, UserRole role) builder;

  const ProfileGate({
    super.key,
    required this.uid,
    required this.profileRepo,
    required this.authService,
    required this.builder,
  });

  @override
  State<ProfileGate> createState() => _ProfileGateState();
}

class _ProfileGateState extends State<ProfileGate> {
  late Future<UserProfile> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.profileRepo.ensureProfile(widget.uid);
  }

  @override
  void didUpdateWidget(covariant ProfileGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uid != widget.uid) {
      _future = widget.profileRepo.ensureProfile(widget.uid);
    }
  }

  void _retry() {
    setState(() {
      _future = widget.profileRepo.ensureProfile(widget.uid);
    });
  }

  Widget _frame(Widget body) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(TripConfig.name),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await widget.authService.logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: body,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _frame(const LoadingView());
        }
        if (snapshot.hasError) {
          return _frame(
            ErrorView(
              message:
                  'No pudimos cargar tu perfil. Revisa tu conexión e intenta de nuevo.',
              retryLabel: 'Reintentar',
              onRetry: _retry,
            ),
          );
        }
        return widget.builder(context, snapshot.data!.role);
      },
    );
  }
}
