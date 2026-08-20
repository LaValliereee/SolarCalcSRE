import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../models/beban_item.dart';
import '../../providers/beban_provider.dart';
import '../../providers/parameter_provider.dart';
import '../hasil/hasil_screen.dart';
import '../riwayat/riwayat_screen.dart';
import 'widgets/beban_card.dart';
import 'widgets/parameter_form.dart';

/// Halaman utama aplikasi: TabBar dengan 3 tab (Input beban, Hasil, Riwayat).
/// Header menampilkan logo & nama aplikasi, plus tombol reset di kanan atas.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                  errorBuilder: (context, error, stackTrace) => CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.primaryTosca.withValues(alpha: 0.15),
                    child: const Icon(
                      Icons.wb_sunny_outlined,
                      size: 18,
                      color: AppTheme.primaryTosca,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('SolaCalcSRE', style: TextStyle(fontSize: 16)),
                  Text(
                    'Sumber Rejeki Energy',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.restart_alt),
              tooltip: 'Proyek baru',
              onPressed: () => _konfirmasiReset(context, ref),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Input beban'),
              Tab(text: 'Hasil'),
              Tab(text: 'Riwayat'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_InputBebanTab(), HasilScreen(), RiwayatScreen()],
        ),
      ),
    );
  }

  void _konfirmasiReset(BuildContext context, WidgetRef ref) {
    final bebanList = ref.read(bebanProvider);

    if (bebanList.isEmpty) {
      // Tidak ada apa-apa untuk direset, tidak perlu tanya konfirmasi
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mulai proyek baru?'),
        content: const Text(
          'Semua beban dan parameter yang sedang diisi akan dihapus. '
          'Pastikan sudah disimpan lewat tab Hasil kalau masih diperlukan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(bebanProvider.notifier).resetBeban();
              ref.read(parameterProvider.notifier).reset();
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _InputBebanTab extends ConsumerWidget {
  const _InputBebanTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bebanList = ref.watch(bebanProvider);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      children: [
        Text('Daftar beban listrik', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        if (bebanList.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Belum ada beban. Tambahkan lewat tombol di bawah.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          ...bebanList.map(
            (item) => BebanCard(
              beban: item,
              onHapus: () =>
                  ref.read(bebanProvider.notifier).hapusBeban(item.id),
              onTap: () => _tampilkanDialogBeban(context, ref, bebanLama: item),
            ),
          ),
        const SizedBox(height: 6),
        OutlinedButton.icon(
          onPressed: () => _tampilkanDialogBeban(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Tambah beban'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(44),
          ),
        ),
        const SizedBox(height: 16),
        const ParameterForm(),
      ],
    );
  }

  /// Dialog untuk tambah beban baru ATAU edit beban lama, tergantung
  /// apakah [bebanLama] diisi. Kalau diisi, form otomatis ter-prefill
  /// dengan nilai lama dan tombol berubah jadi "Simpan" bukan "Tambah".
  void _tampilkanDialogBeban(
    BuildContext context,
    WidgetRef ref, {
    BebanItem? bebanLama,
  }) {
    final isEdit = bebanLama != null;
    final namaController = TextEditingController(text: bebanLama?.nama ?? '');
    final dayaController = TextEditingController(
      text: bebanLama != null ? bebanLama.dayaWatt.toStringAsFixed(0) : '',
    );
    final jamController = TextEditingController(
      text: bebanLama != null ? bebanLama.jamNyala.toStringAsFixed(0) : '',
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit beban' : 'Tambah beban'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: namaController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Nama alat/ruangan',
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: dayaController,
                  decoration: const InputDecoration(labelText: 'Daya (watt)'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    if (n == null || n <= 0) return 'Harus angka > 0';
                    if (n > 10000) return 'Maksimal 10.000 W';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: jamController,
                  decoration: const InputDecoration(
                    labelText: 'Jam nyala per hari',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    if (n == null || n <= 0 || n > 24) {
                      return 'Harus antara 0-24';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            if (isEdit)
              TextButton(
                onPressed: () {
                  ref.read(bebanProvider.notifier).hapusBeban(bebanLama.id);
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Hapus'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final nama = namaController.text.trim();
                final daya = double.parse(dayaController.text);
                final jam = double.parse(jamController.text);

                if (isEdit) {
                  ref.read(bebanProvider.notifier).editBeban(
                        bebanLama.id,
                        nama: nama,
                        dayaWatt: daya,
                        jamNyala: jam,
                      );
                } else {
                  ref.read(bebanProvider.notifier).tambahBeban(
                        nama: nama,
                        dayaWatt: daya,
                        jamNyala: jam,
                      );
                }
                Navigator.pop(context);
              },
              child: Text(isEdit ? 'Simpan' : 'Tambah'),
            ),
          ],
        );
      },
    );
  }
}