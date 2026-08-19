import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/parameter_sistem.dart';
import '../../../providers/parameter_provider.dart';

/// Form untuk mengatur parameter sistem PLTS: jenis SCC, jenis inverter,
/// kapasitas aki, dan Wp panel. Terhubung langsung ke parameterProvider,
/// setiap perubahan langsung ter-update di state (dan otomatis memicu
/// hitung ulang di hasilPerhitunganProvider).
class ParameterForm extends ConsumerWidget {
  const ParameterForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parameter = ref.watch(parameterProvider);
    final notifier = ref.read(parameterProvider.notifier);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Parameter sistem', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDropdownScc(parameter, notifier),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdownInverter(parameter, notifier),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInputAngka(
                label: 'Kapasitas aki (Ah)',
                nilaiAwal: parameter.kapasitasAkiAh,
                onChanged: notifier.ubahKapasitasAki,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInputAngka(
                label: 'Wp panel',
                nilaiAwal: parameter.wpPanel,
                onChanged: notifier.ubahWpPanel,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildInputAngka(
          label: 'Jam matahari efektif',
          nilaiAwal: parameter.jamMatahari,
          onChanged: notifier.ubahJamMatahari,
        ),
        const SizedBox(height: 8),
        _buildPengaturanLanjutan(context, parameter, notifier),
      ],
    );
  }

  Widget _buildPengaturanLanjutan(
    BuildContext context,
    ParameterSistem parameter,
    ParameterNotifier notifier,
  ) {
    return Theme(
      // Hilangkan garis divider default ExpansionTile supaya lebih rapi
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: 8, bottom: 4),
        title: const Text(
          'Pengaturan lanjutan',
          style: TextStyle(fontSize: 13),
        ),
        subtitle: const Text(
          'Sesuaikan efisiensi SCC dan inverter jika sudah tahu spesifikasi produk',
          style: TextStyle(fontSize: 11),
        ),
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInputAngka(
                  label: 'Efisiensi PWM (%)',
                  nilaiAwal: parameter.efisiensiPwm,
                  onChanged: notifier.ubahEfisiensiPwm,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInputAngka(
                  label: 'Efisiensi MPPT (%)',
                  nilaiAwal: parameter.efisiensiMppt,
                  onChanged: notifier.ubahEfisiensiMppt,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInputAngka(
                  label: 'Efisiensi PSW (%)',
                  nilaiAwal: parameter.efisiensiPsw,
                  onChanged: notifier.ubahEfisiensiPsw,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInputAngka(
                  label: 'Efisiensi MSW (%)',
                  nilaiAwal: parameter.efisiensiMsw,
                  onChanged: notifier.ubahEfisiensiMsw,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownScc(ParameterSistem parameter, ParameterNotifier notifier) {
    return DropdownButtonFormField<JenisScc>(
      initialValue: parameter.jenisScc,
      decoration: const InputDecoration(
        labelText: 'Jenis SCC',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: const [
        DropdownMenuItem(value: JenisScc.mppt, child: Text('MPPT')),
        DropdownMenuItem(value: JenisScc.pwm, child: Text('PWM')),
      ],
      onChanged: (value) {
        if (value != null) notifier.ubahJenisScc(value);
      },
    );
  }

  Widget _buildDropdownInverter(
      ParameterSistem parameter, ParameterNotifier notifier) {
    return DropdownButtonFormField<JenisInverter>(
      initialValue: parameter.jenisInverter,
      decoration: const InputDecoration(
        labelText: 'Jenis inverter',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: const [
        DropdownMenuItem(value: JenisInverter.psw, child: Text('PSW')),
        DropdownMenuItem(value: JenisInverter.msw, child: Text('MSW')),
      ],
      onChanged: (value) {
        if (value != null) notifier.ubahJenisInverter(value);
      },
    );
  }

  Widget _buildInputAngka({
    required String label,
    required double nilaiAwal,
    required ValueChanged<double> onChanged,
  }) {
    return TextFormField(
      initialValue: nilaiAwal.toStringAsFixed(0),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      keyboardType: TextInputType.number,
      onChanged: (text) {
        final nilai = double.tryParse(text);
        if (nilai != null && nilai > 0) {
          onChanged(nilai);
        }
      },
    );
  }
}