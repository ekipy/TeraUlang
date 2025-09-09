import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/tera_model.dart';
import '../../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen>
    with SingleTickerProviderStateMixin {
  bool isOnline = true;
  final _svc = FirestoreService();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Tera> _recordsOnSelected = [];
  bool _showCalendar = false;

  // Animasi untuk slide kalender
  late AnimationController _calendarController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _calendarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _calendarController, curve: Curves.easeOut),
        );
    _fadeAnimation = CurvedAnimation(
      parent: _calendarController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? "User";
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final baseHeaderHeight = size.height * 0.15;
    final headerH = _showCalendar ? baseHeaderHeight * 1.1 : baseHeaderHeight;

    return Scaffold(
      body: ScrollConfiguration(
        behavior: _NoGlowScrollBehavior(),
        child: Stack(
          children: [
            // ======= HEADER =======
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: headerH,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(247, 205, 56, 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 24 : 16,
                    vertical: isTablet ? 20 : 12,
                  ),
                  child: Row(
                    children: [
                      // Tombol back
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.black,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 16),

                      // Avatar
                      CircleAvatar(
                        radius: isTablet ? 28 : 22,
                        backgroundColor: Colors.transparent,
                        child: Icon(
                          Icons.person,
                          color: Colors.blue.shade800,
                          size: isTablet ? 40 : 30,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Email dan status
                      Expanded(
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 500),
                          tween: Tween(begin: 0, end: 1),
                          builder: (context, value, child) =>
                              Opacity(opacity: value, child: child),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                userEmail,
                                style: GoogleFonts.poppins(
                                  fontSize: isTablet ? 18 : 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: isTablet ? 14 : 10,
                                    color: isOnline
                                        ? Colors.greenAccent
                                        : Colors.redAccent,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isOnline ? "Online" : "Offline",
                                    style: GoogleFonts.poppins(
                                      fontSize: isTablet ? 14 : 12,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Tombol toggle kalender
                      IconButton(
                        icon: Icon(
                          _showCalendar ? Icons.close : Icons.calendar_month,
                          color: Colors.black,
                          size: isTablet ? 28 : 24,
                        ),
                        onPressed: () {
                          setState(() {
                            _showCalendar = !_showCalendar;
                            if (_showCalendar) {
                              _calendarController.forward();
                            } else {
                              _calendarController.reverse();
                              _recordsOnSelected = [];
                              _selectedDay = null;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ======= BODY =======
            Container(
              margin: EdgeInsets.only(top: headerH - 16),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/Background.png'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                top: false,
                child: StreamBuilder<List<Tera>>(
                  stream: _svc.streamAll(),
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return const Center(
                        child: SpinKitCircle(color: Colors.amber),
                      );
                    }

                    final all = snap.data!;
                    final initialTeraMap = <DateTime, List<Tera>>{};
                    final expiryMap = <DateTime, List<Tera>>{};

                    for (final t in all) {
                      final initialKey = DateTime(
                        t.tanggalTera.year,
                        t.tanggalTera.month,
                        t.tanggalTera.day,
                      );
                      initialTeraMap.putIfAbsent(initialKey, () => []).add(t);

                      final expiryKey = DateTime(
                        t.tanggalTera.year + 1,
                        t.tanggalTera.month,
                        t.tanggalTera.day,
                      );
                      expiryMap.putIfAbsent(expiryKey, () => []).add(t);
                    }

                    List<Tera> getEventsForDay(DateTime day) {
                      final dateKey = DateTime(day.year, day.month, day.day);
                      return [
                        ...(initialTeraMap[dateKey] ?? []),
                        ...(expiryMap[dateKey] ?? []),
                      ];
                    }

                    return Column(
                      children: [
                        // Animasi kalender
                        SizeTransition(
                          sizeFactor: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: _showCalendar
                                ? Container(
                                    margin: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      // ignore: deprecated_member_use
                                      color: Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: TableCalendar<Tera>(
                                      focusedDay: _focusedDay,
                                      firstDay: DateTime(
                                        DateTime.now().year - 3,
                                      ),
                                      lastDay: DateTime(
                                        DateTime.now().year + 3,
                                      ),
                                      calendarFormat: CalendarFormat.month,
                                      eventLoader: getEventsForDay,
                                      selectedDayPredicate: (d) =>
                                          isSameDay(d, _selectedDay),
                                      onDaySelected: (selected, focused) {
                                        setState(() {
                                          _selectedDay = selected;
                                          _focusedDay = focused;
                                          _recordsOnSelected = getEventsForDay(
                                            selected,
                                          );
                                        });
                                      },
                                      headerStyle: HeaderStyle(
                                        titleTextStyle: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: size.width * 0.04,
                                          color: Colors.black87,
                                        ),
                                        formatButtonVisible: false,
                                        leftChevronIcon: const Icon(
                                          Icons.chevron_left,
                                          color: Colors.black,
                                        ),
                                        rightChevronIcon: const Icon(
                                          Icons.chevron_right,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),

                        // Animasi list data
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _selectedDay == null
                                ? _buildDefaultState(size)
                                : _recordsOnSelected.isEmpty
                                ? _buildEmptyState(size)
                                : ListView.builder(
                                    key: ValueKey(_selectedDay),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    itemCount: _recordsOnSelected.length,
                                    itemBuilder: (context, i) {
                                      final t = _recordsOnSelected[i];
                                      final tglAwal = DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(t.tanggalTera);
                                      final tglExp = DateFormat('dd/MM/yyyy')
                                          .format(
                                            DateTime(
                                              t.tanggalTera.year + 1,
                                              t.tanggalTera.month,
                                              t.tanggalTera.day,
                                            ),
                                          );
                                      return AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeOut,
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),
                                        child: Card(
                                          // ignore: deprecated_member_use
                                          color: Colors.white.withOpacity(0.9),
                                          elevation: 6,
                                          shadowColor: Colors.black26,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                              horizontal: 16,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  t.namaPemilik,
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: size.width * 0.04,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${t.alamatPasar}, ${t.kecamatan}\n'
                                                  'HP: ${t.noHp}\n'
                                                  'Jenis: ${t.jenisTimbangan} (${t.anakTimbangan} anak) ${t.kapasitas} ${t.satuan ?? ''}\n'
                                                  'Tera: $tglAwal • Exp: $tglExp',
                                                  style: GoogleFonts.poppins(
                                                    fontSize:
                                                        size.width * 0.035,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Size size) {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month,
              size: size.width * 0.2,
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.7),
            ),
            const SizedBox(height: 12),
            Text(
              'Klik tanggal bertanda untuk melihat detail tera',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: size.width * 0.04,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildDefaultState(Size size) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.info_outline,
          size: size.width * 0.2,
          // ignore: deprecated_member_use
          color: Colors.white.withOpacity(0.8),
        ),
        const SizedBox(height: 12),
        Text(
          'Klik tanggal bertanda untuk melihat detail Tera Data',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: size.width * 0.04,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );
}

class _NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
