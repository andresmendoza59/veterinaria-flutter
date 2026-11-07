import 'package:flutter/material.dart';
import 'package:flutter_app/core/formatters.dart';
import 'package:flutter_app/shared/models/activity_status.dart';
import 'package:flutter_app/shared/models/itinerary_activity.dart';

class ActivityCard extends StatelessWidget {
  final ItineraryActivity activity;
  final bool showSync;
  final List<Widget> actions;

  const ActivityCard({
    super.key,
    required this.activity,
    this.showSync = true,
    this.actions = const <Widget>[],
  });

  Widget _statusChip(ColorScheme scheme) {
    final status = activity.status;
    final Color background;
    final Color foreground;
    final IconData icon;
    if (status == ActivityStatus.rejected ||
        status == ActivityStatus.cancelled) {
      background = scheme.errorContainer;
      foreground = scheme.onErrorContainer;
      icon = Icons.cancel_outlined;
    } else if (status == ActivityStatus.proposed) {
      background = scheme.secondaryContainer;
      foreground = scheme.onSecondaryContainer;
      icon = Icons.edit_note_outlined;
    } else {
      background = scheme.primaryContainer;
      foreground = scheme.onPrimaryContainer;
      icon = Icons.check_circle_outline;
    }
    return _chip(status.label, icon, background, foreground);
  }

  Widget _syncChip(ColorScheme scheme) {
    switch (activity.syncState) {
      case SyncState.synced:
        return _chip(
          'Sincronizada',
          Icons.cloud_done_outlined,
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
        );
      case SyncState.queued:
        return _chip(
          'Pendiente de envío',
          Icons.cloud_upload_outlined,
          scheme.tertiaryContainer,
          scheme.onTertiaryContainer,
        );
      case SyncState.rejected:
        return _chip(
          'No aceptada al enviar',
          Icons.error_outline,
          scheme.errorContainer,
          scheme.onErrorContainer,
        );
    }
  }

  Widget _chip(
    String label,
    IconData icon,
    Color background,
    Color foreground,
  ) {
    return Chip(
      avatar: Icon(icon, size: 18, color: foreground),
      label: Text(label),
      labelStyle: TextStyle(color: foreground),
      backgroundColor: background,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _stateBlock(ThemeData theme, String caption, Widget chip) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          caption,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        chip,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    Widget line(String text, {TextStyle? style}) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(text, style: style ?? theme.textTheme.bodyMedium),
      );
    }

    final details = <Widget>[];
    if (showSync && activity.syncState == SyncState.queued) {
      details.add(
        line(
          'Aún no se envía al servidor: no ocupa franja ni presupuesto.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      );
    }
    if (activity.reason.isNotEmpty) {
      details.add(line('Motivo: ${activity.reason}'));
    }
    if (activity.returnRequested) {
      details.add(
        line(
          'Devolución solicitada',
          style: theme.textTheme.labelLarge?.copyWith(color: scheme.tertiary),
        ),
      );
    }
    if (activity.syncError.isNotEmpty) {
      details.add(
        line(
          'Motivo del rechazo al enviar: ${activity.syncError}',
          style: theme.textTheme.bodyMedium?.copyWith(color: scheme.error),
        ),
      );
    }
    if (activity.reservedCost > 0) {
      details.add(line('Reservado: ${Fmt.money(activity.reservedCost)}'));
    }
    if (activity.realCost > 0) {
      details.add(line('Costo real: ${Fmt.money(activity.realCost)}'));
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(activity.title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.event_outlined,
              text:
                  '${Fmt.date(activity.startAt)} · ${Fmt.slotLabel(activity.startAt)}',
            ),
            _InfoRow(icon: Icons.place_outlined, text: activity.location),
            _InfoRow(
              icon: Icons.payments_outlined,
              text: 'Costo estimado: ${Fmt.money(activity.estimatedCost)}',
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _stateBlock(
                  theme,
                  'Estado de la actividad',
                  _statusChip(scheme),
                ),
                if (showSync)
                  _stateBlock(theme, 'Sincronización', _syncChip(scheme)),
              ],
            ),
            ...details,
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: actions),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
