import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/tera_model.dart';
import '../../services/firestore_service.dart';

class TabChart extends StatefulWidget {
  const TabChart({super.key});

  @override
  State<TabChart> createState() => _TabChartState();
}

class _TabChartState extends State<TabChart> {
  final _svc = FirestoreService();
  int? _year;

  List<int> get _years {
    final now = DateTime.now().year;
    return List.generate(6, (i) => now - i);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Dropdown Tahun
          DropdownButtonFormField<int>(
            initialValue: _year,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.calendar_month,
                color: Colors.blueAccent,
              ),
              labelText: 'Pilih Tahun',
              labelStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
              filled: true,
              fillColor: isDark ? Colors.grey[800] : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
            items: _years
                .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                .toList(),
            onChanged: (v) => setState(() => _year = v),
          ),
          const SizedBox(height: 16),

          // Chart
          Expanded(
            child: _year == null
                ? Center(
                    child: Text(
                      'Pilih tahun untuk melihat grafik',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : StreamBuilder<List<Tera>>(
                    stream: _svc.streamByYear(_year!),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snap.hasData || snap.data!.isEmpty) {
                        return Center(
                          child: Text(
                            'Tidak ada data',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }

                      final list = snap.data!;
                      final grouped = groupBy<Tera, int>(
                        list,
                        (t) => t.tanggalTera.month,
                      );
                      final bars = List.generate(
                        12,
                        (m) => grouped[m + 1]?.length ?? 0,
                      );
                      final maxY = (bars.reduce((a, b) => a > b ? a : b) + 2)
                          .toDouble();

                      // Cari bulan dengan nilai tertinggi
                      final maxValue = bars.reduce((a, b) => a > b ? a : b);
                      final maxMonthIndex = bars.indexOf(maxValue);

                      return Card(
                        color: isDark ? Colors.grey[850] : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 4,
                        shadowColor: Colors.black12,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Ringkasan Data
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total: ${list.length}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                  Text(
                                    'Puncak: ${_monthLabel(maxMonthIndex)} ($maxValue)',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Chart
                              Expanded(
                                child: BarChart(
                                  BarChartData(
                                    maxY: maxY,
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      getDrawingHorizontalLine: (value) =>
                                          FlLine(
                                            // ignore: deprecated_member_use
                                            color: Colors.grey.withOpacity(0.1),
                                            strokeWidth: 1,
                                          ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    titlesData: FlTitlesData(
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 28,
                                          getTitlesWidget: (value, meta) {
                                            const months = [
                                              'J',
                                              'F',
                                              'M',
                                              'A',
                                              'M',
                                              'J',
                                              'J',
                                              'A',
                                              'S',
                                              'O',
                                              'N',
                                              'D',
                                            ];
                                            return Text(
                                              months[value.toInt()],
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey[800],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 30,
                                          getTitlesWidget: (value, meta) =>
                                              Text(
                                                value.toInt().toString(),
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                        ),
                                      ),
                                      topTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: false,
                                        ),
                                      ),
                                      rightTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: false,
                                        ),
                                      ),
                                    ),
                                    barGroups: List.generate(
                                      12,
                                      (i) => BarChartGroupData(
                                        x: i,
                                        barRods: [
                                          BarChartRodData(
                                            toY: bars[i].toDouble(),
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.blue.shade400,
                                                Colors.blue.shade200,
                                              ],
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            width: 18,
                                            backDrawRodData:
                                                BackgroundBarChartRodData(
                                                  show: true,
                                                  toY: maxY,
                                                  color: Colors.grey
                                                      // ignore: deprecated_member_use
                                                      .withOpacity(0.05),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    barTouchData: BarTouchData(
                                      enabled: true,
                                      touchTooltipData: BarTouchTooltipData(
                                        tooltipPadding: const EdgeInsets.all(8),
                                        tooltipRoundedRadius: 10,
                                        getTooltipItem:
                                            (group, groupIndex, rod, rodIndex) {
                                              return BarTooltipItem(
                                                '${rod.toY.toInt()} kali',
                                                GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color.fromARGB(
                                                    255,
                                                    245,
                                                    245,
                                                    245,
                                                  ),
                                                ),
                                              );
                                            },
                                      ),
                                    ),
                                  ),
                                  swapAnimationDuration: const Duration(
                                    milliseconds: 1200,
                                  ),
                                  swapAnimationCurve: Curves.easeInOut,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _monthLabel(int index) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[index];
  }
}
