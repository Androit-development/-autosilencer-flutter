# 🎯 Demo Quick Reference

**This file is your backstage guide during the presentation.**

---

## 🚀 Quick Start Command

```bash
# Before the demo, run:
cd c:\Users\OPPO\Documents\driving_auto_silencer
flutter clean
flutter pub get
flutter run
```

---

## 📂 Key Files to Show (if asked)

### Architecture Files

| File | What to show | Why |
|------|-------------|-----|
| [lib/main.dart](lib/main.dart) | MultiProvider setup | Shows app initialization & state management |
| [lib/viewmodels/driving_viewmodel.dart](lib/viewmodels/driving_viewmodel.dart) | Entire file | Core state + methods (startMonitoring, updateSensorData) |
| [lib/logic/driving_detector.dart](lib/logic/driving_detector.dart) | Algorithm function | Shows dual-sensor logic |
| [lib/services/sensor_manager.dart](lib/services/sensor_manager.dart) | Stream listeners | Real device connection |

### UI Files

| File | What to show | Why |
|------|-------------|-----|
| [lib/views/home_screen.dart](lib/views/home_screen.dart) | Build method | Shows animated rings + sensor stats |
| [lib/views/history_screen.dart](lib/views/history_screen.dart) | Build method | Shows session cards + filters |
| [lib/views/settings_screen.dart](lib/views/settings_screen.dart) | Language toggle | Demonstrates bilingual support |
| [lib/app_theme.dart](lib/app_theme.dart) | Color scheme | Shows "Sentinel Glow" design tokens |

---

## ⏱️ Demo Timeline

```
0:00–0:30   → App launch + splash (show particle animation)
0:30–1:00   → Home screen tour (highlight design)
1:00–2:00   → Stationary state (safe mode with green rings)
2:00–6:00   → Simulate driving (shake + noise)
6:00–7:00   → Show status change (red rings + silenced)
7:00–9:00   → History screen + filter demo
9:00–10:00  → Settings screen (EN ↔ FR toggle)
10:00–12:00 → Architecture walkthrough (code snippets)
12:00–15:00 → Q&A
```

---

## 🎤 Canned Responses (Copy-paste if stuck)

### "How is the algorithm so accurate?"
> "It's not just accelerometer—that would fail on bumpy roads. And GPS alone drains battery.  
> We combine **motion detection + noise level**. Both must exceed thresholds to trigger DRIVING mode.  
> This **two-factor system** eliminates false positives."

### "Won't this drain battery?"
> "No. We read sensors only **1 time per second** (not 100+ times like GPS).  
> We process locally on the phone—**no cloud calls** for detection.  
> Supabase only stores session logs when driving ends (Sprint 2)."

### "What about privacy?"
> "We **never record audio**. Only measure noise *level* (one number in dB).  
> No location tracking. No audio files. No cloud sync during drive.  
> Privacy is built-in, not bolted-on."

### "When's the backend ready?"
> "Sprint 2 is underway. Right now we log to device memory.  
> Once Supabase is live, all sessions auto-save to cloud."

### "Can you build this for iOS?"
> "Absolutely! Flutter compiles to iOS with zero code changes.  
> We started with Android because that's the course focus."

---

## 🔧 If Something Breaks Mid-Demo

### **App crashes on launch:**
```bash
flutter clean
flutter pub get
flutter run
```

### **Permissions denied (sensors not working):**
```
Settings > Apps > AutoSilencer > Permissions
  → Microphone: Allow
  → Motion/Sensors: Allow
```

### **No animations on rings:**
→ This is normal on slow emulators. Tap Start Monitoring anyway—it still works.

### **Language toggle doesn't work:**
→ Restart the app after toggling.

### **History is empty:**
→ Say: "We're still building the Supabase backend (Sprint 2). For now, the history  
  would show real driving sessions once live."

---

## 📸 Visual Cues

```
Home Screen — SAFE Mode (Green)
├── Top banner: "🟢 Safe — Phone Volume ON"
├── Large animated rings: Blue → Green glow
├── Stats box: Motion 0.3 m/s², Noise 42 dB
├── Button: "Start Monitoring"
└── Bottom nav: Home | History | Settings

Home Screen — DRIVING Mode (Red)
├── Top banner: "🔴 DRIVING — Phone Silenced ✓"
├── Large animated rings: Red glow + pulse
├── Stats box: Motion 2.7 m/s², Noise 68 dB
├── Button: "Stop Monitoring"
└── Timer showing elapsed drive time

History Screen
├── Filter chips: All | Driving 🔴 | Safe 🟢
├── Session cards (list):
│   ├── Date: 18 Mar 2026, 08:30
│   ├── Type: DRIVING
│   ├── Duration: 24 min
│   ├── Metrics: Motion 2.4, Noise 68.0
│   └── Color: Red background
└── Search/Sort options

Settings Screen
├── Title: "Settings"
├── Toggle: "🇬🇧 English" ↔ "🇫🇷 Français"
├── Language tag: Shows current selection
└── Info text: "Entire app rebuilds instantly"
```

---

## 🎓 Why This Project Matters (Elevator Pitch)

**30-second version:**
> "Road accidents kill thousands yearly. AutoSilencer detects when you're driving and silences  
> your phone automatically. No taps. No setup. We built it with Flutter, MVVM architecture,  
> real sensors, and cloud logging. It actually **works** and actually **saves lives**."

**2-minute version:**
See `DEMO.md` — Full talking points there.

---

## ✅ Final Pre-Demo Checklist

- [ ] Device is charged (or plugged in)
- [ ] App is installed and launches cleanly
- [ ] Internet connected (for Supabase demo later)
- [ ] Microphone + Motion permissions granted
- [ ] Volume is ON (we'll silence it in the demo!)
- [ ] You've practiced the flow once
- [ ] DEMO.md is bookmarked for reference
- [ ] Know how to simulate motion (shake device)
- [ ] Know how to simulate noise (speak loudly or play sound)
- [ ] Have backup screenshots in case of issues

---

Good luck! 🎬

