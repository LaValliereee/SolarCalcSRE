import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/beban_item.dart';

/// Notifier untuk mengelola daftar beban listrik.
/// UI (screens/home) memanggil method di sini untuk tambah/hapus/edit beban,
/// dan otomatis rebuild setiap kali daftar berubah.
class BebanNotifier extends Notifier<List<BebanItem>> {
  @override
  List<BebanItem> build() {
    // State awal kosong; bisa diisi contoh default kalau mau demo cepat.
    return [];
  }

  void tambahBeban({
    required String nama,
    required double dayaWatt,
    required double jamNyala,
  }) {
    state = [
      ...state,
      BebanItem(nama: nama, dayaWatt: dayaWatt, jamNyala: jamNyala),
    ];
  }

  void hapusBeban(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void editBeban(
    String id, {
    String? nama,
    double? dayaWatt,
    double? jamNyala,
  }) {
    state = state.map((item) {
      if (item.id != id) return item;
      return item.copyWith(
        nama: nama,
        dayaWatt: dayaWatt,
        jamNyala: jamNyala,
      );
    }).toList();
  }

  void resetBeban() {
    state = [];
  }
}

final bebanProvider = NotifierProvider<BebanNotifier, List<BebanItem>>(
  BebanNotifier.new,
);

/// Provider turunan: total watt hours dari daftar beban saat ini.
/// Otomatis update setiap kali bebanProvider berubah.
final totalWattHoursProvider = Provider<double>((ref) {
  final bebanList = ref.watch(bebanProvider);
  return bebanList.fold(0.0, (sum, item) => sum + item.wattHours);
});

/// Provider turunan: total daya (watt) dari daftar beban saat ini.
final totalDayaProvider = Provider<double>((ref) {
  final bebanList = ref.watch(bebanProvider);
  return bebanList.fold(0.0, (sum, item) => sum + item.dayaWatt);
});