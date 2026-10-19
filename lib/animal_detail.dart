import 'package:flutter/material.dart';
import 'package:flutter_app/model/animal.dart';
import 'package:flutter_app/model/animal_note.dart';
import 'package:flutter_app/service/animal_note_storage.dart';

class AnimalDetail extends StatefulWidget {
    final Animal animal;

    const AnimalDetail({
        super.key,
        required this.animal
    });

    @override 
    State<AnimalDetail> createState() => _AnimalDetailPageState();

}

class _AnimalDetailPageState extends State<AnimalDetail> {
  final AnimalNoteStorage _storage = AnimalNoteStorage();
  final TextEditingController _noteController = TextEditingController();

  @override
    void dispose() {
      // TODO: implement dispose
      _noteController.dispose();
      super.dispose();
    }

  Future<void> _loadLocalNote() async {
    final _saved = await _storage.getNoteFromAnimal(widget.animal.id);
    if (!mounted || _saved == null) return;

    setState(() {
          _noteController.text = _saved.note;
        });
  }

  Future<void> _saveLocalNote() async {
    final note = AnimalNote(animalId: widget.animal.id, note: _noteController.text.trim(), updatedAt: DateTime.now());

    await _storage.saveNote(note);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("The note was saved")));
  }

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
                  const Divider(),
                  const SizedBox(height: 16,),
                  const Text('Storaged note',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                        controller: _noteController,
                        decoration: const InputDecoration(border: OutlineInputBorder(),
                        labelText: 'Comment'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _saveLocalNote, child: const Text('Save note')),
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
