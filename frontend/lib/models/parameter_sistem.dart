/// Jenis Solar Charge Controller
enum JenisScc { pwm, mppt }

/// Jenis inverter
enum JenisInverter { psw, msw }

/// Parameter sistem PLTS yang bisa diubah pengguna
/// Sesuai bagian "Silahkan rubah nilai berikut sesuai kebutuhan Anda" di Excel
class ParameterSistem {
  final JenisScc jenisScc;
  final double efisiensiPwm; // default 60%
  final double efisiensiMppt; // default 90%

  final JenisInverter jenisInverter;
  final double efisiensiPsw; // default 95%
  final double efisiensiMsw; // default 85%

  final double kapasitasAkiAh;
  final double voltAki; // default 12V

  final double wpPanel;
  final double jamMatahari; // default 4 jam

  const ParameterSistem({
    this.jenisScc = JenisScc.mppt,
    this.efisiensiPwm = 60,
    this.efisiensiMppt = 90,
    this.jenisInverter = JenisInverter.psw,
    this.efisiensiPsw = 95,
    this.efisiensiMsw = 85,
    required this.kapasitasAkiAh,
    this.voltAki = 12,
    required this.wpPanel,
    this.jamMatahari = 4,
  });

  /// Efisiensi SCC yang sedang aktif dipakai
  double get efisiensiSccAktif =>
      jenisScc == JenisScc.pwm ? efisiensiPwm : efisiensiMppt;

  /// Efisiensi inverter yang sedang aktif dipakai
  double get efisiensiInverterAktif =>
      jenisInverter == JenisInverter.psw ? efisiensiPsw : efisiensiMsw;

  ParameterSistem copyWith({
    JenisScc? jenisScc,
    JenisInverter? jenisInverter,
    double? kapasitasAkiAh,
    double? voltAki,
    double? wpPanel,
    double? jamMatahari,
  }) {
    return ParameterSistem(
      jenisScc: jenisScc ?? this.jenisScc,
      efisiensiPwm: efisiensiPwm,
      efisiensiMppt: efisiensiMppt,
      jenisInverter: jenisInverter ?? this.jenisInverter,
      efisiensiPsw: efisiensiPsw,
      efisiensiMsw: efisiensiMsw,
      kapasitasAkiAh: kapasitasAkiAh ?? this.kapasitasAkiAh,
      voltAki: voltAki ?? this.voltAki,
      wpPanel: wpPanel ?? this.wpPanel,
      jamMatahari: jamMatahari ?? this.jamMatahari,
    );
  }

  Map<String, dynamic> toJson() => {
        'jenis_scc': jenisScc.name.toUpperCase(),
        'jenis_inverter': jenisInverter.name.toUpperCase(),
        'kapasitas_aki_ah': kapasitasAkiAh,
        'volt_aki': voltAki,
        'wp_panel': wpPanel,
        'jam_matahari': jamMatahari,
      };

  factory ParameterSistem.fromJson(Map<String, dynamic> json) {
    return ParameterSistem(
      jenisScc: (json['jenis_scc'] as String).toUpperCase() == 'PWM'
          ? JenisScc.pwm
          : JenisScc.mppt,
      jenisInverter: (json['jenis_inverter'] as String).toUpperCase() == 'MSW'
          ? JenisInverter.msw
          : JenisInverter.psw,
      kapasitasAkiAh: (json['kapasitas_aki_ah'] as num).toDouble(),
      voltAki: (json['volt_aki'] as num?)?.toDouble() ?? 12,
      wpPanel: (json['wp_panel'] as num).toDouble(),
      jamMatahari: (json['jam_matahari'] as num?)?.toDouble() ?? 4,
    );
  }
}