import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class PresenceService {
  static void setupPresence() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final DatabaseReference statusRef = FirebaseDatabase.instance.ref(
      "status/${user.uid}",
    );

    final onlineData = {"online": true, "lastSeen": ServerValue.timestamp};

    final offlineData = {"online": false, "lastSeen": ServerValue.timestamp};

    // ✅ Monitor koneksi ke Firebase
    DatabaseReference connectedRef = FirebaseDatabase.instance.ref(
      ".info/connected",
    );

    connectedRef.onValue.listen((event) {
      final connected = event.snapshot.value as bool? ?? false;
      if (connected) {
        // Saat koneksi balik, set status online lagi
        statusRef.onDisconnect().set(offlineData);
        statusRef.set(onlineData);
      } else {
        // Saat offline manual
        statusRef.set(offlineData);
      }
    });
  }

  static Future<void> setOffline() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DatabaseReference statusRef = FirebaseDatabase.instance.ref(
      "status/${user.uid}",
    );

    final offlineData = {"online": false, "lastSeen": ServerValue.timestamp};

    await statusRef.set(offlineData);
  }
}
