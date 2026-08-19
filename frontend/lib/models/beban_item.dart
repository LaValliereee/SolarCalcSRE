import 'package:uuid/uuid.dart';

/// Merepresentasikan satu item beban listrik (alat/ruangan)
/// Contoh: Lampu Teras, 15 watt, nyala 11 jam per hari
class BebanItem {
  final String id;
  final String nama;
  final double dayaWatt;
  final double jamNyala;

  BebanItem({
    String? id,
    required this.nama,
    required this.dayaWatt,
    required this.jamNyala,
  }) : id = id ?? const Uuid().v4();

  /// Watt Hours = Daya (watt) x Total Nyala (jam)
  /// Sesuai rumus kolom F pada file Excel referensi
  double get wattHours => dayaWatt * jamNyala;

  BebanItem copyWith({String? nama, double? dayaWatt, double? jamNyala}) {
    return BebanItem(
      id: id,
      nama: nama ?? this.nama,
      dayaWatt: dayaWatt ?? this.dayaWatt,
      jamNyala: jamNyala ?? this.jamNyala,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nama': nama,
    'daya_watt': dayaWatt,
    'jam_nyala': jamNyala,
    'watt_hours': wattHours,
  };

  factory BebanItem.fromJson(Map<String, dynamic> json) => BebanItem(
    id: json['id'] as String?,
    nama: json['nama'] as String,
    dayaWatt: (json['daya_watt'] as num).toDouble(),
    jamNyala: (json['jam_nyala'] as num).toDouble(),
  );
}
