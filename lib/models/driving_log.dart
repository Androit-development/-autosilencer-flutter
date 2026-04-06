// ═══════════════════════════════════════════════════════════════════
// lib/models/driving_log.dart
// This file describes what ONE driving session looks like.
// Think of it as a blueprint — like a form with fields to fill.
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

// DrivingStatus = the possible states of a session
enum DrivingStatus {
  driving,       // phone was silenced — user was driving
  notDriving,    // monitoring was on but user was not driving
  sessionEnded,  // session was manually stopped
  shortTrip,     // a very short trip was detected
}

// DrivingLog = one complete session record
// This matches exactly the columns in our Supabase driving_logs table
class DrivingLog {
  final String id;               // unique ID for this session
  final DateTime timestamp;      // when it happened
  final DrivingStatus status;    // was the user driving?
  final double motionLevel;      // how much the phone moved (m/s²)
  final double noiseLevel;       // how loud the environment was (dB)
  final int durationMinutes;     // how long the session lasted

  const DrivingLog({
    required this.id,
    required this.timestamp,
    required this.status,
    required this.motionLevel,
    required this.noiseLevel,
    required this.durationMinutes,
  });

  // ── Label shown in the History screen ───────────────────────────
  // Returns the right text depending on the language (EN or FR)
  String label(bool isEnglish) {
    switch (status) {
      case DrivingStatus.driving:
        return isEnglish ? 'Driving detected' : 'Conduite détectée';
      case DrivingStatus.notDriving:
        return isEnglish ? 'Monitoring active' : 'Surveillance active';
      case DrivingStatus.sessionEnded:
        return isEnglish ? 'Session ended' : 'Fin de session';
      case DrivingStatus.shortTrip:
        return isEnglish ? 'Short trip' : 'Trajet court';
    }
  }

  // ── Color for each status ────────────────────────────────────────
  // Returns a color code (integer) that Flutter uses
  int get colorValue {
    switch (status) {
      case DrivingStatus.driving:      return 0xFFFFB4AB; // red
      case DrivingStatus.notDriving:   return 0xFF00E475; // green
      case DrivingStatus.sessionEnded: return 0xFF8C90A0; // grey
      case DrivingStatus.shortTrip:    return 0xFFB0C6FF; // blue
    }
  }

  // ── Color as Flutter Color object ────────────────────────────────
  Color get color => Color(colorValue);

  // ── Progress bar fill (how full the bar appears) ─────────────────
  double get progressFill {
    switch (status) {
      case DrivingStatus.driving:      return 0.72;
      case DrivingStatus.notDriving:   return 0.42;
      case DrivingStatus.sessionEnded: return 0.90;
      case DrivingStatus.shortTrip:    return 0.22;
    }
  }

  // ── Date shown in cards ──────────────────────────────────────────
  // Example output: "18 mars 2026 • 08:30 AM"
  String formattedDate(bool isEnglish) {
    const monthsFr = [
      'jan','fév','mars','avr','mai','juin',
      'juil','août','sep','oct','nov','déc'
    ];
    const monthsEn = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    final months = isEnglish ? monthsEn : monthsFr;
    final h  = timestamp.hour;
    final m  = timestamp.minute.toString().padLeft(2, '0');
    final pm = h >= 12 ? 'PM' : 'AM';
    final h12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '${timestamp.day} ${months[timestamp.month - 1]} '
           '${timestamp.year} • '
           '${h12.toString().padLeft(2, "0")}:$m $pm';
  }
}