import 'package:flutter/material.dart';
import 'package:flutter_app/core/formatters.dart';
import 'package:flutter_app/validators/itinerary_rules.dart';

/// Tarjeta con el resumen del presupuesto: total, reservado, gastado y saldo.
/// Con showTotals = false solo muestra reservado y gastado (sirve para el
/// subtotal de un filtro, donde el total y el saldo no aplican).
class BudgetSummaryCard extends StatelessWidget {
  final String title;
  final BudgetSummary summary;
  final bool showTotals;

  const BudgetSummaryCard({
    super.key,
    required this.title,
    required this.summary,
    this.showTotals = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            if (showTotals)
              _MoneyRow(label: 'Presupuesto total', value: summary.total),
            _MoneyRow(label: 'Costo reservado', value: summary.reserved),
            _MoneyRow(label: 'Gasto real', value: summary.spent),
            if (showTotals) const Divider(),
            if (showTotals)
              _MoneyRow(
                label: 'Saldo disponible',
                value: summary.available,
                bold: true,
              ),
            const SizedBox(height: 8),
            Text(
              'Confirmadas: ${summary.confirmedCount} · '
              'Realizadas: ${summary.doneCount} · '
              'Costo cerrado: ${summary.closedCount} · '
              'Canceladas: ${summary.cancelledCount}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _MoneyRow extends StatelessWidget {
  final String label;
  final int value;
  final bool bold;

  const _MoneyRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? Theme.of(context).textTheme.titleSmall
        : Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(Fmt.money(value), style: style),
        ],
      ),
    );
  }
}
