import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/firestore_service.dart';
import '../utils/notif_helper.dart';

class BottomSheetReport extends StatefulWidget {
  final ScrollController scrollController;
  const BottomSheetReport({super.key, required this.scrollController});

  @override
  State<BottomSheetReport> createState() => _BottomSheetReportState();
}

class _BottomSheetReportState extends State<BottomSheetReport> {
  final _svc = FirestoreService();
  int? _year;

  List<int> get _years {
    final now = DateTime.now().year;
    return List.generate(6, (i) => now - i);
  }

  Future<void> _generate() async {
    if (_year == null) {
      NotifHelper.showError(
        Navigator.of(context).context,
        'Silakan pilih tahun terlebih dahulu',
      );
      return;
    }

    final sub = _svc.streamByYear(_year!).listen((_) {});
    final list = await _svc.streamByYear(_year!).first;
    await sub.cancel();

    final excel = Excel.createExcel();
    final sheet = excel['Tera'];

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

    for (final t in list) {
      sheet.appendRow([
        TextCellValue(t.namaPemilik),
        TextCellValue(t.alamatPasar),
        TextCellValue(t.kecamatan),
        TextCellValue(t.noHp),
        TextCellValue(t.jenisTimbangan),
        TextCellValue(t.kapasitas),
        TextCellValue(t.satuan ?? ''),
        IntCellValue(t.anakTimbangan),
        DoubleCellValue(t.biaya.toDouble()),
        TextCellValue(f.format(t.tanggalTera)),
      ]);
    }

    final bytes = Uint8List.fromList(excel.encode()!);
    await FileSaver.instance.saveFile(
      name: 'report-tera-$_year',
      bytes: bytes,
      ext: 'xlsx',
      mimeType: MimeType.microsoftExcel,
    );

    // ignore: use_build_context_synchronously
    Navigator.pop(context); // Tutup bottom sheet
    NotifHelper.showSuccess(
      // ignore: use_build_context_synchronously
      Navigator.of(context).context,
      'Report berhasil diunduh',
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: widget.scrollController,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        Text(
          "E-Cerapan",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
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
    );
  }
}
