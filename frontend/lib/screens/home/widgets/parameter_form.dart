import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/parameter_sistem.dart';
import '../../../providers/parameter_provider.dart';
import 'validated_number_field.dart';

/// Form untuk mengatur parameter sistem PLTS: jenis SCC, jenis inverter,
/// kapasitas aki, tegangan aki, Wp panel, jam matahari efektif, dan
/// pengaturan lanjutan (efisiensi custom). Semua input angka divalidasi
/// batas wajarnya lewat ValidatedNumberField, supaya provider tidak
/// pernah menerima nilai 0/negatif yang bisa merusak hasil perhitungan.
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
            Expanded(child: _buildDropdownScc(parameter, notifier)),
            const SizedBox(width: 12),
            Expanded(child: _buildDropdownInverter(parameter, notifier)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ValidatedNumberField(
                label: 'Kapasitas aki (Ah)',
                initialValue: parameter.kapasitasAkiAh,
                min: 1,
                max: 10000,
                onChanged: notifier.ubahKapasitasAki,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: _buildDropdownVolt(parameter, notifier)),
          ],
        ),
        const SizedBox(height: 12),
        ValidatedNumberField(
          label: 'Wp panel',
          initialValue: parameter.wpPanel,
          min: 1,
          max: 2000,
          suffixText: 'Wp',
          onChanged: notifier.ubahWpPanel,
        ),
        const SizedBox(height: 12),
        ValidatedNumberField(
          label: 'Jam matahari efektif',
          initialValue: parameter.jamMatahari,
          min: 1,
          max: 8,
          suffixText: 'jam',
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
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: 8, bottom: 4),
        title: const Text('Pengaturan lanjutan', style: TextStyle(fontSize: 13)),
        subtitle: const Text(
          'Sesuaikan efisiensi SCC dan inverter jika sudah tahu spesifikasi produk',
          style: TextStyle(fontSize: 11),
        ),
        children: [
          Row(
            children: [
              Expanded(
                child: ValidatedNumberField(
                  label: 'Efisiensi PWM',
                  initialValue: parameter.efisiensiPwm,
                  min: 1,
                  max: 100,
                  suffixText: '%',
                  onChanged: notifier.ubahEfisiensiPwm,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ValidatedNumberField(
                  label: 'Efisiensi MPPT',
                  initialValue: parameter.efisiensiMppt,
                  min: 1,
                  max: 100,
                  suffixText: '%',
                  onChanged: notifier.ubahEfisiensiMppt,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ValidatedNumberField(
                  label: 'Efisiensi PSW',
                  initialValue: parameter.efisiensiPsw,
                  min: 1,
                  max: 100,
                  suffixText: '%',
                  onChanged: notifier.ubahEfisiensiPsw,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ValidatedNumberField(
                  label: 'Efisiensi MSW',
                  initialValue: parameter.efisiensiMsw,
                  min: 1,
                  max: 100,
                  suffixText: '%',
                  onChanged: notifier.ubahEfisiensiMsw,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownVolt(ParameterSistem parameter, ParameterNotifier notifier) {
    const pilihanVolt = [12.0, 24.0, 48.0];
    final nilaiSekarang =
        pilihanVolt.contains(parameter.voltAki) ? parameter.voltAki : 12.0;

    return DropdownButtonFormField<double>(
      initialValue: nilaiSekarang,
      decoration: const InputDecoration(
        labelText: 'Tegangan aki',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: pilihanVolt
          .map((volt) => DropdownMenuItem(
                value: volt,
                child: Text('${volt.toStringAsFixed(0)} V'),
              ))
          .toList(),
      onChanged: (value) {
        if (value != null) notifier.ubahVoltAki(value);
      },
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
}