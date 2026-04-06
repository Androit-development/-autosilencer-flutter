<div align="center">

<img width="100%" src="https://capsule-render.vercel.app/api?type=waving&color=0:060E1E,50:1a3a6e,100:2979FF&height=220&section=header&text=AutoSilencer&fontSize=80&fontColor=ffffff&fontAlignY=38&desc=Drive%20Focused.%20Stay%20Safe.&descAlignY=58&descSize=24&descColor=B0C6FF&animation=fadeIn"/>

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.io)
[![Android](https://img.shields.io/badge/Android-API%2027+-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://developer.android.com)
[![Sprint](https://img.shields.io/badge/Sprint%201-Complete-00E676?style=for-the-badge)]()

<br/>

> ### *"Every year, thousands of people die because of a phone notification while driving.*
> ### *We built the app that prevents it — automatically."*

<br/>

</div>

---

## 📖 Table of Contents

- [The Problem](#-the-problem--a-crisis-hiding-in-plain-sight)
- [The Solution](#-the-solution--autosilencer)
- [What Makes It Innovative](#-what-makes-it-innovative)
- [System Architecture](#-system-architecture)
- [Data Flow](#-data-flow--from-sensor-to-silence)
- [Project Structure](#-project-structure)
- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Database Schema](#-database-schema)
- [Sprint Plan](#-agile-sprint-plan)
- [Getting Started](#-getting-started)
- [Team](#-team--collaboration)

---

## 🌍 The Problem — A Crisis Hiding in Plain Sight

<table>
<tr>
<td width="55%">

Every single day, drivers across the world — including right here in **Yaoundé, Cameroon** — pick up their phones while behind the wheel. A buzzing notification. An incoming call. A WhatsApp message. A MTN MoMo alert.

**Just one glance. That glance kills.**

The frustrating truth? The solution is elementary: **silence your phone before you drive**. But humans forget. We're busy. We're running late. We tell ourselves *"just this once."*

Existing solutions require you to:
- ❌ Manually enable Do Not Disturb
- ❌ Remember to turn it off afterward
- ❌ Use GPS (drains battery + privacy risk)
- ❌ Subscribe to a paid service

**There is no app that does this silently, automatically, with zero user interaction — until now.**

</td>
<td width="45%" align="center">

```
 Road Accident Causes (WHO 2023)
 ────────────────────────────────
  Speeding      ████████░░  38%
  Alcohol       ██████░░░░  29%
  Distraction   █████░░░░░  25% ← 📱
  Other         ██░░░░░░░░   8%
 ────────────────────────────────

 Distraction breakdown:
  Phone calls   ████████░░  41%
  Texting       ██████░░░░  32%
  Notifications █████░░░░░  27%
 ────────────────────────────────
  Source: WHO Global Road Safety
```

</td>
</tr>
</table>

---

## 💡 The Solution — AutoSilencer

<div align="center">

```
┌──────────────────────────────────────────────────────────────────────┐
│                                                                       │
│   1. You start your car.          → AutoSilencer detects motion      │
│   2. Engine noise rises.          → AutoSilencer detects ambient dB  │
│   3. Both thresholds exceeded.    → Decision: YOU ARE DRIVING        │
│   4. Phone goes silent.           → Zero taps. Zero thought.         │
│   5. You arrive safely.           → Volume automatically restored    │
│   6. Session saved to cloud.      → Your journey is recorded         │
│                                                                       │
│              Zero taps. Zero setup. Zero distraction.                │
│                                                                       │
└──────────────────────────────────────────────────────────────────────┘
```

</div>

**AutoSilencer** is a native Android application built with Flutter that uses the phone's **accelerometer** and **microphone** — no GPS, no internet required for core detection — to automatically determine when you are driving and silence your phone instantly. When your journey ends, it restores your volume. Every session is logged to a Supabase cloud database so you can track your safe driving history.

---

## 🚀 What Makes It Innovative

<table>
<tr>
<td align="center" width="33%">

### 📡 Dual-Sensor Intelligence

Most solutions rely on GPS alone. We combine **accelerometer motion analysis** with **ambient noise measurement** — a two-factor detection system that is both more accurate and far more battery-efficient. No satellite lock needed.

</td>
<td align="center" width="33%">

### 🔒 Privacy by Design

We **never record audio**. The microphone measures only the ambient noise *level* — a single decimal number in decibels. No audio file is ever created, stored, or transmitted. Your conversations stay private, always.

</td>
<td align="center" width="33%">

### 🇨🇲 Local Context First

Built for the Cameroonian driver. Fully bilingual in **English and French** with a single tap. Designed to silence MTN MoMo, Orange Money, and WhatsApp — the exact notifications that distract us most on Cameroonian roads.

</td>
</tr>
</table>

---

## 🏛️ System Architecture

### MVVM — The Three Layers

```
╔═══════════════════════════════════════════════════════════════════════════╗
║                         AUTOSILENCER APP                                  ║
║                  MVVM (Model — View — ViewModel)                          ║
╠═══════════════════════════════════════════════════════════════════════════╣
║                                                                            ║
║  ╔═══════════════════════════════════════════════════════════════════╗    ║
║  ║                        VIEW  LAYER                                ║    ║
║  ║              "What the user sees and touches"                     ║    ║
║  ║                                                                   ║    ║
║  ║  ┌────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────┐  ║    ║
║  ║  │   Splash   │  │    Home     │  │   History   │  │Settings │  ║    ║
║  ║  │  Module 1  │  │  Module 2   │  │  Module 3   │  │Module 4 │  ║    ║
║  ║  │            │  │             │  │             │  │         │  ║    ║
║  ║  │ Particles  │  │ Status Rings│  │Session Cards│  │ EN / FR │  ║    ║
║  ║  │ Shield logo│  │ Sensor stats│  │Filter chips │  │Switcher │  ║    ║
║  ║  │ CTA button │  │ Start/Stop  │  │Summary pills│  │         │  ║    ║
║  ║  └─────┬──────┘  └──────┬──────┘  └──────┬──────┘  └────┬────┘  ║    ║
║  ╚════════╪═══════════════╪════════════════╪═══════════════╪════════╝    ║
║           │    observes & reacts to ViewModel state        │              ║
║  ╔════════▼═══════════════▼════════════════▼═══════════════▼════════╗    ║
║  ║                     VIEWMODEL  LAYER                              ║    ║
║  ║            "The brain — bridges UI and data"                     ║    ║
║  ║                                                                   ║    ║
║  ║  ┌───────────────────────────────────┐  ┌─────────────────────┐  ║    ║
║  ║  │        DrivingViewModel           │  │   LanguageViewModel  │  ║    ║
║  ║  │            Module 5               │  │       Module 6       │  ║    ║
║  ║  │                                   │  │                      │  ║    ║
║  ║  │  State:                           │  │  locale: Locale      │  ║    ║
║  ║  │    isMonitoring: bool             │  │  isEnglish: bool     │  ║    ║
║  ║  │    isDriving: bool                │  │  toggle() method     │  ║    ║
║  ║  │    motionLevel: double            │  │                      │  ║    ║
║  ║  │    noiseLevel: double             │  │  → Rebuilds entire   │  ║    ║
║  ║  │    logs: List<DrivingLog>         │  │    app on change     │  ║    ║
║  ║  │                                   │  └─────────────────────┘  ║    ║
║  ║  │  Actions:                         │                            ║    ║
║  ║  │    startMonitoring()              │                            ║    ║
║  ║  │    stopMonitoring()               │                            ║    ║
║  ║  │    updateSensorData(motion, noise)│                            ║    ║
║  ║  └─────────────────┬─────────────────┘                            ║    ║
║  ╚═══════════════════╪══════════════════════════════════════════════╝    ║
║                       │  reads from / writes to                           ║
║  ╔════════════════════▼══════════════════════════════════════════════╗    ║
║  ║                      MODEL  LAYER                                 ║    ║
║  ║                "Data sources and business logic"                  ║    ║
║  ║                                                                   ║    ║
║  ║  ┌──────────────┐  ┌──────────────────┐  ┌──────────────────┐   ║    ║
║  ║  │SensorManager │  │ DrivingDetector  │  │ SupabaseService  │   ║    ║
║  ║  │   Module 9   │  │    Module 8      │  │    Module 10     │   ║    ║
║  ║  │              │  │                  │  │                  │   ║    ║
║  ║  │Accelerometer │  │ magnitude =      │  │ INSERT log row   │   ║    ║
║  ║  │stream (1/sec)│  │  √(x²+y²+z²)    │  │ SELECT history   │   ║    ║
║  ║  │              │  │                  │  │ Real-time sync   │   ║    ║
║  ║  │Microphone dB │  │ IF motion > 1.5  │  │                  │   ║    ║
║  ║  │stream (1/sec)│  │ AND noise > 60dB │  └────────┬─────────┘   ║    ║
║  ║  └──────┬───────┘  │ → DRIVING ✅     │           │             ║    ║
║  ║         │          └────────┬─────────┘           │             ║    ║
║  ╚═════════╪═══════════════════╪═════════════════════╪═════════════╝    ║
╚════════════╪═══════════════════╪═════════════════════╪══════════════════╝
             │                   │                     │
   ┌──────────▼────────┐  ┌──────▼──────────┐  ┌──────▼──────────────┐
   │  📱 Phone Hardware │  │ 🔇 Android DND  │  │  ☁️ Supabase Cloud  │
   │  Accelerometer     │  │  Silent Mode    │  │  PostgreSQL Database │
   │  Microphone        │  │  Volume Control │  │  REST API           │
   └────────────────────┘  └─────────────────┘  └─────────────────────┘
```

---

## 🌊 Data Flow — From Sensor to Silence

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         DETECTION PIPELINE                               │
└─────────────────────────────────────────────────────────────────────────┘

  [USER ENTERS CAR]
         │
         ▼
  ┌──────────────────────┐    every 1 second
  │   SensorManager      │ ──────────────────────────────────────────────┐
  │                      │                                                │
  │  Accelerometer  ───→ │  x: 0.12, y: 9.81, z: 2.30  (raw m/s²)      │
  │  Microphone     ───→ │  noise: 68.4 dB                               │
  └──────────────────────┘                                                │
                                                                          │
         ┌────────────────────────────────────────────────────────────────┘
         │
         ▼
  ┌──────────────────────────────────────────────────────────────────────┐
  │                      DrivingDetector Algorithm                        │
  │                                                                        │
  │   Step 1:  magnitude  = √(0.12² + 9.81² + 2.30²)  =  10.07 m/s²    │
  │   Step 2:  netMotion  = |10.07 - 9.8|              =   0.27 m/s²    │
  │                          (subtract gravity)                            │
  │                                                                        │
  │   Step 3:  netMotion (0.27) > threshold (1.5)?      → NO             │
  │            noiseLevel (68.4) > threshold (60.0)?    → YES            │
  │                                                                        │
  │            BOTH must be true → Result: NOT DRIVING 🟢                │
  │            (prevents false positive from bumpy road or loud room)     │
  └──────────────────────────────────────────────────────────────────────┘
         │
         ▼
  ┌──────────────────────┐
  │   Status Changed?    │
  └────┬─────────────────┘
      YES ──────────────────────────────────────────────────────────────┐
       │                                                                  │
       ▼                                                                  ▼
  [DRIVING → Silent ON]                                      [STOPPED → Volume ON]
       │                                                                  │
       └──────────────────────┬───────────────────────────────────────────┘
                              │
                              ▼
                   ┌──────────────────────────────┐
                   │     Log saved to Supabase     │
                   │  {                            │
                   │    status: "DRIVING",         │
                   │    timestamp: now(),          │
                   │    motion: 2.4,               │
                   │    noise: 68.4                │
                   │  }                            │
                   └──────────────────────────────┘
                              │
                              ▼
                   ┌──────────────────────────────┐
                   │  UI rebuilds via Provider     │
                   │  → Red rings animate          │
                   │  → Alert banner appears       │
                   │  → Stats update live          │
                   └──────────────────────────────┘
```

---

## 📁 Project Structure

```
driving_auto_silencer/
│
├── 📄 main.dart                     ← App entry + routes + MultiProvider
├── 🎨 app_theme.dart                ← "Sentinel Glow" design tokens
│
├── 📱 lib/views/                    ── VIEW LAYER ──
│   ├── splash_screen.dart           Module 1: Particle field + shield logo
│   ├── home_screen.dart             Module 2: Animated rings + sensor data
│   ├── history_screen.dart          Module 3: Session cards + filter chips
│   └── settings_screen.dart         Module 4: EN🇬🇧 / FR🇫🇷 language switcher
│
├── 🧠 lib/viewmodels/               ── VIEWMODEL LAYER ──
│   ├── driving_viewmodel.dart       Module 5: Core state (ChangeNotifier)
│   └── language_viewmodel.dart      Module 6: Bilingual locale switching
│
├── 📦 lib/models/                   ── DATA MODELS ──
│   └── driving_log.dart             Module 7: DrivingLog data class
│
├── ⚙️  lib/logic/                   ── BUSINESS LOGIC ──
│   └── driving_detector.dart        Module 8: Detection algorithm
│
├── 🔌 lib/services/                 ── EXTERNAL SERVICES ──
│   ├── sensor_manager.dart          Module 9: Hardware sensor streams
│   └── supabase_service.dart        Module 10: Cloud DB operations
│
└── 🧪 test/                         ── TESTING (Sprint 3) ──
    ├── driving_detector_test.dart
    └── sensor_manager_test.dart
```

---

## ✨ Features

| Feature | Description | Sprint | Status |
|---|---|:---:|:---:|
| 🚗 Driving detection | Dual-sensor algorithm (motion + noise) | 1 | ✅ Done |
| 🔇 Auto silent mode | Instant silence when driving detected | 1 | ✅ Done |
| 🔔 Auto volume restore | Volume returns when driving stops | 1 | ✅ Done |
| 📊 Live sensor stats | Real-time motion (m/s²) + noise (dB) | 1 | ✅ Done |
| ▶️ Manual control | One-tap Start / Stop monitoring | 1 | ✅ Done |
| 🌍 Bilingual EN/FR | Full English + French with one tap | 1 | ✅ Done |
| 🎨 Sentinel Glow UI | Animated rings, particles, glass cards | 1 | ✅ Done |
| ☁️ Supabase logging | Session events saved to cloud | 2 | 🔄 In Progress |
| 📜 Session history | View and filter all past sessions | 2 | 🔄 In Progress |
| 🧪 Unit tests | Automated tests for all logic | 3 | 🔜 Upcoming |
| 📦 APK release | Installable on any Android 8+ device | 3 | 🔜 Upcoming |

---

## 🛠️ Tech Stack

```
┌─────────────────────────────────────────────────────────┐
│                      TECH STACK                          │
├──────────────────────┬──────────────────────────────────┤
│ Frontend Framework   │ Flutter 3.x (Dart)               │
│ Architecture         │ MVVM + Provider                  │
│ Design System        │ "The Sentinel Glow" (custom)     │
│ Typography           │ Space Grotesk + Manrope           │
│ Motion Sensor        │ sensors_plus ^6.1.1              │
│ Noise Detection      │ noise_meter ^5.0.2               │
│ Cloud Backend        │ Supabase (PostgreSQL)            │
│ Permissions          │ permission_handler ^11.3.1       │
│ State Management     │ provider ^6.1.5                  │
│ Localization         │ flutter_localizations            │
│ Target Platform      │ Android API 27+ (Android 8.0+)  │
│ IDE                  │ VS Code + Android Studio         │
│ Version Control      │ Git + GitHub (Organisation)      │
└──────────────────────┴──────────────────────────────────┘
```

---

## 🗄️ Database Schema

```sql
-- Supabase Cloud — PostgreSQL
-- Table: driving_logs

CREATE TABLE driving_logs (
  id            UUID         DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at    TIMESTAMPTZ  DEFAULT now() NOT NULL,
  status        TEXT         NOT NULL,        -- 'DRIVING' | 'NOT_DRIVING'
  motion_level  FLOAT        NOT NULL,        -- m/s² from accelerometer
  noise_level   FLOAT        NOT NULL,        -- dB from microphone
  duration_min  INTEGER      DEFAULT 0        -- session length in minutes
);

-- Sample data (matches what you see in the History screen)
INSERT INTO driving_logs VALUES
  ('1', '2026-03-18 08:30', 'DRIVING',     2.4, 68.0, 24),
  ('2', '2026-03-18 07:15', 'NOT_DRIVING', 0.3, 42.0, 12),
  ('3', '2026-03-17 18:45', 'NOT_DRIVING', 0.1, 35.0, 45),
  ('4', '2026-03-17 09:12', 'DRIVING',     1.8, 62.0,  8);
```

---

## 🏃 Agile Sprint Plan

```
╔════════════════════════════════════════════════════════════════╗
║  SPRINT 1 — "Make It Work"                      ✅ COMPLETE   ║
╠════════════════════════════════════════════════════════════════╣
║  ✅ Flutter project + MVVM architecture                        ║
║  ✅ "Sentinel Glow" design system                              ║
║  ✅ Splash screen (particle field + shield logo)               ║
║  ✅ Home screen (safe state — green animated rings)            ║
║  ✅ Home screen (driving state — red alert + pulse)            ║
║  ✅ History screen (session cards + filters + pills)           ║
║  ✅ Settings screen (EN/FR language switcher)                  ║
║  ✅ DrivingViewModel with full state management                ║
║  ✅ Bilingual support (English + French)                       ║
╚════════════════════════════════════════════════════════════════╝

╔════════════════════════════════════════════════════════════════╗
║  SPRINT 2 — "Make It Remember"               🔄 IN PROGRESS   ║
╠════════════════════════════════════════════════════════════════╣
║  ⬜ Supabase project + driving_logs table                      ║
║  ⬜ Flutter ↔ Supabase live connection                         ║
║  ⬜ Auto-save session on status change                         ║
║  ⬜ History screen pulls from real database                    ║
╚════════════════════════════════════════════════════════════════╝

╔════════════════════════════════════════════════════════════════╗
║  SPRINT 3 — "Make It Professional"              🔜 UPCOMING   ║
╠════════════════════════════════════════════════════════════════╣
║  ⬜ Unit tests — DrivingDetector (100% coverage target)        ║
║  ⬜ Unit tests — SensorManager                                 ║
║  ⬜ Full project documentation                                 ║
║  ⬜ APK build + install on physical device                     ║
╚════════════════════════════════════════════════════════════════╝
```

---

## 🚀 Getting Started

### Prerequisites

```bash
flutter doctor    # must show ✅ Flutter + ✅ Android toolchain
```

| Tool | Version |
|---|---|
| Flutter | ≥ 3.0.0 |
| Dart | ≥ 3.0.0 |
| Android | API 27+ (Android 8.0) |

### Installation

```bash
# Clone
git clone https://github.com/androit-development/autosilencer-flutter.git
cd autosilencer-flutter

# Install dependencies
flutter pub get

# Run on emulator or connected device
flutter run
```

### Build Release APK *(Sprint 3)*

```bash
flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk
```

---

## 🤝 Team & Collaboration

<table>
<tr>
<td align="center" width="50%">

### 🧑‍💻 Erwan — KFJerwan
**Flutter / Dart Developer**

[![GitHub](https://img.shields.io/badge/GitHub-KFJerwan-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/KFJerwan)

Responsible for:
- Flutter MVVM architecture
- UI screens + animations
- Sensor integration (Sprint 1)
- Supabase backend (Sprint 2)
- Unit tests (Sprint 3)

</td>
<td align="center" width="50%">

### 🧑‍💻 Teammate
**Kotlin Developer**

[![GitHub](https://img.shields.io/badge/GitHub-Teammate-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/androit-development)

Responsible for:
- Kotlin + Jetpack Compose version
- Android-native sensors
- Room database
- Kotlin coroutines & Flow
- Kotlin unit tests

</td>
</tr>
</table>

### Git Workflow

```
main          ←── protected: stable reviewed code only
  │
  ├── start            ← initial setup + first screens  [current]
  ├── feat/sensors     ← Sprint 1: sensor integration
  ├── feat/backend     ← Sprint 2: Supabase connection
  └── feat/tests       ← Sprint 3: unit tests

Commit convention:
  feat:  new feature
  fix:   bug fix
  docs:  documentation update
  test:  test files
  style: UI/design changes

Pull Request rule:
  Every branch → PR → teammate reviews → merge to main
```



<div align="center">

**SE 3242 — Android Application Development**

**ICT University, Yaoundé, Cameroon 🇨🇲**



<br/>

*Built with ❤️  — because every safe arrival matters.*

<img width="100%" src="https://capsule-render.vercel.app/api?type=waving&color=0:2979FF,50:1a3a6e,100:060E1E&height=120&section=footer"/>
