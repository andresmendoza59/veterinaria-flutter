import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/data/repositories/animal_note_repository.dart';
import 'package:flutter_app/data/services/auth_service.dart';
import 'package:flutter_app/data/services/crash/crash_service.dart';
import 'package:flutter_app/data/services/animal_source.dart';
import 'package:flutter_app/shared/widgets/empty_view.dart';
import 'package:flutter_app/shared/widgets/error_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/shared/models/animal.dart';
import '../widgets/item_card.dart';
import 'animal_detail.dart';

class AnimalScreen extends StatefulWidget {
  final AnimalNoteRepository noteRepo;
  final AuthService authService;
  final CrashService crashService;

  const AnimalScreen({
    super.key,
    required this.noteRepo,
    required this.authService,
    required this.crashService,
  });

  @override
  State<AnimalScreen> createState() => _AnimalScreenState();
}

class _AnimalScreenState extends State<AnimalScreen> {
  // Estado de la pantalla.
  // Durante la clase analizaremos qué representa cada variable
  // y cuándo debe cambiar.

  bool isLoading = false;
  List<Animal> animals = [];
  String errorMessage = '';
  String? favoriteId;
  final AnimalSource _animalSource = const AssetAnimalSource();
  late Future<List<Animal>> _futureAnimals;
  

  void toggleFavorite(String id) {
    setState(() {
          if (favoriteId == id) {
            favoriteId = null;
          } else {
            favoriteId = id;
          }
    });
  }

  void retryAnimalList() {
    setState(() {
        _futureAnimals = _animalSource.fetchAnimals();
    });
  }

  String _friendlyError(Object? error) {
    if (error is ApiException) {
      return error.toString();
    }
    if (error is DecodeException) {
      return error.toString();
    }
    return "The information of the animals couldn't be loaded";
  }

  Future<void> saveFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    if (favoriteId == null) {
        await prefs.remove('favoriteId');
    } else {
        await prefs.setString('favoriteId', favoriteId!);
    }
  }

  @override
  void initState() {
    super.initState();
    _futureAnimals = _animalSource.fetchAnimals();
  }

  // Esta función se construirá progresivamente durante la clase.
  Future<void> fetchAnimals() async {
    // CHECKPOINTS DE LA CLASE:
    // 1. Activar el estado de carga.
    // 2. Esperar los datos.
    // 3. Guardar las películas.
    // 4. Finalizar la carga.
    // 5. Manejar un posible error.
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final data = await _animalSource.fetchAnimals();
      setState(() {
        animals = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'No se pudieron cargar las mascotas';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mascotas'),
        centerTitle: true,
        actions: [
            // Menú QA: solo existe en debug, desaparece en un build release.
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
                tooltip: 'Synchronize notes',
                onPressed: () async { await widget.noteRepo.syncPending(); },
                icon: const Icon(Icons.sync),
            ),
            IconButton(
                tooltip: 'Cerrar sesión',
                onPressed: () async { await widget.authService.logout(); },
                icon: const Icon(Icons.logout),
            ),
        ],
      ),
      body: _buildBody2()
    );
  }

  Widget _buildBody2() {
    return FutureBuilder<List<Animal>>(future: _futureAnimals,
        builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ErrorView(
                message: _friendlyError(snapshot.error),
                onRetry: retryAnimalList,
              );
            }

            final animals = snapshot.data ?? [];

            if (animals.isEmpty) {
              return const EmptyView(message: 'No animals available');
            }

            return ListView.builder(
                itemCount: animals.length,
                itemBuilder: (context, index) {
                    final animal = animals[index];
                    final isFavorite = animal.id == favoriteId;

                    return ItemCard(
                        animal: animal,
                        // TODO: Mostrar el check que se mostraba cuando era Card
                        isFavorite: isFavorite,
                        onFavoriteTap: () => toggleFavorite(animal.id),
                        onTap: () => {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => AnimalDetail(animal: animal, noteRepo: widget.noteRepo,)))
                        }
                    );
                });
           
        }    
    ); 
  }
}
