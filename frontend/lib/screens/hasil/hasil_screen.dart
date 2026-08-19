import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/beban_item.dart';
import '../../models/hasil_perhitungan.dart';
import '../../core/theme.dart';
import '../../providers/beban_provider.dart';
import '../../providers/hasil_provider.dart';
import '../../providers/parameter_provider.dart';
import '../../providers/riwayat_provider.dart';
import '../../services/pdf_export_service.dart';
import 'widgets/breakdown_chart.dart';
import 'widgets/metric_card.dart';
import 'widgets/perbandingan_baterai_card.dart';

/// Halaman Hasil: menampilkan ringkasan total daya/WH, perbandingan
/// VRLA vs LiFePO4, dan breakdown per beban. Semua data otomatis
/// ter-update lewat hasilPerhitunganProvider setiap kali beban atau
/// parameter berubah di HomeScreen — tidak perlu tombol "hitung" manual.
class HasilScreen extends ConsumerWidget {
  const HasilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasil = ref.watch(hasilPerhitunganProvider);
    final bebanList = ref.watch(bebanProvider);
    final theme = Theme.of(context);

    if (hasil == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calculate_outlined,
                  size: 48, color: theme.colorScheme.outline),
              const SizedBox(height: 12),
              Text(
                'Belum ada beban ditambahkan',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Tambahkan beban di tab Input beban untuk melihat hasil perhitungan.',
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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: MetricCard(
                label: 'Total watt hours',
                value: '${hasil.totalWattHours.toStringAsFixed(0)} Wh',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                label: 'Total daya',
                value: '${hasil.totalDayaWatt.toStringAsFixed(0)} W',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text('Perbandingan jenis baterai', style: theme.textTheme.titleSmall),
        const SizedBox(height: 10),
        PerbandinganBateraiCard(
          namaBaterai: 'VRLA (DoD 50%)',
          hasil: hasil.vrla,
          warna: AppTheme.warnaVrla,
        ),
        const SizedBox(height: 8),
        PerbandinganBateraiCard(
          namaBaterai: 'LiFePO4 (DoD 80%)',
          hasil: hasil.lifepo4,
          warna: AppTheme.warnaLifepo4,
        ),
        const SizedBox(height: 20),
        BreakdownChart(bebanList: bebanList),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () => _tampilkanDialogSimpan(context, ref),
          icon: const Icon(Icons.save_outlined),
          label: const Text('Simpan proyek'),
        ),
        const SizedBox(height: 8),
        FilledButton.tonalIcon(
          onPressed: () => _tampilkanDialogNamaLaluExport(context, ref, bebanList, hasil),
          icon: const Icon(Icons.download_outlined),
          label: const Text('Export PDF'),
        ),
      ],
    );
  }

  Future<void> _tampilkanDialogNamaLaluExport(
    BuildContext context,
    WidgetRef ref,
    List<BebanItem> bebanList,
    HasilPerhitungan hasil,
  ) async {
    final namaProyek = await _tampilkanDialogInputNama(
      context,
      judulDialog: 'Export PDF',
      labelInput: 'Nama proyek',
      teksTombol: 'Export',
    );
    if (namaProyek == null) return; // dibatalkan
    if (!context.mounted) return;
    await _exportPdf(context, ref, bebanList, hasil, namaProyek);
  }

  Future<void> _exportPdf(
    BuildContext context,
    WidgetRef ref,
    List<BebanItem> bebanList,
    HasilPerhitungan hasil,
    String namaProyek,
  ) async {
    final parameter = ref.read(parameterProvider);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await PdfExportService.exportDanBagikan(
        namaProyek: namaProyek,
        bebanList: bebanList,
        parameter: parameter,
        hasil: hasil,
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Gagal export PDF: $e')),
      );
    }
  }

  void _tampilkanDialogSimpan(BuildContext context, WidgetRef ref) async {
    final namaProyek = await _tampilkanDialogInputNama(
      context,
      judulDialog: 'Simpan proyek',
      labelInput: 'Nama proyek',
      teksTombol: 'Simpan',
    );
    if (namaProyek == null) return; // dibatalkan
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(riwayatProvider.notifier).simpanProyekSaatIni(namaProyek);
      messenger.showSnackBar(
        SnackBar(content: Text('Proyek "$namaProyek" berhasil disimpan')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    }
  }

  /// Dialog reusable untuk minta input nama proyek.
  /// Dipakai baik untuk "Simpan proyek" maupun "Export PDF", supaya
  /// tidak ada duplikasi kode dialog. Return null kalau dibatalkan.
  Future<String?> _tampilkanDialogInputNama(
    BuildContext context, {
    required String judulDialog,
    required String labelInput,
    required String teksTombol,
  }) {
    final namaController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(judulDialog),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: namaController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: labelInput,
                hintText: 'Contoh: Rumah Pak Budi - Gresik',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(context, namaController.text.trim());
              },
              child: Text(teksTombol),
            ),
          ],
        );
      },
    );
  }
}