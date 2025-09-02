import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/tera_model.dart';
import '../../services/firestore_service.dart';

class TabData extends StatefulWidget {
  const TabData({super.key});

  @override
  State<TabData> createState() => _TabDataState();
}

class _TabDataState extends State<TabData> {
  final _svc = FirestoreService();
  int? _year;
  String _searchQuery = '';
  late final List<int> _years;

  @override
  void initState() {
    super.initState();
    final currentYear = DateTime.now().year;
    _years = List.generate(
      currentYear - 2019,
      (index) => 2020 + index,
    ).reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Background abu terang
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row untuk Search Field dan Dropdown Filter
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: GoogleFonts.poppins(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Cari nama pemilik...',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<int>(
                    initialValue: _year,
                    decoration: InputDecoration(
                      labelText: 'Tahun',
                      labelStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    items: _years
                        .map(
                          (y) => DropdownMenuItem(value: y, child: Text('$y')),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _year = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Tabel Data
            Expanded(
              child: _year == null
                  ? Center(
                      child: Text(
                        'Pilih tahun untuk melihat data',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : StreamBuilder<List<Tera>>(
                      stream: _svc.streamByYear(_year!),
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (!snap.hasData || snap.data!.isEmpty) {
                          return Center(
                            child: Text(
                              'Tidak ada data',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }

                        // Filter data berdasarkan query search
                        final filteredData = snap.data!
                            .where(
                              (t) => t.namaPemilik.toLowerCase().contains(
                                _searchQuery.toLowerCase(),
                              ),
                            )
                            .toList();

                        final currencyFormat = NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp',
                          decimalDigits: 0,
                        );
                        final dateFormat = DateFormat('dd/MM/yyyy');

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStateColor.resolveWith(
                              (states) => Colors.yellow,
                            ),
                            headingTextStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            dataRowColor: WidgetStateColor.resolveWith(
                              (states) => Colors.white,
                            ),
                            dataTextStyle: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                            columns: const [
                              DataColumn(label: Text('Pemilik')),
                              DataColumn(label: Text('Jenis')),
                              DataColumn(label: Text('Alamat')),
                              DataColumn(label: Text('Kecamatan')),
                              DataColumn(label: Text('Tanggal Tera')),
                              DataColumn(label: Text('Anak Timbangan')),
                              DataColumn(label: Text('No HP')),
                              DataColumn(label: Text('Kapasitas')),
                              DataColumn(label: Text('Biaya')),
                            ],
                            rows: filteredData.map((t) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(t.namaPemilik)),
                                  DataCell(Text(t.jenisTimbangan)),
                                  DataCell(Text(t.alamatPasar)),
                                  DataCell(Text(t.kecamatan)),
                                  DataCell(
                                    Text(dateFormat.format(t.tanggalTera)),
                                  ),
                                  DataCell(Text('${t.anakTimbangan}')),
                                  DataCell(Text(t.noHp)),
                                  DataCell(
                                    Text('${t.kapasitas} ${t.satuan ?? ''}'),
                                  ),
                                  DataCell(
                                    Text(
                                      currencyFormat.format(t.biaya),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
