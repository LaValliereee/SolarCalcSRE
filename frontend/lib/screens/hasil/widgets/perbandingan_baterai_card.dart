import 'package:flutter/material.dart';

import '../../../models/hasil_perhitungan.dart';

/// Kartu untuk menampilkan hasil perhitungan satu jenis baterai
/// (VRLA atau LiFePO4): nama jenis di kiri, jumlah aki & panel di kanan.
/// Warna latar bisa dibedakan antar jenis baterai lewat parameter [warna].
class PerbandinganBateraiCard extends StatelessWidget {
  final String namaBaterai; // contoh: "VRLA (DoD 50%)"
  final HasilBaterai hasil;
  final Color warna;

  const PerbandinganBateraiCard({
    super.key,
    required this.namaBaterai,
    required this.hasil,
    required this.warna,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            namaBaterai,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: warna,
            ),
          ),
          Text(
            '${hasil.jumlahAki} aki · ${hasil.jumlahPanel} panel',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}