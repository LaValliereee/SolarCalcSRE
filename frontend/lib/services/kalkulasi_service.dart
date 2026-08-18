import '../models/beban_item.dart';
import '../models/hasil_perhitungan.dart';
import '../models/parameter_sistem.dart';

/// Service murni Dart (tanpa dependency UI) untuk menghitung kebutuhan PLTS.
/// Logika ini diterjemahkan dari file Excel referensi "Hitung Kebutuhan PLTS",
/// dan harus konsisten dengan implementasi Python di backend (kalkulasi.py)
/// agar hasil frontend dan backend selalu sama.
///
/// Alur perhitungan:
/// 1. Total Watt Hours = jumlah (daya x jam nyala) semua beban
/// 2. Kebutuhan aki = (total WH dikoreksi efisiensi inverter) / (volt x Ah),
///    dikali faktor DoD (2x untuk VRLA, 1.25x untuk LiFePO4), dibulatkan ke atas
/// 3. Kebutuhan panel = (total WH dikoreksi efisiensi SCC) / (jam matahari x Wp panel),
///    dibulatkan ke atas
class KalkulasiService {
  /// Menghitung total watt hours dari daftar beban
  static double hitungTotalWattHours(List<BebanItem> bebanList) {
    return bebanList.fold(0, (sum, item) => sum + item.wattHours);
  }

  /// Menghitung total daya (watt) dari daftar beban
  static double hitungTotalDaya(List<BebanItem> bebanList) {
    return bebanList.fold(0, (sum, item) => sum + item.dayaWatt);
  }

  /// Mengoreksi daya kebutuhan dengan efisiensi (rugi-rugi) komponen.
  /// Contoh: daya 7100 Wh dengan efisiensi 95% (PSW) akan dikoreksi jadi
  /// 7100 + (7100 * (100-95)/100) = 7455 Wh (menutupi rugi-rugi 5%)
  static double koreksiEfisiensi(double daya, double efisiensiPersen) {
    return daya + (daya * ((100 - efisiensiPersen) / 100));
  }

  /// Menghitung kebutuhan aki untuk satu jenis baterai
  ///
  /// [totalWattHours] total kebutuhan energi (Wh)
  /// [efisiensiInverter] efisiensi inverter yang dipakai (%)
  /// [voltAki] tegangan aki (V)
  /// [kapasitasAh] kapasitas aki (Ah)
  /// [faktorDod] 2.0 untuk VRLA (DoD 50%), 1.25 untuk LiFePO4 (DoD 80%)
  static HasilBaterai hitungKebutuhanBaterai({
    required double totalWattHours,
    required double efisiensiInverter,
    required double voltAki,
    required double kapasitasAh,
    required double faktorDod,
    required double efisiensiScc,
    required double jamMatahari,
    required double wpPanel,
  }) {
    // Koreksi daya dengan efisiensi inverter
    final dayaTerkoreksiInverter =
        koreksiEfisiensi(totalWattHours, efisiensiInverter);

    // Jumlah aki mentah = daya terkoreksi / (V x Ah)
    final jumlahAkiMentah = dayaTerkoreksiInverter / (voltAki * kapasitasAh);

    // Dikali faktor DoD, lalu dibulatkan ke atas
    final jumlahAkiRaw = jumlahAkiMentah * faktorDod;
    final jumlahAki = jumlahAkiRaw.ceil();

    // Daya jam aki total (Wh) = V x Ah x jumlah aki (pembulatan)
    final dayaJamAkiWh = (voltAki * kapasitasAh) * jumlahAki;

    // Kebutuhan panel dihitung dari total daya jam aki (skenario full power),
    // dikoreksi efisiensi SCC, dibagi (jam matahari x Wp panel)
    final dayaTerkoreksiScc = koreksiEfisiensi(dayaJamAkiWh, efisiensiScc);
    final jumlahPanelRaw = dayaTerkoreksiScc / (jamMatahari * wpPanel);
    final jumlahPanel = jumlahPanelRaw.ceil();

    return HasilBaterai(
      jumlahAkiRaw: jumlahAkiRaw,
      jumlahAki: jumlahAki,
      jumlahPanelRaw: jumlahPanelRaw,
      jumlahPanel: jumlahPanel,
      dayaJamAkiWh: dayaJamAkiWh,
    );
  }

  /// Fungsi utama: menghitung kebutuhan PLTS lengkap
  /// (total daya, total WH, dan hasil untuk kedua jenis baterai)
  static HasilPerhitungan hitung({
    required List<BebanItem> bebanList,
    required ParameterSistem parameter,
  }) {
    if (bebanList.isEmpty) {
      throw ArgumentError('Daftar beban tidak boleh kosong');
    }

    final totalDaya = hitungTotalDaya(bebanList);
    final totalWattHours = hitungTotalWattHours(bebanList);

    final vrla = hitungKebutuhanBaterai(
      totalWattHours: totalWattHours,
      efisiensiInverter: parameter.efisiensiInverterAktif,
      voltAki: parameter.voltAki,
      kapasitasAh: parameter.kapasitasAkiAh,
      faktorDod: 2.0, // VRLA, DoD 50%
      efisiensiScc: parameter.efisiensiSccAktif,
      jamMatahari: parameter.jamMatahari,
      wpPanel: parameter.wpPanel,
    );

    final lifepo4 = hitungKebutuhanBaterai(
      totalWattHours: totalWattHours,
      efisiensiInverter: parameter.efisiensiInverterAktif,
      voltAki: parameter.voltAki,
      kapasitasAh: parameter.kapasitasAkiAh,
      faktorDod: 1.25, // LiFePO4, DoD 80%
      efisiensiScc: parameter.efisiensiSccAktif,
      jamMatahari: parameter.jamMatahari,
      wpPanel: parameter.wpPanel,
    );

    return HasilPerhitungan(
      totalDayaWatt: totalDaya,
      totalWattHours: totalWattHours,
      vrla: vrla,
      lifepo4: lifepo4,
    );
  }
}