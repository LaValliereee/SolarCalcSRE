import 'package:flutter/material.dart';

/// Widget root aplikasi SolaCalcSRE.
/// Untuk sekarang masih pakai halaman placeholder sederhana;
/// nanti diganti dengan HomeScreen setelah screens/ dibangun.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SolaCalcSRE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: const _PlaceholderHome(),
    );
  }
}

/// Halaman sementara supaya aplikasi bisa langsung dijalankan dan dites
/// sebelum HomeScreen sungguhan (dengan tab Input beban / Hasil) dibuat.
class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SolaCalcSRE')),
      body: const Center(
        child: Text('Setup providers berhasil. Siap lanjut ke screens/.'),
      ),
    );
  }
}