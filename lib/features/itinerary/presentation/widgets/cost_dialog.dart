import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/validators/itinerary_rules.dart';

/// Diálogo para escribir un valor en pesos (por ejemplo, el costo real).
/// Devuelve el número escrito o null si el usuario cancela.
Future<int?> costDialog(
  BuildContext context, {
  required String title,
  required String message,
  int? initialValue,
}) {
  return showDialog<int>(
    context: context,
    builder: (_) =>
        _CostDialog(title: title, message: message, initialValue: initialValue),
  );
}

class _CostDialog extends StatefulWidget {
  final String title;
  final String message;
  final int? initialValue;

  const _CostDialog({
    required this.title,
    required this.message,
    this.initialValue,
  });

  @override
  State<_CostDialog> createState() => _CostDialogState();
}

class _CostDialogState extends State<_CostDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final initial = widget.initialValue;
    if (initial != null) {
      _controller.text = initial.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    final value = ItineraryRules.parseCost(_controller.text);
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.message),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: ItineraryRules.validateCostText,
              decoration: const InputDecoration(
                labelText: 'Valor (COP)',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Guardar')),
      ],
    );
  }
}
