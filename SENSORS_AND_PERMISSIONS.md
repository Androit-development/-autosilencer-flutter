# 🎤 Microphone & Sensors Configuration Guide

## ✅ What Has Been Improved

### 1. **iOS Permissions** 
- ✅ Added `NSMicrophoneUsageDescription` to Info.plist
- ✅ Added `NSMotionUsageDescription` to Info.plist
- Users will see permission prompts when app starts

### 2. **Android Permissions**
- ✅ Already declared in AndroidManifest.xml:
  - `RECORD_AUDIO` - For microphone access
  - `ACCESS_NOTIFICATION_POLICY` - To silence phone
  - `MODIFY_AUDIO_SETTINGS` - To control volume
  - `FOREGROUND_SERVICE_MICROPHONE` - Background service with microphone

### 3. **Permission Handling**
- ✅ Created `PermissionsService` for centralized permission management
- ✅ Permissions requested at app startup (splash screen)
- ✅ Permission check before starting monitoring
- ✅ User-friendly dialog if permissions are denied

### 4. **Sensor Sensitivity**
- ✅ Increased accelerometer sampling from 500ms → **250ms** (4x per second)
- ✅ Continuous microphone sampling
- ✅ Combined motion + noise detection for accuracy
- ✅ Created sensor optimization guide

---

## 🎯 Current Sensor Configuration

### **Accelerometer (Motion Detection)**
- **Sampling Rate**: 250ms (4 times per second)
- **Threshold**: 1.5 m/s² 
- **Measures**: Vehicle acceleration, road vibrations, movement patterns

### **Microphone (Noise Detection)**
- **Sampling Rate**: Continuous
- **Threshold**: 60.0 dB
- **Measures**: Ambient sound level, engine noise, traffic sounds
- **Requires**: `NSMicrophoneUsageDescription` (iOS), `RECORD_AUDIO` (Android)

### **Sensor Fusion Logic**
```
isDriving = (Motion > 1.5 m/s²) AND (Noise > 60 dB)
```
Using **both sensors together** prevents false positives from:
- Bumpy roads (motion only)
- Loud restaurants (noise only)
- Stationary traffic

---

## 📱 How Permissions Work

### **On App Start**
1. User launches app
2. Splash screen shows 1.5 seconds
3. `PermissionsService.requestAllPermissions()` is called
4. User sees OS-level permission dialogs:
   - **iOS**: Native popup for microphone & motion
   - **Android**: Native popup for microphone & notification policy
5. User grants or denies permissions
6. App continues to home screen

### **Before Starting Monitoring**
1. User taps "START MONITORING" button
2. App checks permission status with `PermissionsService.checkAllPermissions()`
3. If any permission is missing:
   - Shows dialog with status of each permission
   - User can tap "Request Permissions" to try again
   - Or go to Settings to enable manually
4. If all permissions granted:
   - Monitoring starts
   - Sensors begin reading

---

## 🔧 Sensor Sensitivity Tuning

### **Make Sensors MORE Sensitive**
```dart
// In lib/constants/app_constants.dart
static const double motionThreshold = 1.0;  // Was 1.5 (lower = more sensitive)
static const double noiseThreshold = 55.0;   // Was 60.0 (lower = more sensitive)
```

**Pros:**
- Detects slow/steady driving
- Detects highways with low noise
- Works in quiet environments

**Cons:**
- More false positives
- May trigger on bumpy roads
- Battery drain increases

---

### **Make Sensors LESS Sensitive (More Stable)**
```dart
static const double motionThreshold = 2.0;   // Higher = less sensitive
static const double noiseThreshold = 65.0;   // Higher = less sensitive  
```

**Pros:**
- Fewer false positives
- Better battery life
- Works in noisy environments

**Cons:**
- Misses slow/steady driving
- Requires More obvious motion

---

## 📊 Sensor Reading Examples

### **Typical Readings**
| Scenario | Motion (m/s²) | Noise (dB) | Status |
|----------|--------------|-----------|--------|
| Sitting at home | 0-0.2 | 40-50 | ❌ NOT DRIVING |
| Walking around | 0.5-1.2 | 50-60 | ❌ NOT DRIVING |
| Stopped in traffic | 0.3-0.8 | 65-75 | ❌ NOT DRIVING (noise, no motion) |
| **City driving** | **1.8-3.5** | **65-80** | **✅ DRIVING** |
| **Highway driving** | **1.5-2.2** | **60-70** | **✅ DRIVING** |
| **Aggressive acceleration** | **3.0+** | **70-85** | **✅ DRIVING** |
| Bumpy parking lot | 2.5-4.0 | 50-60 | ❌ NOT DRIVING (motion, no noise) |
| Loud restaurant | 0-0.5 | 75-85 | ❌ NOT DRIVING (noise, no motion) |

---

## 🚀 Advanced Optimization

### **Check Sensor Health (for Debugging)**
```dart
import 'package:driving_auto_silencer/utils/sensor_optimization.dart';

// Get diagnostics
print(SensorOptimization.getSensorDiagnostics(
  recentMotion: 1.8,
  recentNoise: 62.0,
  isDriving: true,
));
```

### **Different Profiles**
```dart
// lib/utils/sensor_optimization.dart already has these:
const sensitive = {'motion': 1.2, 'noise': 55.0};  // Sensitive
const balanced = {'motion': 1.5, 'noise': 60.0};   // Default (recommended)
const stable = {'motion': 2.0, 'noise': 65.0};     // Stable
```

---

## 📋 Files Modified/Created

### **Created:**
- ✅ `lib/services/permissions_service.dart` - Centralized permission management
- ✅ `lib/utils/sensor_optimization.dart` - Sensor tuning guide & diagnostics

### **Modified:**
- ✅ `ios/Runner/Info.plist` - Added microphone & motion descriptions
- ✅ `lib/views/splash_screen.dart` - Request permissions on startup
- ✅ `lib/views/home_screen.dart` - Check permissions before monitoring, show dialog
- ✅ `lib/viewmodels/driving_viewmodel.dart` - Improved sensor sampling (500ms → 250ms)
- ✅ `lib/services/background_service.dart` - Better sensor sampling with logging
- ✅ `lib/utils/index.dart` - Export new sensor optimization module

---

## 🎤 How to Test Permissions

### **iOS (Simulator)**
1. Go to Settings > Privacy > Microphone
2. Find "AutoSilencer" (or "Driving Auto Silencer")
3. Toggle microphone access
4. Restart app and watch permission prompts

### **iOS (Physical Device)**
1. Settings > Privacy > Microphone
2. Enable "Driving Auto Silencer"
3. Settings > Motion > Enable if present
4. Restart app

### **Android**
1. Settings > Apps > AutoSilencer > Permissions
2. Toggle Microphone & Sensors
3. Restart app
4. Watch for permission dialogs

---

## ⚠️ Important Notes

1. **Microphone Permission is Critical**
   - App works WITHOUT it, but only motion detection available
   - Reduces accuracy significantly
   - Show warning if microphone is denied

2. **Sensor Quality Varies by Device**
   - Flagship phones: Premium accelerometers (can use lower thresholds)
   - Budget phones: Can be noisier (may need higher thresholds)
   - Test on your target device

3. **Battery Impact**
   - Continuous microphone: ~2-5% per hour (Android)
   - Continuous microphone: ~1-3% per hour (iOS)
   - Accelerometer: ~0.5-1% per hour
   - Total: 3-6% per hour of active monitoring

4. **Background Service (Android)**
   - Uses foreground service (visible notification)
   - Requires `FOREGROUND_SERVICE` permission
   - Continues working even when app is closed
   - Already configured in AndroidManifest.xml

5. **Privacy**
   - Microphone data is only used for noise level (dB)
   - Raw audio is NOT recorded
   - Data stays on device (not sent to cloud unless using Supabase)
   - User can disable anytime in Settings

---

## 🐛 Troubleshooting

### **Sensors Not Working**
1. Check if permissions are granted in Settings
2. Look at debug logs: `flutter logs`
3. Verify sensor grants: `PermissionsService.checkAllPermissions()`
4. Try requesting permissions again

### **Too Many False Positives**
1. Increase sensor thresholds (make less sensitive)
2. Test on real driving conditions
3. Adjust both motion AND noise together
4. Check sensor readings in app

### **App Crashes on Permission Request**
1. Make sure iOS permissions are in Info.plist ✅ (done)
2. Make sure Android permissions in AndroidManifest.xml ✅ (done)
3. Use `permission_handler` package correctly ✅ (done)
4. Run `flutter clean && flutter pub get`

---

## 📞 Need Help?

Check these files for implementation details:
- `lib/services/permissions_service.dart` - Permission implementation
- `lib/utils/sensor_optimization.dart` - Sensor tuning guide
- `lib/constants/app_constants.dart` - Threshold values
- `ios/Runner/Info.plist` - iOS permissions
- `android/app/src/main/AndroidManifest.xml` - Android permissions
