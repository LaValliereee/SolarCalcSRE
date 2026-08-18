/// Hasil perhitungan kebutuhan aki dan panel untuk satu jenis baterai
class HasilBaterai {
  final double jumlahAkiRaw;
  final int jumlahAki;
  final double jumlahPanelRaw;
  final int jumlahPanel;
  final double dayaJamAkiWh;

  const HasilBaterai({
    required this.jumlahAkiRaw,
    required this.jumlahAki,
    required this.jumlahPanelRaw,
    required this.jumlahPanel,
    required this.dayaJamAkiWh,
  });

  Map<String, dynamic> toJson() => {
        'jumlah_aki_raw': jumlahAkiRaw,
        'jumlah_aki': jumlahAki,
        'jumlah_panel_raw': jumlahPanelRaw,
        'jumlah_panel': jumlahPanel,
        'daya_jam_aki_wh': dayaJamAkiWh,
      };
}

/// Hasil perhitungan lengkap kebutuhan PLTS
/// Menyertakan dua skenario baterai: VRLA (DoD 50%) dan LiFePO4 (DoD 80%)
class HasilPerhitungan {
  final double totalDayaWatt;
  final double totalWattHours;
  final HasilBaterai vrla;
  final HasilBaterai lifepo4;

  const HasilPerhitungan({
    required this.totalDayaWatt,
    required this.totalWattHours,
    required this.vrla,
    required this.lifepo4,
  });

  Map<String, dynamic> toJson() => {
        'total_daya_watt': totalDayaWatt,
        'total_watt_hours': totalWattHours,
        'vrla': vrla.toJson(),
        'lifepo4': lifepo4.toJson(),
      };
}