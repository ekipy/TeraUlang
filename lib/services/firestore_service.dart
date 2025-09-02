import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/tera_model.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  CollectionReference get _col => _db.collection('tera');

  Future<Tera> create(Tera data) async {
    final id = _uuid.v4();
    final tera = Tera(
      id: id,
      namaPemilik: data.namaPemilik,
      alamatPasar: data.alamatPasar,
      kecamatan: data.kecamatan,
      noHp: data.noHp,
      jenisTimbangan: data.jenisTimbangan,
      kapasitas: data.kapasitas,
      satuan: data.satuan,
      anakTimbangan: data.anakTimbangan,
      biaya: data.biaya,
      tanggalTera: data.tanggalTera,
      createdAt: DateTime.now(),
    );
    await _col.doc(id).set(tera.toMap());
    return tera;
  }

  Future<void> update(Tera data) async {
    await _col.doc(data.id).update(data.toMap());
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }

  Stream<List<Tera>> streamAll() {
    return _col
        .orderBy('tanggalTera', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Tera.fromDoc(d)).toList());
  }

  Stream<List<Tera>> streamByYear(int year) {
    final start = DateTime(year, 1, 1);
    final end = DateTime(year + 1, 1, 1);
    return _col
        .where('tanggalTera', isGreaterThanOrEqualTo: start)
        .where('tanggalTera', isLessThan: end)
        .orderBy('tanggalTera', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Tera.fromDoc(d)).toList());
  }

  // Untuk monitoring kadaluarsa (tanggalTera + 1 tahun <= hari ini)
  Stream<List<Tera>> streamExpiredUpTo(DateTime day) {
    return _col.snapshots().map((s) {
      final all = s.docs.map((d) => Tera.fromDoc(d)).toList();
      return all.where((t) {
        final expiredDate = DateTime(
          t.tanggalTera.year + 1,
          t.tanggalTera.month,
          t.tanggalTera.day,
        );
        return !expiredDate.isAfter(day);
      }).toList();
    });
  }
}
