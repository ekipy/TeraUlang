import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tera_ulang/data/data_screen.dart';
import 'package:tera_ulang/screen/monitoring_screen.dart';
import 'package:tera_ulang/screen/report_screen.dart';
import 'package:tera_ulang/screen/tera_ulang_screen.dart';
import 'package:tera_ulang/services/presence_service.dart';
import 'package:tera_ulang/widgets/buttom_sheet_report.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isOnline = true;
  bool isLoading = true;

  final List<Map<String, dynamic>> menuItems = const [
    {"icon": Icons.scale, "title": "Tera Ulang", "screen": '/tera_form'},
    {"icon": Icons.dataset, "title": "Data Tera Ulang", "screen": '/data'},
    {"icon": Icons.monitor, "title": "Monitoring", "screen": '/monitoring'},
    {"icon": Icons.bar_chart, "title": "E-Cerapan", "screen": '/report'},
  ];

  Future<void> _logout() async {
    await PresenceService.setOffline();
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushNamed(context, '/login');
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      body: Stack(
        children: [
          /// HEADER
          Container(
            height: size.height * 0.18, // proporsional dengan tinggi layar
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
                    CircleAvatar(
                      radius: isTablet ? 40 : 28,
                      backgroundColor: Colors.transparent,
                      child: Icon(
                        Icons.person,
                        color: Colors.blue.shade800,
                        size: isTablet ? 45 : 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            FirebaseAuth.instance.currentUser?.email ?? "User",
                            style: GoogleFonts.poppins(
                              fontSize: isTablet ? 22 : 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.circle,
                                size: isTablet ? 18 : 14,
                                color: isOnline
                                    ? Colors.greenAccent
                                    : Colors.red,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isOnline ? "Online" : "Offline",
                                style: GoogleFonts.poppins(
                                  fontSize: isTablet ? 16 : 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.logout,
                        size: isTablet ? 28 : 24,
                        color: Colors.black,
                      ),
                      tooltip: "Logout",
                      onPressed: _logout,
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// BODY
          Container(
            margin: EdgeInsets.only(top: size.height * 0.16),
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
            child: Column(
              children: [
                SizedBox(height: size.height * 0.03),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 20 : 8,
                      vertical: 0,
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = isTablet ? 3 : 2;
                        return GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 20,
                                childAspectRatio: isTablet ? 1 : 0.85,
                              ),
                          itemCount: menuItems.length,
                          itemBuilder: (context, index) {
                            final item = menuItems[index];
                            return _DashboardCard(
                              icon: item["icon"],
                              title: item["title"],
                              isLoading: isLoading,
                              onTap: () {
                                if (item["title"] == "E-Cerapan") {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) {
                                      return DraggableScrollableSheet(
                                        initialChildSize: 0.5,
                                        minChildSize: 0.4,
                                        maxChildSize: 0.9,
                                        builder: (context, scrollController) {
                                          return Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                    top: Radius.circular(20),
                                                  ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 10,
                                                  offset: Offset(0, -2),
                                                ),
                                              ],
                                            ),
                                            padding: const EdgeInsets.all(16),
                                            child: BottomSheetReport(
                                              scrollController:
                                                  scrollController,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                } else if (item["screen"] is String) {
                                  Navigator.of(
                                    context,
                                  ).push(_createRoute(item["screen"]));
                                }
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool isLoading;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<_DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<_DashboardCard> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) => setState(() => _scale = 0.95);
  void _onTapUp(TapUpDetails details) => setState(() => _scale = 1.0);
  void _onTapCancel() => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: (details) {
        _onTapUp(details);
        widget.onTap();
      },
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF019DCE),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(4, 6),
              ),
            ],
          ),
          child: widget.isLoading
              ? Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.circle, size: 50, color: Colors.grey),
                      SizedBox(height: 12),
                      SizedBox(
                        height: 18,
                        width: 90,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.icon,
                      size: isTablet ? 70 : 55,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.title,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: isTablet ? 20 : 16,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Fungsi helper untuk animasi transisi
Route _createRoute(String screen) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        _getScreenFromRoute(screen),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Animasi Fade + Slide ke atas
      const begin = Offset(0.0, 0.1);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var fadeTween = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: FadeTransition(
          opacity: animation.drive(fadeTween),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 400),
  );
}

/// Map route name ke widget screen
Widget _getScreenFromRoute(String routeName) {
  switch (routeName) {
    case '/tera_form':
      return const TeraUlangScreen();
    case '/data':
      return const DataScreen();
    case '/monitoring':
      return const MonitoringScreen();
    case '/report':
      return const ReportScreen();
    default:
      return const Scaffold(
        body: Center(child: Text('Halaman tidak ditemukan')),
      );
  }
}
