import 'animal.dart';
import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
    final Animal animal;
    final VoidCallback onTap;
    final bool isFavorite;
    final VoidCallback onFavoriteTap;

    const ItemCard({
        super.key,
        required this.animal,
        required this.onTap,
        required this.isFavorite,
        required this.onFavoriteTap
    });

    @override
    Widget build(BuildContext context) {
        return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
                onTap: onTap,
                child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                               CircleAvatar(radius: 50, backgroundImage: AssetImage('assets/images/${animal.imagePath}')),
                               const SizedBox(height: 4),
                               Text(animal.name),
                               Text(animal.race)
                           ]
                       )
                )
            )
        );        
    }
}
