import 'package:flutter/material.dart';

/// Kartu sederhana untuk menampilkan satu angka ringkasan,
/// misal "Total Watt Hours: 1.242 Wh". Dipakai berpasangan
/// (total WH & total daya) di bagian atas HasilScreen.
class MetricCard extends StatelessWidget {
  final String label;
  final String value;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}