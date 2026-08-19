import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../models/beban_item.dart';

/// Kartu untuk menampilkan satu item beban (nama, daya, jam nyala)
/// dengan tombol hapus. Dipakai di HomeScreen dalam ListView.builder.
class BebanCard extends StatelessWidget {
  final BebanItem beban;
  final VoidCallback onHapus;

  const BebanCard({
    super.key,
    required this.beban,
    required this.onHapus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        title: Text(
          beban.nama,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${beban.dayaWatt.toStringAsFixed(0)} W · ${beban.jamNyala.toStringAsFixed(0)} jam',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: AppTheme.toscaDark),
          onPressed: onHapus,
          tooltip: 'Hapus beban',
        ),
      ),
    );
  }
}