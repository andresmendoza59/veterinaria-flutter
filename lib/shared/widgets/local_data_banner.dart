import 'package:flutter/material.dart';

/// Aviso que se muestra cuando Firestore no respondió y la pantalla está
/// usando lo último guardado en Drift.
class LocalDataBanner extends StatelessWidget {
  const LocalDataBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      color: scheme.tertiaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(Icons.cloud_off_outlined, color: scheme.onTertiaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Sin conexión con el servidor. Estás viendo los datos '
              'guardados en este dispositivo.',
              style: TextStyle(color: scheme.onTertiaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
