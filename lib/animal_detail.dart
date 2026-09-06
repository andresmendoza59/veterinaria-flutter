import 'package:flutter/material.dart';
import 'animal.dart';

class AnimalDetail extends StatelessWidget {
    final Animal animal;

    const AnimalDetail({
        super.key,
        required this.animal
    });


    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: Text(animal.name)),
            body: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(animal.race)
            )
        );
    }
}
