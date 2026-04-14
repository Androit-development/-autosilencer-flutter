<div align="center">

<img width="100%" src="https://capsule-render.vercel.app/api?type=waving&color=0:060E1E,50:1a3a6e,100:2979FF&height=220&section=header&text=AutoSilencer&fontSize=80&fontColor=ffffff&fontAlignY=38&desc=Drive%20Focused.%20Stay%20Safe.&descAlignY=58&descSize=24&descColor=B0C6FF&animation=fadeIn"/>

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.io)
[![Android](https://img.shields.io/badge/Android-API%2027+-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://developer.android.com)
[![Driver Mode](https://img.shields.io/badge/Driver%20Mode-Yango%20Ready-FFB300?style=for-the-badge)]()

<br/>

> ### *"Every year, thousands of people die because of a phone notification while driving.*
> ### *We built the app that prevents it — automatically."*

<br/>

</div>

---

## 📖 Table of Contents

- [The Problem](#-the-problem)
- [The Solution](#-the-solution)
- [What Makes It Innovative](#-what-makes-it-innovative)
- [Real User Feedback](#-real-user-feedback--driver-mode-origin)
- [System Architecture](#-system-architecture)
- [Data Flow](#-data-flow)
- [Project Structure](#-project-structure)
- [Features](#-features)
- [Driver Mode](#-driver-mode--for-yango--professional-drivers)
- [Tech Stack](#-tech-stack)
- [Database Schema](#-database-schema)
- [Sprint Plan](#-agile-sprint-plan)
- [Getting Started](#-getting-started)
- [Team](#-team--collaboration)

---

## 🌍 The Problem

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

## 💡 The Solution

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

**AutoSilencer** is a native Android application built with Flutter that uses the phone's **accelerometer** and **microphone** — no GPS, no internet required for core detection — to automatically determine when you are driving and silence the phone instantly. When the journey ends, it restores the volume. Every session is logged to a Supabase cloud database.

---

## 🚀 What Makes It Innovative

<table>
<tr>
<td align="center" width="33%">

### 📡 Dual-Sensor Intelligence
Most solutions rely on GPS alone. We combine **accelerometer motion analysis** with **ambient noise measurement** — a two-factor detection system that is more accurate and far more battery-efficient. No satellite lock needed.

</td>
<td align="center" width="33%">

### 🔒 Privacy by Design
We **never record audio**. The microphone measures only the ambient noise *level* — a single decimal number in decibels. No audio file is ever created, stored, or transmitted. Your conversations stay private, always.

</td>
<td align="center" width="33%">

### 🇨🇲 Local Context First
Built for the Cameroonian driver. Fully bilingual in **English and French**. Designed to silence MTN MoMo, Orange Money, and WhatsApp — the exact notifications that distract us most on Cameroonian roads.

</td>
</tr>
<tr>
<td align="center" width="33%">

### 🚖 Driver Mode
Real Yango and inDrive drivers need their order notifications. **Driver Mode** whitelists specific apps so ride-hailing alerts still come through while everything else is silenced. Built from real user feedback.

</td>
<td align="center" width="33%">

### 🟢 Availability Status
Professional drivers can set their status to **Available**, **Busy**, or **Offline** — just like WhatsApp status — directly from the app. Inspired by real feedback from a Yango driver in Yaoundé.

</td>
<td align="center" width="33%">

### ☁️ Cloud History
Every driving session is automatically saved to **Supabase PostgreSQL**. Users can review their full driving history filtered by today, this week, or all time — with analytics showing total trips, time, and silences.

</td>
</tr>
</table>

---

## 💬 Real User Feedback — Driver Mode Origin

> *"Bon, tu pourrais mettre une fonction comme pour WhatsApp qui met occupé et disponible... Pour ceux qui font le Yango, ils ont besoin d'être actifs, ils ont besoin d'avoir leur téléphone. Yango, absolument le seul truc qui doit être allumé, qui doit être actif, donc le reste ne peut pas donner."*
>
> — **Real Yango driver, Yaoundé, Cameroon** — first external user test session

This direct feedback from a professional driver led to the development of **Driver Mode**, which allows Yango, inDrive, Uber Driver, and navigation apps to bypass silence so professional drivers never miss an order while AutoSilencer keeps them safe.

---

## 🏛️ System Architecture

### MVVM — The Four Layers

```
╔═════════════════════════════════════════════════════════════════════════╗
║                         AUTOSILENCER APP                                ║
║                  MVVM (Model — View — ViewModel)                        ║
╠═════════════════════════════════════════════════════════════════════════╣
║                                                                          ║
║  ╔═══════════════════════════════════════════════════════════════════╗  ║
║  ║                        VIEW  LAYER                                ║  ║
║  ║                 "What the user sees and touches"                  ║  ║
║  ║                                                                   ║  ║
║  ║  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌──────────┐  ║  ║
║  ║  │ Splash  │ │  Home   │ │ History │ │Settings │ │  Driver  │  ║  ║
║  ║  │Module 1 │ │Module 2 │ │Module 3 │ │Module 4 │ │   Mode   │  ║  ║
║  ║  │Particles│ │ Rings   │ │ Cards   │ │ EN/FR   │ │ Module 5 │  ║  ║
║  ║  │ Shield  │ │ Sensors │ │ Filter  │ │Sliders  │ │ Yango    │  ║  ║
║  ║  │   CTA   │ │ Start   │ │Analytics│ │  About  │ │ Status   │  ║  ║
║  ║  └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘ └────┬─────┘  ║  ║
║  ╚═══════╪══════════╪════════════╪════════════╪═══════════╪═════════╝  ║
║          │       observes & reacts to ViewModel state     │             ║
║  ╔═══════▼══════════▼════════════▼════════════▼═══════════▼═════════╗  ║
║  ║                       VIEWMODEL  LAYER                            ║  ║
║  ║              "The brain — bridges UI and data"                   ║  ║
║  ║                                                                   ║  ║
║  ║  ┌──────────────────────┐  ┌──────────────┐  ┌───────────────┐  ║  ║
║  ║  │   DrivingViewModel   │  │LanguageVM    │  │DriverModeVM   │  ║  ║
║  ║  │      Module 6        │  │  Module 7    │  │   Module 8    │  ║  ║
║  ║  │                      │  │              │  │               │  ║  ║
║  ║  │ isMonitoring: bool   │  │locale: Locale│  │isDriverMode   │  ║  ║
║  ║  │ isDriving: bool      │  │isEnglish:bool│  │status: enum   │  ║  ║
║  ║  │ motionLevel: double  │  │toggle()      │  │whitelistedApps│  ║  ║
║  ║  │ noiseLevel: double   │  │              │  │toggleApp()    │  ║  ║
║  ║  │ logs: List<DrivingLog│  └──────────────┘  └───────────────┘  ║  ║
║  ║  │ startMonitoring()    │                                        ║  ║
║  ║  │ stopMonitoring()     │                                        ║  ║
║  ║  │ loadLogs()           │                                        ║  ║
║  ║  └──────────┬───────────┘                                        ║  ║
║  ╚═════════════╪══════════════════════════════════════════════════════╝ ║
║                │  reads from / writes to                                ║
║  ╔═════════════▼══════════════════════════════════════════════════════╗ ║
║  ║                        MODEL  LAYER                                ║ ║
║  ║                "Data sources and business logic"                   ║ ║
║  ║                                                                    ║ ║
║  ║  ┌──────────────┐  ┌─────────────────┐  ┌───────────────────┐   ║ ║
║  ║  │SensorManager │  │ DrivingDetector │  │  SupabaseService  │   ║ ║
║  ║  │   Module 9   │  │   Module 10     │  │    Module 11      │   ║ ║
║  ║  │              │  │                 │  │                   │   ║ ║
║  ║  │Accelerometer │  │ √(x²+y²+z²)    │  │ INSERT logs       │   ║ ║
║  ║  │  500ms stream│  │ -gravity = net  │  │ SELECT history    │   ║ ║
║  ║  │Microphone dB │  │ motion>1.5 AND  │  │ RLS per user      │   ║ ║
║  ║  │  continuous  │  │ noise>60 →      │  │ Auth integration  │   ║ ║
║  ║  └──────┬───────┘  │ DRIVING ✅      │  └─────────┬─────────┘   ║ ║
║  ║         │          └─────────────────┘            │             ║ ║
║  ╚═════════╪═══════════════════════════════════════╪══════════════╝ ║
╚════════════╪═══════════════════════════════════════╪════════════════╝
             │                                       │
   ┌──────────▼──────────┐               ┌───────────▼───────────────┐
   │   📱 Android Hardware│               │   ☁️ Supabase Cloud       │
   │   Accelerometer      │               │   PostgreSQL Database     │
   │   Microphone         │               │   REST API + Auth         │
   │   DND API (silent)   │               │   Row Level Security      │
   └─────────────────────┘               └───────────────────────────┘
```

---

## 🌊 Data Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                        DETECTION PIPELINE                            │
└─────────────────────────────────────────────────────────────────────┘

  [USER TAPS START]
        │
        ▼
  ┌─────────────────────────────────────┐
  │   SensorManager — reads every 500ms  │
  │   Accelerometer → x, y, z values    │
  │   Microphone    → dB level           │
  └─────────────────────┬───────────────┘
                        │ check every 1 second
                        ▼
  ┌──────────────────────────────────────────────────────────┐
  │               DrivingDetector Algorithm                   │
  │                                                           │
  │   magnitude = √(x² + y² + z²)                           │
  │   netMotion = |magnitude − 9.8|   ← subtract gravity    │
  │                                                           │
  │   IF netMotion > threshold (default: 1.5 m/s²)          │
  │   AND noiseLevel > threshold (default: 60 dB)           │
  │        → DRIVING DETECTED ✅                             │
  │   ELSE → NOT DRIVING 🟢                                 │
  │                                                           │
  │   Both thresholds adjustable in Settings screen sliders  │
  └────────────────────┬────────────────────────────────────┘
                       │ status changed?
                       ▼
         ┌─────────────────────────────────┐
         │        Driver Mode check         │
         │                                  │
         │  Normal → Silence EVERYTHING     │
         │  Driver → Silence ALL except:    │
         │    ✅ Yango (if enabled)         │
         │    ✅ inDrive (if enabled)       │
         │    ✅ Phone calls (always)       │
         │    ✅ Google Maps (always)       │
         └──────────────┬──────────────────┘
                        │
                        ▼
             ┌──────────────────────────┐
             │   Log saved to Supabase   │
             │   {                       │
             │     user_id,              │
             │     status: "DRIVING",    │
             │     motion: 2.4,          │
             │     noise: 68.4           │
             │   }                       │
             └──────────────────────────┘
                        │
                        ▼
             ┌──────────────────────────┐
             │  UI rebuilds via Provider │
             │  Red rings animate        │
             │  Alert banner appears     │
             │  Stats update live        │
             └──────────────────────────┘
```

---

## 📁 Project Structure

```
driving_auto_silencer/
│
├── 📄 main.dart                        ← Entry + routes + MultiProvider
│
├── 📱 lib/views/
│   ├── splash_screen.dart              Module 1: Particles + shield logo
│   ├── home_screen.dart                Module 2: Animated rings + sensors
│   ├── history_screen.dart             Module 3: Sessions + analytics
│   ├── settings_screen.dart            Module 4: Language + thresholds
│   └── driver_mode_screen.dart         Module 5: Yango whitelist + status
│
├── 🧠 lib/viewmodels/
│   ├── driving_viewmodel.dart          Module 6: Core MVVM state + sensors
│   ├── language_viewmodel.dart         Module 7: EN/FR switching
│   └── driver_mode_viewmodel.dart      Module 8: Driver mode + whitelist
│
├── 📦 lib/models/
│   └── driving_log.dart                Module 9: DrivingLog data class
│
├── 🔌 lib/services/
│   ├── supabase_service.dart           Module 10: Cloud DB (CRUD + Auth)
│   └── background_service.dart         Module 11: Foreground service
│
├── 🤖 android/app/src/main/
│   ├── AndroidManifest.xml             ← All permissions declared
│   └── kotlin/.../MainActivity.kt      ← Silent mode native MethodChannel
│
└── 🧪 test/
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
| 🔧 Sensitivity sliders | Adjust motion & noise thresholds | 1 | ✅ Done |
| ☁️ Supabase logging | Sessions auto-saved to cloud database | 2 | ✅ Done |
| 📜 Session history | View, filter and delete past sessions | 2 | ✅ Done |
| 📊 Analytics dialog | Trips, time, silences, safe sessions | 2 | ✅ Done |
| 🔄 Background service | Runs silently when app is closed | 2 | ✅ Done |
| 🚖 Driver Mode | Yango/inDrive whitelist when silenced | 2 | ✅ Done |
| 🟢 Availability status | Available / Busy / Offline status | 2 | ✅ Done |
| 🔒 Row Level Security | Each user sees only their own data | 2 | ✅ Done |
| 🧪 Unit tests | Automated tests for all logic | 3 | 🔜 Upcoming |
| 📦 APK release | Installable on any Android 8+ device | 3 | 🔜 Upcoming |

---

## 🚖 Driver Mode — For Yango & Professional Drivers

```
┌──────────────────────────────────────────────────────────┐
│                   DRIVER MODE SCREEN                      │
│                                                           │
│  🚖 Driver Mode                          [● ON]          │
│  "Yango & order apps stay active                          │
│   while phone is silenced"                                │
│                                                           │
│  MY STATUS                                               │
│  [🟢 Available]    [🔴 Busy]    [⚫ Offline]             │
│                                                           │
│  ALLOWED APPS WHEN DRIVING               3 active        │
│  ──────────────────────────────────────────────          │
│  RIDE-HAILING                                            │
│  🚖 Yango              ✅ enabled                        │
│  🚗 inDrive            ☐  disabled                       │
│  ⚫ Uber Driver         ☐  disabled                       │
│  🟢 Bolt Driver        ☐  disabled                       │
│                                                           │
│  DELIVERY                                                │
│  📦 Glovo              ☐  disabled                       │
│  🛵 Lalamove           ☐  disabled                       │
│                                                           │
│  ESSENTIAL                                               │
│  📞 Phone Calls        🔒 Always on                      │
│  🗺️  Google Maps       🔒 Always on                      │
└──────────────────────────────────────────────────────────┘
```

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
│ Background Service   │ flutter_foreground_task ^8.x     │
│ Cloud Backend        │ Supabase (PostgreSQL + Auth)      │
│ Environment vars     │ flutter_dotenv ^5.2.1            │
│ Permissions          │ permission_handler ^11.3.1       │
│ State Management     │ provider ^6.1.5                  │
│ Localization         │ flutter_localizations            │
│ Fonts                │ google_fonts ^6.2.1              │
│ Target Platform      │ Android API 27+ (Android 8.0+)  │
│ IDE                  │ VS Code + Android Studio         │
│ Version Control      │ Git + GitHub (Organisation)      │
└──────────────────────┴──────────────────────────────────┘
```

---

## 🗄️ Database Schema

```sql
-- ── TABLE 1: profiles ─────────────────────────────────────────────
CREATE TABLE profiles (
  id                 UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  created_at         TIMESTAMPTZ DEFAULT now(),
  email              TEXT,
  full_name          TEXT,
  avatar_url         TEXT,
  preferred_language TEXT DEFAULT 'fr'
);

-- ── TABLE 2: driving_logs ─────────────────────────────────────────
CREATE TABLE driving_logs (
  id            UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at    TIMESTAMPTZ DEFAULT now() NOT NULL,
  user_id       UUID        REFERENCES auth.users(id) ON DELETE CASCADE,
  status        TEXT        NOT NULL CHECK (status IN ('DRIVING','NOT_DRIVING')),
  motion_level  FLOAT       NOT NULL DEFAULT 0,
  noise_level   FLOAT       NOT NULL DEFAULT 0,
  duration_min  INTEGER     DEFAULT 0,
  latitude      FLOAT,
  longitude     FLOAT
);

-- ── TABLE 3: app_settings ─────────────────────────────────────────
CREATE TABLE app_settings (
  user_id           UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  motion_threshold  FLOAT   DEFAULT 1.5,
  noise_threshold   FLOAT   DEFAULT 60.0,
  language          TEXT    DEFAULT 'fr',
  notifications_on  BOOLEAN DEFAULT true
);

-- ── Row Level Security ────────────────────────────────────────────
ALTER TABLE profiles     ENABLE ROW LEVEL SECURITY;
ALTER TABLE driving_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_settings ENABLE ROW LEVEL SECURITY;

-- Auto-create profile + settings on signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, email) VALUES (NEW.id, NEW.email);
  INSERT INTO app_settings (user_id) VALUES (NEW.id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();
```

---

## 🏃 Agile Sprint Plan

```
╔════════════════════════════════════════════════════════════════╗
║  SPRINT 1 — "Make It Work"                      ✅ COMPLETE   ║
╠════════════════════════════════════════════════════════════════╣
║  ✅ Flutter project setup + MVVM architecture                  ║
║  ✅ "Sentinel Glow" design system (Space Grotesk + Manrope)   ║
║  ✅ Splash screen — particle field + floating shield logo      ║
║  ✅ Home screen — safe state (green animated rings)            ║
║  ✅ Home screen — driving state (red pulse rings + alert)      ║
║  ✅ History screen — session cards + filter chips + pills      ║
║  ✅ Settings screen — EN/FR language + sensitivity sliders     ║
║  ✅ DrivingViewModel — state management via Provider           ║
║  ✅ Bilingual support — English and French                     ║
║  ✅ Real accelerometer sensor integration (500ms stream)       ║
║  ✅ Real microphone noise detection (continuous)               ║
║  ✅ Driving detection algorithm (motion + noise thresholds)    ║
║  ✅ Silent mode via Android MethodChannel (MainActivity.kt)    ║
║  ✅ AndroidManifest — all required permissions                 ║
╚════════════════════════════════════════════════════════════════╝

╔════════════════════════════════════════════════════════════════╗
║  SPRINT 2 — "Make It Remember"                  ✅ COMPLETE   ║
╠════════════════════════════════════════════════════════════════╣
║  ✅ Supabase project — 3 tables: profiles, logs, settings     ║
║  ✅ Row Level Security — users see only their own data         ║
║  ✅ Auto-trigger — profile + settings created on signup        ║
║  ✅ Flutter ↔ Supabase connection via flutter_dotenv          ║
║  ✅ Auto-save session to cloud on status change                ║
║  ✅ History screen loads real data from Supabase cloud         ║
║  ✅ Analytics dialog — trips, time, silences, safe sessions    ║
║  ✅ Swipe-to-delete session cards (Dismissible widget)         ║
║  ✅ Background foreground service (runs when app is closed)    ║
║  ✅ Driver Mode — Yango/inDrive/Uber whitelist                 ║
║  ✅ Availability status — Available / Busy / Offline           ║
║  ✅ App whitelist by category (ride-hailing, delivery, nav)    ║
║  ✅ Real user feedback integrated — Yango driver interview     ║
╚════════════════════════════════════════════════════════════════╝

╔════════════════════════════════════════════════════════════════╗
║  SPRINT 3 — "Make It Professional"              🔜 UPCOMING   ║
╠════════════════════════════════════════════════════════════════╣
║  ⬜ Unit tests — DrivingDetector (100% coverage target)        ║
║  ⬜ Unit tests — SensorManager stream testing                  ║
║  ⬜ Widget tests — HomeScreen state changes                    ║
║  ⬜ Full project documentation                                 ║
║  ⬜ APK build + install on physical device                     ║
║  ⬜ Performance profiling + battery optimisation               ║
╚════════════════════════════════════════════════════════════════╝
```

---

## 🚀 Getting Started

### Prerequisites

```bash
flutter doctor   # must show ✅ Flutter + ✅ Android toolchain
```

| Tool | Minimum Version |
|---|---|
| Flutter | ≥ 3.0.0 |
| Dart | ≥ 3.0.0 |
| Android | API 27+ (Android 8.0) |

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/androit-development/autosilencer-flutter.git
cd autosilencer-flutter

# 2. Install dependencies
flutter pub get

# 3. Create your .env file at project root (never commit this file)
SUPABASE_URL=https://yourproject.supabase.co
SUPABASE_ANON_KEY=eyJhbGci...

# 4. Run on emulator or connected device
flutter run
```

### Build Release APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## 🤝 Team & Collaboration

<table>
<tr>
<td align="center" width="50%">

[![GitHub](https://img.shields.io/badge/GitHub-KFJerwan-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/KFJerwan)


</td>
<td align="center" width="50%">



[![GitHub](https://img.shields.io/badge/GitHub-Androit--Dev-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/androit-development)

</td>
</tr>
</table>

### Git Workflow

```
main          ←── protected: stable reviewed code only
  │
  ├── start              ← initial setup + first screens
  ├── feat/sensors       ← Sprint 1: sensor integration
  ├── feat/backend       ← Sprint 2: Supabase + Driver Mode
  └── feat/tests         ← Sprint 3: unit tests

Commit convention:
  feat:   new feature
  fix:    bug fix
  docs:   documentation
  test:   test files
  style:  UI / design

Pull Request rule:
  Every branch → PR → teammate reviews → merge to main
```

---

<div align="center">

**ICT University, Yaoundé, Cameroon 🇨🇲**

**Organisation: [Androit Development](https://github.com/androit-development)**

<br/>

*Built with ❤️ in Cameroon — because every safe arrival matters.*

<img width="100%" src="https://capsule-render.vercel.app/api?type=waving&color=0:2979FF,50:1a3a6e,100:060E1E&height=120&section=footer"/>

</div>
