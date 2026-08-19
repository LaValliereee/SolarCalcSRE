import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/beban_item.dart';
import '../models/hasil_perhitungan.dart';
import '../models/parameter_sistem.dart';

/// Service untuk generate dan membagikan laporan PDF hasil perhitungan
/// kebutuhan PLTS. Memakai package `pdf` untuk membangun dokumen dan
/// `printing` untuk membuka dialog cetak/bagikan/simpan bawaan platform
/// (browser print dialog di web, share sheet di Android/iOS).
class PdfExportService {
  // Warna tosca untuk PDF — diambil dari brand color
  static final PdfColor _toscaHeaderBg = PdfColor.fromHex('#E0F2F1');
  static final PdfColor _toscaAccent = PdfColor.fromHex('#0D9488');

  /// Generate PDF lalu langsung tampilkan dialog cetak/bagikan/simpan.
  /// Dipanggil dari tombol "Export PDF" di HasilScreen.
  static Future<void> exportDanBagikan({
    required String namaProyek,
    required List<BebanItem> bebanList,
    required ParameterSistem parameter,
    required HasilPerhitungan hasil,
  }) async {
    final pdfBytes = await _buatDokumen(
      namaProyek: namaProyek,
      bebanList: bebanList,
      parameter: parameter,
      hasil: hasil,
    );

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: '${_slugify(namaProyek)}_solacalcsre.pdf',
    );
  }

  static Future<Uint8List> _buatDokumen({
    required String namaProyek,
    required List<BebanItem> bebanList,
    required ParameterSistem parameter,
    required HasilPerhitungan hasil,
  }) async {
    final doc = pw.Document();
    final tanggal = DateTime.now();
    final tanggalStr = '${tanggal.day}/${tanggal.month}/${tanggal.year}';

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(namaProyek, tanggalStr),
          pw.SizedBox(height: 20),
          _buildRingkasan(hasil),
          pw.SizedBox(height: 20),
          _buildTabelBeban(bebanList),
          pw.SizedBox(height: 20),
          _buildParameterSistem(parameter),
          pw.SizedBox(height: 20),
          _buildHasilPerbandingan(hasil),
          pw.SizedBox(height: 24),
          pw.Text(
            'Dibuat otomatis oleh SolaCalcSRE - Sumber Rejeki Energy',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _buildHeader(String namaProyek, String tanggal) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Laporan Kebutuhan PLTS',
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: _toscaAccent,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text('Proyek: $namaProyek', style: const pw.TextStyle(fontSize: 12)),
        pw.Text(
          'Tanggal: $tanggal',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
        pw.Divider(),
      ],
    );
  }

  static pw.Widget _buildRingkasan(HasilPerhitungan hasil) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _buildRingkasanItem(
          'Total Watt Hours',
          '${hasil.totalWattHours.toStringAsFixed(0)} Wh',
        ),
        _buildRingkasanItem(
          'Total Daya',
          '${hasil.totalDayaWatt.toStringAsFixed(0)} W',
        ),
      ],
    );
  }

  static pw.Widget _buildRingkasanItem(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  static pw.Widget _buildTabelBeban(List<BebanItem> bebanList) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Daftar Beban Listrik',
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 6),
        pw.TableHelper.fromTextArray(
          headerStyle: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
          ),
          cellStyle: const pw.TextStyle(fontSize: 9),
          headerDecoration: pw.BoxDecoration(color: _toscaHeaderBg),
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.centerRight,
            2: pw.Alignment.centerRight,
            3: pw.Alignment.centerRight,
          },
          headers: ['Nama', 'Daya (W)', 'Jam nyala', 'Watt Hours'],
          data: bebanList
              .map(
                (item) => [
                  item.nama,
                  item.dayaWatt.toStringAsFixed(0),
                  item.jamNyala.toStringAsFixed(0),
                  item.wattHours.toStringAsFixed(0),
                ],
              )
              .toList(),
        ),
      ],
    );
  }

  static pw.Widget _buildParameterSistem(ParameterSistem parameter) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Parameter Sistem',
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 6),
        pw.TableHelper.fromTextArray(
          headerStyle: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
          ),
          cellStyle: const pw.TextStyle(fontSize: 9),
          headerDecoration: pw.BoxDecoration(color: _toscaHeaderBg),
          headers: ['Parameter', 'Nilai'],
          data: [
            ['Jenis SCC', parameter.jenisScc.name.toUpperCase()],
            ['Jenis Inverter', parameter.jenisInverter.name.toUpperCase()],
            [
              'Kapasitas Aki',
              '${parameter.kapasitasAkiAh.toStringAsFixed(0)} Ah',
            ],
            ['Tegangan Aki', '${parameter.voltAki.toStringAsFixed(0)} V'],
            ['Wp Panel', '${parameter.wpPanel.toStringAsFixed(0)} Wp'],
            [
              'Jam Matahari Efektif',
              '${parameter.jamMatahari.toStringAsFixed(0)} jam',
            ],
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildHasilPerbandingan(HasilPerhitungan hasil) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Perbandingan Jenis Baterai',
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 6),
        pw.TableHelper.fromTextArray(
          headerStyle: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
          ),
          cellStyle: const pw.TextStyle(fontSize: 9),
          headerDecoration: pw.BoxDecoration(color: _toscaHeaderBg),
          headers: ['Jenis Baterai', 'Jumlah Aki', 'Jumlah Panel'],
          data: [
            [
              'VRLA (DoD 50%)',
              '${hasil.vrla.jumlahAki}',
              '${hasil.vrla.jumlahPanel}',
            ],
            [
              'LiFePO4 (DoD 80%)',
              '${hasil.lifepo4.jumlahAki}',
              '${hasil.lifepo4.jumlahPanel}',
            ],
          ],
        ),
      ],
    );
  }

  static String _slugify(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }
}
