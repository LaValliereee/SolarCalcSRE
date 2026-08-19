import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/riwayat_provider.dart';

/// Halaman Riwayat: menampilkan daftar proyek perhitungan yang sudah
/// disimpan secara lokal (sqflite), dengan opsi hapus per item.
/// Menggunakan AsyncNotifier, jadi loading/error state ditangani
/// otomatis lewat .when().
class RiwayatScreen extends ConsumerWidget {
  const RiwayatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final riwayatAsync = ref.watch(riwayatProvider);
    final theme = Theme.of(context);

    return riwayatAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Gagal memuat riwayat: $error',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ),
      data: (daftarProyek) {
        if (daftarProyek.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 48, color: theme.colorScheme.outline),
                  const SizedBox(height: 12),
                  Text('Belum ada proyek tersimpan', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(
                    'Simpan hasil perhitungan dari tab Hasil untuk melihatnya di sini.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: daftarProyek.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final proyek = daftarProyek[index];
            return Card(
              child: ListTile(
                title: Text(
                  proyek.namaProyek,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  '${proyek.hasil.totalWattHours.toStringAsFixed(0)} Wh · '
                  '${proyek.hasil.vrla.jumlahAki} aki VRLA · '
                  '${_formatTanggal(proyek.dibuatPada)}',
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                  tooltip: 'Hapus proyek',
                  onPressed: () => _konfirmasiHapus(context, ref, proyek.id, proyek.namaProyek),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatTanggal(DateTime tanggal) {
    return '${tanggal.day}/${tanggal.month}/${tanggal.year}';
  }

  void _konfirmasiHapus(
    BuildContext context,
    WidgetRef ref,
    String id,
    String namaProyek,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus proyek?'),
        content: Text('Proyek "$namaProyek" akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(riwayatProvider.notifier).hapusProyek(id);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}