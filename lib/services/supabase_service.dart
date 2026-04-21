// ═══════════════════════════════════════════════════════════════════
// lib/services/supabase_service.dart
// This file talks to the Supabase cloud database.
// It saves driving logs and fetches them back.
// Think of it as the "phone call" to our cloud storage.
// ═══════════════════════════════════════════════════════════════════

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/driving_log.dart';

class SupabaseService {

  // Get the Supabase connection (set up in main.dart)
  // We use this to talk to the database
  static final _db = Supabase.instance.client;

  // ── Who is logged in right now? ──────────────────────────────────
  // Returns the user's ID, or null if nobody is logged in
  static String? get userId => _db.auth.currentUser?.id;

  // ── Is anyone logged in? ─────────────────────────────────────────
  static bool get isLoggedIn => _db.auth.currentUser != null;

  // ════════════════════════════════════════════════════════════════
  // SAVE a driving log to Supabase
  // Called every time the app detects a status change
  // ════════════════════════════════════════════════════════════════
  static Future<void> saveLog(DrivingLog log) async {
    // Safety check — don't save if nobody is logged in
    if (!isLoggedIn) {
      print('Cannot save: no user logged in');
      return;
    }

    try {
      // Insert one row into the driving_logs table
      // This is like filling out a form and clicking "submit"
      await _db.from('driving_logs').insert({
        'user_id':      userId,
        'status':       log.status == DrivingStatus.driving
                        ? 'DRIVING'
                        : 'NOT_DRIVING',
        'motion_level': log.motionLevel,
        'noise_level':  log.noiseLevel,
        'duration_min': log.durationMinutes,
      });

      print('✅ Log saved to Supabase');

    } catch (error) {
      // If saving fails, print the error but don't crash the app
      print('❌ Could not save log: $error');
    }
  }

  // ════════════════════════════════════════════════════════════════
  // FETCH all driving logs for the current user
  // Called when the History screen opens
  // ════════════════════════════════════════════════════════════════
  static Future<List<DrivingLog>> fetchLogs() async {
    // If nobody is logged in, return empty list
    if (!isLoggedIn) return [];

    try {
      // Ask Supabase for all rows in driving_logs
      // where user_id = the current user's ID
      // ordered by newest first
      final data = await _db
          .from('driving_logs')
          .select()                              // get all columns
          .eq('user_id', userId!)               // only THIS user's logs
          .order('created_at', ascending: false) // newest first
          .limit(50);                            // max 50 at a time

      // Convert each row from the database into a DrivingLog object
      // "map" means: for each row, do this conversion
      return (data as List)
          .map((row) => _convertRowToLog(row))
          .toList();

    } catch (error) {
      print('❌ Could not fetch logs: $error');
      return []; // return empty list if something goes wrong
    }
  }

  // ════════════════════════════════════════════════════════════════
  // DELETE one log by its ID
  // ════════════════════════════════════════════════════════════════
  static Future<void> deleteLog(String logId) async {
    if (!isLoggedIn) return;

    try {
      await _db
          .from('driving_logs')
          .delete()
          .eq('id', logId)
          .eq('user_id', userId!); // safety: only delete own logs

      print('✅ Log deleted');
    } catch (error) {
      print('❌ Could not delete log: $error');
    }
  }

  // ════════════════════════════════════════════════════════════════
  // HELPER: Convert a database row into a DrivingLog object
  // A "row" from Supabase looks like a dictionary:
  // { 'id': '...', 'status': 'DRIVING', 'motion_level': 2.4, ... }
  // We convert it into a proper DrivingLog Dart object
  // ════════════════════════════════════════════════════════════════
  static DrivingLog _convertRowToLog(Map<String, dynamic> row) {
    return DrivingLog(
      id:              row['id'].toString(),
      timestamp:       DateTime.parse(row['created_at']),
      status:          row['status'] == 'DRIVING'
                       ? DrivingStatus.driving
                       : DrivingStatus.notDriving,
      motionLevel:     (row['motion_level'] as num).toDouble(),
      noiseLevel:      (row['noise_level'] as num).toDouble(),
      durationMinutes: row['duration_min'] ?? 0,
    );
  }

  // ════════════════════════════════════════════════════════════════
  // SAVE language preference to Supabase
  // So next time user logs in, their language is remembered
  // ════════════════════════════════════════════════════════════════
  static Future<void> saveLanguage(String langCode) async {
    if (!isLoggedIn) return;

    try {
      await _db
          .from('app_settings')
          .update({'language': langCode})
          .eq('user_id', userId!);

      print('✅ Language saved: $langCode');
    } catch (error) {
      print('❌ Could not save language: $error');
    }
  }
}