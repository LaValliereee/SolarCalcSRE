import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/hasil_perhitungan.dart';
import '../services/kalkulasi_service.dart';
import 'beban_provider.dart';
import 'parameter_provider.dart';

/// Provider turunan (bukan Notifier) yang otomatis menghitung ulang
/// hasil PLTS setiap kali bebanProvider atau parameterProvider berubah.
///
/// Karena ini murni derivasi dari dua provider lain, tidak perlu state
/// manual — cukup `ref.watch` keduanya, Riverpod yang urus rebuild-nya.
///
/// Return null kalau daftar beban masih kosong (belum bisa dihitung),
/// supaya UI (screens/hasil) bisa tampilkan state kosong yang sesuai
/// alih-alih error.
final hasilPerhitunganProvider = Provider<HasilPerhitungan?>((ref) {
  final bebanList = ref.watch(bebanProvider);
  final parameter = ref.watch(parameterProvider);

  if (bebanList.isEmpty) return null;

  return KalkulasiService.hitung(
    bebanList: bebanList,
    parameter: parameter,
  );
});