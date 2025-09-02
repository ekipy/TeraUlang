import 'package:cloud_firestore/cloud_firestore.dart';

class Tera {
  final String id;
  final String namaPemilik;
  final String alamatPasar; // dropdown pasar
  final String kecamatan; // dropdown kecamatan
  final String noHp;
  final String jenisTimbangan; // dropdown
  final String kapasitas; // string numeric
  final String? satuan; // 'KG' / 'G' / null
  final int anakTimbangan; // numeric
  final int biaya; // rupiah (integer)
  final DateTime tanggalTera; // datepicker
  final DateTime createdAt;

  Tera({
    required this.id,
    required this.namaPemilik,
    required this.alamatPasar,
    required this.kecamatan,
    required this.noHp,
    required this.jenisTimbangan,
    required this.kapasitas,
    required this.satuan,
    required this.anakTimbangan,
    required this.biaya,
    required this.tanggalTera,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'namaPemilik': namaPemilik,
    'alamatPasar': alamatPasar,
    'kecamatan': kecamatan,
    'noHp': noHp,
    'jenisTimbangan': jenisTimbangan,
    'kapasitas': kapasitas,
    'satuan': satuan,
    'anakTimbangan': anakTimbangan,
    'biaya': biaya,
    'tanggalTera': Timestamp.fromDate(tanggalTera),
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory Tera.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Tera(
      id: d['id'],
      namaPemilik: d['namaPemilik'],
      alamatPasar: d['alamatPasar'],
      kecamatan: d['kecamatan'],
      noHp: d['noHp'],
      jenisTimbangan: d['jenisTimbangan'],
      kapasitas: d['kapasitas'],
      satuan: d['satuan'],
      anakTimbangan: d['anakTimbangan'],
      biaya: d['biaya'],
      tanggalTera: (d['tanggalTera'] as Timestamp).toDate(),
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }
}
