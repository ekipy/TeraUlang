import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tab_data.dart';
import 'tab_chart.dart';

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);

  @override
  Widget build(BuildContext context) {
    final double fontSize = MediaQuery.of(context).size.width * 0.035;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Soft background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Flat design
        title: Text(
          'Data Tera',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: Colors.blueAccent,
          labelColor: Colors.blueAccent,
          unselectedLabelColor: Colors.grey,
          labelStyle: GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Data'),
            Tab(text: 'Grafik'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: TabBarView(
            controller: _tab,
            children: const [TabData(), TabChart()],
          ),
        ),
      ),
    );
  }
}
