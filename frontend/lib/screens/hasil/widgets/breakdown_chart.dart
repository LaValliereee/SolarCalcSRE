import 'package:flutter/material.dart';

import '../../../models/beban_item.dart';

/// Menampilkan breakdown watt hours per item beban sebagai bar horizontal,
/// diurutkan dari yang paling besar. Bar terpanjang = kontributor WH
/// terbesar, jadi user langsung lihat item mana yang paling boros.
class BreakdownChart extends StatelessWidget {
  final List<BebanItem> bebanList;

  const BreakdownChart({super.key, required this.bebanList});

  @override
  Widget build(BuildContext context) {
    if (bebanList.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    // Urutkan dari watt hours terbesar, ambil maksimal 6 teratas
    // supaya chart tidak kepanjangan kalau daftar beban banyak.
    final sorted = [...bebanList]
      ..sort((a, b) => b.wattHours.compareTo(a.wattHours));
    final ditampilkan = sorted.take(6).toList();
    final maxWh = ditampilkan.first.wattHours;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Breakdown daya per beban', style: theme.textTheme.titleSmall),
        const SizedBox(height: 10),
        ...ditampilkan.map((item) {
          final proporsi = maxWh > 0 ? item.wattHours / maxWh : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text(
                    item.nama,
                    style: theme.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: proporsi,
                      minHeight: 8,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        if (sorted.length > 6)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '+${sorted.length - 6} beban lainnya',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}