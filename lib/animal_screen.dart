import 'package:flutter/material.dart';
import 'package:flutter_app/service/animal_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'animal.dart';
import 'item_card.dart';
import 'animal_detail.dart';

class AnimalScreen extends StatefulWidget {
  const AnimalScreen({super.key});

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
  late final AnimalService _animalService;
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
    fetchAnimals();
    _animalService = AnimalService(baseUrl: "https://dummyjson.com/c/f55e-31ca-481d-9428");
    _futureAnimals = _animalService.getAnimals();
  }
  // Simula una operación asíncrona, como consultar una API.
  Future<List<Animal>> loadAnimals() async {
    await Future.delayed(
      const Duration(seconds: 2),
    );

    return [
      Animal(
        id:      '1',
        name:    'Luna',
        species: 'Cat',
        age:      1,
        race:     'Esfinge',
        weight:    7.5,
        isAttended: false,
        imagePath: 'sphynx.jpg'
      ),
      Animal(
        id:      '2',
        name:    'Rufus',
        species: 'Dog',
        age:      7,
        race:     'Rottweiler',
        weight:   30.0,
        isAttended: false,
        imagePath: 'rottweiler.jpg'
      ),
      Animal(
        id:      '3',
        name:    'Mbappé',
        species: 'Turtle',
        age:     32,
        race:    'Macrochelys temminckii',
        weight:   70.0,
        isAttended: true,
        imagePath: 'macrochelys.jpg'
      )
    ];
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
      final data = await loadAnimals();
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
      ),
      body: _buildBody2()
    );
  }

  Widget _buildBody() {
    // Empezamos con una interfaz mínima que ya funciona.
    // Este método evolucionará durante los checkpoints.

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator()
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Text(errorMessage)
      );
    }

    if (animals.isEmpty) {
      return Center(
        child: ElevatedButton(onPressed: fetchAnimals, child: const Text('Cargando mascotas...'))
      );
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
                Navigator.push(context, MaterialPageRoute(builder: (_) => AnimalDetail(animal: animal)))
            }
        );
      });
  }

  Widget _buildBody2() {
    return FutureBuilder<List<Animal>>(future: _futureAnimals,
        builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
                return Center(child: Text("There's an error, $snapshot"));
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
                            Navigator.push(context, MaterialPageRoute(builder: (_) => AnimalDetail(animal: animal)))
                        }
                    );
                });
           
        }    
    ); 
  }
}
