import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../providers/beban_provider.dart';
import '../hasil/hasil_screen.dart';
import '../riwayat/riwayat_screen.dart';
import 'widgets/beban_card.dart';
import 'widgets/parameter_form.dart';

/// Halaman utama aplikasi: TabBar dengan 2 tab (Input beban, Hasil).
/// Header menampilkan nama aplikasi "SolaCalcSRE" sesuai mockup.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            ),
          ),
        const SizedBox(height: 6),
        OutlinedButton.icon(
          onPressed: () => _tampilkanDialogTambahBeban(context, ref),
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

  void _tampilkanDialogTambahBeban(BuildContext context, WidgetRef ref) {
    final namaController = TextEditingController();
    final dayaController = TextEditingController();
    final jamController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah beban'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: namaController,
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
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                ref
                    .read(bebanProvider.notifier)
                    .tambahBeban(
                      nama: namaController.text.trim(),
                      dayaWatt: double.parse(dayaController.text),
                      jamNyala: double.parse(jamController.text),
                    );
                Navigator.pop(context);
              },
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }
}
