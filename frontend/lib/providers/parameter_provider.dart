import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/parameter_sistem.dart';

/// Notifier untuk mengelola parameter sistem (SCC, inverter, aki, panel).
/// Terpisah dari bebanProvider supaya perubahan salah satunya tidak
/// memicu rebuild yang tidak perlu di bagian lain.
class ParameterNotifier extends Notifier<ParameterSistem> {
  @override
  ParameterSistem build() {
    // Nilai default mengikuti default di Excel referensi:
    // MPPT, PSW, aki 200Ah, panel 200Wp, 4 jam matahari.
    return const ParameterSistem(
      kapasitasAkiAh: 200,
      wpPanel: 200,
    );
  }

  void ubahJenisScc(JenisScc jenis) {
    state = state.copyWith(jenisScc: jenis);
  }

  void ubahJenisInverter(JenisInverter jenis) {
    state = state.copyWith(jenisInverter: jenis);
  }

  void ubahKapasitasAki(double ah) {
    state = state.copyWith(kapasitasAkiAh: ah);
  }

  void ubahVoltAki(double volt) {
    state = state.copyWith(voltAki: volt);
  }

  void ubahWpPanel(double wp) {
    state = state.copyWith(wpPanel: wp);
  }

  void ubahJamMatahari(double jam) {
    state = state.copyWith(jamMatahari: jam);
  }

  void reset() {
    state = const ParameterSistem(kapasitasAkiAh: 200, wpPanel: 200);
  }
}

final parameterProvider = NotifierProvider<ParameterNotifier, ParameterSistem>(
  ParameterNotifier.new,
);