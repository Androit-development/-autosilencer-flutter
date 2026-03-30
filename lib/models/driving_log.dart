// ═══════════════════════════════════════════════════════════════════════════
// Module 7: models/driving_log.dart
// Data class representing one driving session record.
// ═══════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import '../app_theme.dart';

enum DrivingStatus { driving, notDriving, sessionEnded, shortTrip }

class DrivingLog {
  final String id;
  final DateTime timestamp;
  final DrivingStatus status;
  final double motionLevel;
  final double noiseLevel;
  final int durationMinutes;

  const DrivingLog({
    required this.id,
    required this.timestamp,
    required this.status,
    required this.motionLevel,
    required this.noiseLevel,
    required this.durationMinutes,
  });

  // Bilingual label
  String label(bool isEnglish) {
    switch (status) {
      case DrivingStatus.driving:      return isEnglish ? 'Driving detected'    : 'Conduite détectée';
      case DrivingStatus.notDriving:   return isEnglish ? 'Monitoring active'   : 'Surveillance active';
      case DrivingStatus.sessionEnded: return isEnglish ? 'Session ended'       : 'Fin de session';
      case DrivingStatus.shortTrip:    return isEnglish ? 'Short trip'          : 'Trajet court';
    }
  }

  // Status color
  Color get color {
    switch (status) {
      case DrivingStatus.driving:      return AppColors.error;
      case DrivingStatus.notDriving:   return AppColors.tertiary;
      case DrivingStatus.sessionEnded: return AppColors.outline;
      case DrivingStatus.shortTrip:    return AppColors.primary;
    }
  }

  // Progress bar fill ratio (0.0 to 1.0)
  double get progressFill {
    switch (status) {
      case DrivingStatus.driving:      return 0.72;
      case DrivingStatus.notDriving:   return 0.42;
      case DrivingStatus.sessionEnded: return 0.90;
      case DrivingStatus.shortTrip:    return 0.22;
    }
  }

  // Formatted date — bilingual
  String formattedDate(bool isEnglish) {
    const monthsFr = ['jan','fév','mars','avr','mai','juin','juil','août','sep','oct','nov','déc'];
    const monthsEn = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final months = isEnglish ? monthsEn : monthsFr;
    final h  = timestamp.hour;
    final m  = timestamp.minute.toString().padLeft(2,'0');
    final pm = h >= 12 ? 'PM' : 'AM';
    final h12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '${timestamp.day} ${months[timestamp.month-1]} • '
           '${h12.toString().padLeft(2,"0")}:$m $pm';
  }
}