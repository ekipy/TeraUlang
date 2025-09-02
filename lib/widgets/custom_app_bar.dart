import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isOnline;
  final List<Widget>? actions;
  final bool showProfile;

  const CustomAppBar({
    super.key,
    required this.isOnline,
    this.actions,
    this.showProfile = true,
  });

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? "User";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      height: preferredSize.height,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(247, 205, 56, 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
              size: 20,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),

          // Email dan status online
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                userEmail,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 10,
                    color: isOnline ? Colors.greenAccent : Colors.redAccent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isOnline ? "Online" : "Offline",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color.fromARGB(179, 0, 0, 0),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),
          // action calender
          if (actions != null) ...actions!,

          // Avatar Profile
          if (showProfile)
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.transparent,
              child: Icon(Icons.person, color: Colors.blue.shade800, size: 28),
            ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
