import 'package:flutter/material.dart';
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

  void toggleFavorite(String id) {
    setState(() {
          if (favoriteId == id) {
            favoriteId = null;
          } else {
            favoriteId = id;
          }
    });
  }


  @override
  void initState() {
    super.initState();
    fetchAnimals();
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
        imagePath: ''
      ),
      Animal(
        id:      '2',
        name:    'Rufus',
        species: 'Dog',
        age:      7,
        race:     'Rottweiler',
        weight:   30.0,
        isAttended: false,
        imagePath: ''
      ),
      Animal(
        id:      '3',
        name:    'Mbappé',
        species: 'Turtle',
        age:     32,
        race:    'Macrochelys temminckii',
        weight:   70.0,
        isAttended: true,
        imagePath: ''
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
      body: _buildBody()
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
}
