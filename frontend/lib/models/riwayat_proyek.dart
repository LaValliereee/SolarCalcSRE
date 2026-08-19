import 'dart:convert';

import 'package:uuid/uuid.dart';

import 'beban_item.dart';
import 'hasil_perhitungan.dart';
import 'parameter_sistem.dart';

/// Merepresentasikan satu proyek perhitungan PLTS yang disimpan secara lokal
/// (misal: "Rumah Pak Budi - Gresik"), lengkap dengan beban, parameter,
/// dan hasil perhitungannya, supaya bisa dibuka kembali dari halaman Riwayat.
class RiwayatProyek {
  final String id;
  final String namaProyek;
  final List<BebanItem> bebanList;
  final ParameterSistem parameter;
  final HasilPerhitungan hasil;
  final DateTime dibuatPada;

  RiwayatProyek({
    String? id,
    required this.namaProyek,
    required this.bebanList,
    required this.parameter,
    required this.hasil,
    DateTime? dibuatPada,
  }) : id = id ?? const Uuid().v4(),
       dibuatPada = dibuatPada ?? DateTime.now();

  /// Dikonversi ke Map untuk disimpan sebagai satu baris di SQLite.
  /// Field kompleks (beban, parameter) disimpan sebagai string JSON
  /// dalam satu kolom, supaya skema tabel tetap sederhana.
  Map<String, dynamic> toDbMap() => {
    'id': id,
    'nama_proyek': namaProyek,
    'beban_json': jsonEncode(bebanList.map((b) => b.toJson()).toList()),
    'parameter_json': jsonEncode(parameter.toJson()),
    'total_daya_watt': hasil.totalDayaWatt,
    'total_watt_hours': hasil.totalWattHours,
    'jumlah_aki_vrla': hasil.vrla.jumlahAki,
    'jumlah_panel_vrla': hasil.vrla.jumlahPanel,
    'jumlah_aki_lifepo4': hasil.lifepo4.jumlahAki,
    'jumlah_panel_lifepo4': hasil.lifepo4.jumlahPanel,
    'dibuat_pada': dibuatPada.toIso8601String(),
  };

  factory RiwayatProyek.fromDbMap(Map<String, dynamic> map) {
    final bebanJson = jsonDecode(map['beban_json'] as String) as List;
    final parameterJson =
        jsonDecode(map['parameter_json'] as String) as Map<String, dynamic>;

    final bebanList = bebanJson
        .map((b) => BebanItem.fromJson(b as Map<String, dynamic>))
        .toList();
    final parameter = ParameterSistem.fromJson(parameterJson);

    // Hasil dihitung ulang dari beban + parameter yang tersimpan,
    // bukan disimpan mentah, supaya selalu konsisten dengan versi
    // terbaru logika kalkulasi (lihat catatan di database_service.dart).
    return RiwayatProyek(
      id: map['id'] as String,
      namaProyek: map['nama_proyek'] as String,
      bebanList: bebanList,
      parameter: parameter,
      hasil: HasilPerhitungan(
        totalDayaWatt: (map['total_daya_watt'] as num).toDouble(),
        totalWattHours: (map['total_watt_hours'] as num).toDouble(),
        vrla: HasilBaterai(
          jumlahAkiRaw: (map['jumlah_aki_vrla'] as num).toDouble(),
          jumlahAki: map['jumlah_aki_vrla'] as int,
          jumlahPanelRaw: (map['jumlah_panel_vrla'] as num).toDouble(),
          jumlahPanel: map['jumlah_panel_vrla'] as int,
          dayaJamAkiWh: 0,
        ),
        lifepo4: HasilBaterai(
          jumlahAkiRaw: (map['jumlah_aki_lifepo4'] as num).toDouble(),
          jumlahAki: map['jumlah_aki_lifepo4'] as int,
          jumlahPanelRaw: (map['jumlah_panel_lifepo4'] as num).toDouble(),
          jumlahPanel: map['jumlah_panel_lifepo4'] as int,
          dayaJamAkiWh: 0,
        ),
      ),
      dibuatPada: DateTime.parse(map['dibuat_pada'] as String),
    );
  }
}
