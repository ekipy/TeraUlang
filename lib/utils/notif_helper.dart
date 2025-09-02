import 'dart:ui';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class NotifHelper {
  static const Color primaryBlue = Color(0xFF019DCE);

  /// Notifikasi sukses dengan Lottie + Glassmorphism
  static void showSuccess(BuildContext context, String message) {
    Flushbar(
      backgroundColor: Colors.transparent,
      boxShadows: [
        BoxShadow(
          // ignore: deprecated_member_use
          color: Colors.black.withOpacity(0.2),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(16),
      flushbarPosition: FlushbarPosition.TOP,
      animationDuration: const Duration(milliseconds: 500),
      forwardAnimationCurve: Curves.easeOutBack,
      messageText: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: primaryBlue.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Lottie.asset(
                  'assets/Success.json',
                  width: 60,
                  height: 60,
                  repeat: false,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).show(context);
  }

  /// Notifikasi error dengan Lottie + Glassmorphism
  static void showError(BuildContext context, String message) {
    Flushbar(
      backgroundColor: Colors.transparent,
      boxShadows: [
        BoxShadow(
          // ignore: deprecated_member_use
          color: Colors.black.withOpacity(0.2),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(16),
      flushbarPosition: FlushbarPosition.TOP,
      animationDuration: const Duration(milliseconds: 500),
      forwardAnimationCurve: Curves.easeOutBack,
      messageText: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: Colors.redAccent.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Lottie.asset(
                  'assets/Error.json',
                  width: 80,
                  height: 80,
                  repeat: false,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).show(context);
  }
}
