import 'package:flutter/material.dart';
import 'animal.dart';

class AnimalDetail extends StatefulWidget {
    final Animal animal;

    const AnimalDetail({
        super.key,
        required this.animal
    });

    @override 
    State<AnimalDetail> createState() => _AnimalDetailPageState();


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

class _AnimalDetailPageState extends State<AnimalDetail> {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Animal details'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Un póster vertical, centrado y con bordes redondeados.
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 260),
                      child: Card(
                        elevation: 4,
                        margin: EdgeInsets.zero,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: AspectRatio(
                          aspectRatio: 2 / 3,
                          child: Image.asset(
                            "assets/images/${widget.animal.imagePath}",
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return ColoredBox(
                                color: colors.surfaceContainerHighest,
                                child: Center(
                                  child: Icon(
                                    Icons.movie_outlined,
                                    size: 72,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                   widget.animal.name,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Wrap permite que las etiquetas bajen en pantallas pequeñas.
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        avatar: const Icon(
                          Icons.content_paste,
                          size: 18,
                        ),
                        label: Text(widget.animal.species),
                        side: BorderSide.none,
                        backgroundColor: colors.secondaryContainer,
                      ),
                      Chip(
                        avatar: Icon(
                          widget.animal.isAttended
                              ? Icons.check_circle_outline
                              : Icons.schedule,
                          size: 18,
                        ),
                        label: Text(
                          widget.animal.isAttended ? 'Attended' : 'Pending',
                        ),
                        side: BorderSide.none,
                        backgroundColor: colors.surfaceContainerHighest,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Age',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.animal.age.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
