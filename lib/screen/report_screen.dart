import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/firestore_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _svc = FirestoreService();
  int? _year;

  List<int> get _years {
    final now = DateTime.now().year;
    return List.generate(6, (i) => now - i);
  }

  Future<void> _generate() async {
    if (_year == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tahun terlebih dahulu')),
      );
      return;
    }

    // Ambil data sesuai tahun
    final sub = _svc.streamByYear(_year!).listen((_) {});
    final list = await _svc.streamByYear(_year!).first;
    await sub.cancel();

    final excel = Excel.createExcel();
    final sheet = excel['Tera'];

    //header
    sheet.appendRow([
      TextCellValue('Nama Pemilik'),
      TextCellValue('Alamat Pasar'),
      TextCellValue('Kecamatan'),
      TextCellValue('No. HP'),
      TextCellValue('Jenis Timbangan'),
      TextCellValue('Kapasitas'),
      TextCellValue('Satuan'),
      TextCellValue('Anak Timbangan'),
      TextCellValue('Biaya'),
      TextCellValue('Tanggal Tera Ulang'),
    ]);

    final f = DateFormat('dd/MM/yyyy');

    // Data
    for (final t in list) {
      sheet.appendRow([
        TextCellValue(t.namaPemilik),
        TextCellValue(t.alamatPasar),
        TextCellValue(t.kecamatan),
        TextCellValue(t.noHp),
        TextCellValue(t.jenisTimbangan),
        TextCellValue(t.kapasitas), // angka desimal
        TextCellValue(t.satuan ?? ''), // string
        IntCellValue(t.anakTimbangan), // angka integer
        DoubleCellValue(t.biaya.toDouble()), // angka desimal
        TextCellValue(f.format(t.tanggalTera)), // tanggal string
      ]);
    }

    // Simpan file
    final bytes = Uint8List.fromList(excel.encode()!);
    await FileSaver.instance.saveFile(
      name: 'report-tera-$_year',
      bytes: bytes,
      ext: 'xlsx',
      mimeType: MimeType.microsoftExcel,
    );

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Report berhasil diunduh')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              initialValue: _year,
              decoration: const InputDecoration(labelText: 'Tahun'),
              items: _years
                  .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                  .toList(),
              onChanged: (v) => setState(() => _year = v),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _generate,
                child: const Text('Generate'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
