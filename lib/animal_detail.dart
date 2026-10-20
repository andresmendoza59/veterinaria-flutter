import 'package:flutter/material.dart';
import 'package:flutter_app/model/animal.dart';
import 'package:flutter_app/model/animal_note.dart';
import 'package:flutter_app/repository/animal_note_repository.dart';

class AnimalDetail extends StatefulWidget {
    final Animal animal;
    final AnimalNoteRepository noteRepo;

    const AnimalDetail({
        super.key,
        required this.animal,
        required this.noteRepo
    });

    @override 
    State<AnimalDetail> createState() => _AnimalDetailPageState();

}

class _AnimalDetailPageState extends State<AnimalDetail> {
  final TextEditingController _noteController = TextEditingController();
  AnimalNote? _savedNote;

  @override
  void initState() {
    super.initState();
    _loadLocalNote();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadLocalNote() async {
    final saved = await widget.noteRepo.getNoteForAnimal(widget.animal.id);
    if (!mounted) return;

    setState(() {
      _savedNote = saved;
      _noteController.text = saved?.note ?? '';
    });
  }

  Future<void> _saveLocalNote() async {
    final text = _noteController.text.trim();
    if (text.isEmpty) return;

    final note = AnimalNote(animalId: widget.animal.id, note: text, updatedAt: DateTime.now());

    await widget.noteRepo.saveNote(note);

    if (!mounted) return;

    setState(() {
      _savedNote = note;
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("The note was saved")));
  }

  Widget _buildSavedNote(ColorScheme colors) {
    final note = _savedNote;

    if (note == null || note.note.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.sticky_note_2_outlined, size: 20, color: colors.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No note stored for this animal yet.',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: colors.secondaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sticky_note_2_outlined, size: 18, color: colors.onSecondaryContainer),
                const SizedBox(width: 8),
                Text(
                  'Updated ${_formatTimestamp(note.updatedAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.onSecondaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              note.note,
              style: TextStyle(fontSize: 16, height: 1.4, color: colors.onSecondaryContainer),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final local = timestamp.toLocal();
    String two(int value) => value.toString().padLeft(2, '0');

    return '${two(local.day)}/${two(local.month)}/${local.year} '
        '${two(local.hour)}:${two(local.minute)}';
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
                  const Text('Stored note',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildSavedNote(colors),
                    const SizedBox(height: 16),
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
