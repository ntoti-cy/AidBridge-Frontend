import 'dart:convert';

import 'package:aid_bridge/Controllers/help/db_helper.dart';
import 'package:aid_bridge/Services/auth_service.dart';

class SyncRepository {
  final DBHelper db;
  final AuthService authService;

  SyncRepository({required this.db, required this.authService});

  Future<Map<String, dynamic>> synchronize() async {
    // Read pending synchronization records
    final pending = await db.pendingSync();

    if (pending.isEmpty) {
      return {"synced": 0, "failed": 0, "message": "Nothing to synchronize."};
    }

    // Build the records that will be sent to the backend
    final List<Map<String, dynamic>> records = pending.map((row) {
      final payload = jsonDecode(row["payload"]);

      // Attach the local SQLite ID so the backend can return it
      payload["local_id"] = row["id"];

      return Map<String, dynamic>.from(payload);
    }).toList();

    // Upload to backend
    final response = await authService.synchronize(records);

    // Backend should return:
    // {
    //   "synced": [1,2,3],
    //   "failed": [...],
    //   "message": "Synchronization complete"
    // }

    final List synced = response["synced"] ?? [];
    final List failed = response["failed"] ?? [];

    // Remove successfully synchronized records
    for (final id in synced) {
      await db.removePendingSync(id);
    }

    return {
      "synced": synced.length,
      "failed": failed.length,
      "message": response["message"] ?? "Synchronization complete.",
    };
  }
}
