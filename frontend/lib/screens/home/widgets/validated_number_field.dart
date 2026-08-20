import 'package:flutter/material.dart';

/// Input angka dengan validasi batas (min/max) yang menampilkan pesan
/// error langsung di bawah field saat nilai di luar batas wajar.
/// [onChanged] hanya dipanggil kalau nilai valid, jadi provider tidak
/// pernah menerima nilai 0/negatif/di luar batas yang bisa merusak
/// hasil perhitungan (misal pembagian dengan nol).
class ValidatedNumberField extends StatefulWidget {
  final String label;
  final double initialValue;
  final double min;
  final double? max;
  final ValueChanged<double> onChanged;
  final String? suffixText;

  const ValidatedNumberField({
    super.key,
    required this.label,
    required this.initialValue,
    required this.min,
    this.max,
    required this.onChanged,
    this.suffixText,
  });

  @override
  State<ValidatedNumberField> createState() => _ValidatedNumberFieldState();
}

class _ValidatedNumberFieldState extends State<ValidatedNumberField> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue.toStringAsFixed(
        widget.initialValue.truncateToDouble() == widget.initialValue ? 0 : 1,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validasiDanUpdate(String text) {
    final nilai = double.tryParse(text);

    if (text.trim().isEmpty) {
      setState(() => _errorText = 'Wajib diisi');
      return;
    }
    if (nilai == null) {
      setState(() => _errorText = 'Harus berupa angka');
      return;
    }
    if (nilai < widget.min) {
      setState(() => _errorText = 'Minimal ${widget.min.toStringAsFixed(0)}');
      return;
    }
    if (widget.max != null && nilai > widget.max!) {
      setState(() => _errorText = 'Maksimal ${widget.max!.toStringAsFixed(0)}');
      return;
    }

    setState(() => _errorText = null);
    widget.onChanged(nilai);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
        isDense: true,
        errorText: _errorText,
        suffixText: widget.suffixText,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: _validasiDanUpdate,
    );
  }
}