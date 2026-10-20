import 'package:flutter/material.dart';
import 'package:flutter_app/repository/animal_note_repository.dart';
import 'package:flutter_app/service/animal_source.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/model/animal.dart';
import 'item_card.dart';
import 'animal_detail.dart';

class AnimalScreen extends StatefulWidget {
  final AnimalNoteRepository noteRepo;

  const AnimalScreen({ super.key, required this.noteRepo });

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
    return "The information of the animals couldn't be loaded ($error)";
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
            IconButton(
                tooltip: 'Synchronize notes',
                onPressed: () async { await widget.noteRepo.syncPending(); },
                icon: const Icon(Icons.sync),
            )
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
                return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(_friendlyError(snapshot.error)),
                    ElevatedButton(onPressed: retryAnimalList, child: const Text('Retry'))
                ]));
            }

            final animals = snapshot.data ?? [];

            if (animals.isEmpty) {
                return const Center(child: Text('No pet data was sent'));
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
