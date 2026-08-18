import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/beban_item.dart';
import 'package:frontend/models/parameter_sistem.dart';
import 'package:frontend/services/kalkulasi_service.dart';

// Nilai pembanding diambil langsung dari file Excel referensi
// "Hitung_Kebutuhan_PLTS_OK.xlsx" agar hasil aplikasi bisa diverifikasi.
void main() {
  group('KalkulasiService', () {
    late List<BebanItem> bebanContohExcel;
    late ParameterSistem parameterContohExcel;

    setUp(() {
      bebanContohExcel = [
        BebanItem(nama: 'Lampu Teras', dayaWatt: 15, jamNyala: 11),
        BebanItem(nama: 'Lampu Ruang Tamu', dayaWatt: 10, jamNyala: 4),
        BebanItem(nama: 'Lampu Ruang Keluarga', dayaWatt: 7, jamNyala: 4),
        BebanItem(nama: 'Lampu Dapur', dayaWatt: 10, jamNyala: 3),
        BebanItem(nama: 'Lampu Jeding', dayaWatt: 5, jamNyala: 3),
        BebanItem(nama: 'Lampu Kamar Tidur 1', dayaWatt: 5, jamNyala: 4),
        BebanItem(nama: 'Lampu Kamar Tidur 2', dayaWatt: 5, jamNyala: 4),
        BebanItem(nama: 'Lampu Halaman Belakang', dayaWatt: 10, jamNyala: 11),
        BebanItem(nama: 'Lampu Garasi', dayaWatt: 7, jamNyala: 2),
        BebanItem(nama: 'TV', dayaWatt: 70, jamNyala: 4),
        BebanItem(nama: 'Kulkas', dayaWatt: 80, jamNyala: 6),
        BebanItem(nama: 'Spare', dayaWatt: 20, jamNyala: 2),
      ];

      parameterContohExcel = const ParameterSistem(
        jenisScc: JenisScc.mppt,
        jenisInverter: JenisInverter.psw,
        kapasitasAkiAh: 200,
        wpPanel: 200,
        jamMatahari: 4,
      );
    });

    test('total daya sesuai Excel (244 W)', () {
      final total = KalkulasiService.hitungTotalDaya(bebanContohExcel);
      expect(total, 244);
    });

    test('total watt hours sesuai Excel (1242 Wh)', () {
      final total = KalkulasiService.hitungTotalWattHours(bebanContohExcel);
      expect(total, 1242);
    });

    test('koreksi efisiensi sesuai contoh Excel (7100 -> 7455 dengan PSW 95%)',
        () {
      final hasil = KalkulasiService.koreksiEfisiensi(7100, 95);
      expect(hasil, closeTo(7455, 0.01));
    });

    test('hitung() mengembalikan hasil untuk kedua jenis baterai', () {
      final hasil = KalkulasiService.hitung(
        bebanList: bebanContohExcel,
        parameter: parameterContohExcel,
      );

      expect(hasil.totalDayaWatt, 244);
      expect(hasil.totalWattHours, 1242);
      expect(hasil.vrla.jumlahAki, greaterThan(0));
      expect(hasil.lifepo4.jumlahAki, greaterThan(0));

      // LiFePO4 (DoD 80%) harus butuh aki lebih sedikit dari VRLA (DoD 50%)
      expect(hasil.lifepo4.jumlahAki, lessThanOrEqualTo(hasil.vrla.jumlahAki));
    });

    test('hitung() melempar error jika daftar beban kosong', () {
      expect(
        () => KalkulasiService.hitung(
          bebanList: [],
          parameter: parameterContohExcel,
        ),
        throwsArgumentError,
      );
    });
  });
}