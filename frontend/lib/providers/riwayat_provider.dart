import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/riwayat_proyek.dart';
import '../services/database_service.dart';
import 'beban_provider.dart';
import 'hasil_provider.dart';
import 'parameter_provider.dart';

final _databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

/// Notifier async untuk daftar riwayat proyek dari database lokal.
/// AsyncNotifier menangani loading/error state secara otomatis,
/// jadi UI tinggal pakai .when(data:, loading:, error:) di screens/riwayat.
class RiwayatNotifier extends AsyncNotifier<List<RiwayatProyek>> {
  @override
  Future<List<RiwayatProyek>> build() async {
    final db = ref.read(_databaseServiceProvider);
    return db.ambilSemuaProyek();
  }

  /// Menyimpan proyek baru dari state beban + parameter + hasil saat ini,
  /// lalu refresh daftar riwayat.
  Future<void> simpanProyekSaatIni(String namaProyek) async {
    final bebanList = ref.read(bebanProvider);
    final parameter = ref.read(parameterProvider);
    final hasil = ref.read(hasilPerhitunganProvider);

    if (hasil == null) {
      throw StateError('Belum ada hasil perhitungan untuk disimpan');
    }

    final proyek = RiwayatProyek(
      namaProyek: namaProyek,
      bebanList: bebanList,
      parameter: parameter,
      hasil: hasil,
    );

    final db = ref.read(_databaseServiceProvider);
    await db.simpanProyek(proyek);

    // Refresh state supaya UI riwayat langsung update
    state = const AsyncLoading();
    state = AsyncData(await db.ambilSemuaProyek());
  }

  Future<void> hapusProyek(String id) async {
    final db = ref.read(_databaseServiceProvider);
    await db.hapusProyek(id);

    state = const AsyncLoading();
    state = AsyncData(await db.ambilSemuaProyek());
  }
}

final riwayatProvider =
    AsyncNotifierProvider<RiwayatNotifier, List<RiwayatProyek>>(
  RiwayatNotifier.new,
);