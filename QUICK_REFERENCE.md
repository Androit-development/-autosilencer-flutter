# Quick Reference Guide - AutoSilencer Modular Structure

## 📂 Where to Find Everything

### 🎨 Design System (Colors, Fonts, Decorations)
- **Colors**: `lib/theme/app_colors.dart`
- **Text Styles**: `lib/theme/app_text_styles.dart`
- **Decorations**: `lib/theme/app_decorations.dart`
- **Import**: `import 'theme/index.dart'`

### ⚙️ Configuration & Constants
- **App Config**: `lib/config/app_config.dart` (theme, routes)
- **Constants**: `lib/constants/app_constants.dart` (durations, thresholds, sizes)
- **Import**: `import 'config/index.dart'` or `import 'constants/index.dart'`

### 🧩 Reusable Widgets
- **Common**: `lib/widgets/common/common_widgets.dart` (GlassCard, BottomNav, etc.)
- **Home**: `lib/widgets/home/home_widgets.dart` (StatusRing, StatCard, etc.)
- **Import**: `import 'widgets/common/index.dart'` or `import 'widgets/home/index.dart'`

### 🛠️ Utilities
- **Helpers**: `lib/utils/app_utils.dart` (StringUtils, DialogUtils, AnimationUtils)
- **Import**: `import 'utils/index.dart'`

### 📱 UI Screens
- **Home**: `lib/views/home_screen.dart`
- **History**: `lib/views/history_screen.dart`
- **Settings**: `lib/views/settings_screen.dart`
- **Splash**: `lib/views/splash_screen.dart`

### 💼 Business Logic
- **ViewModels**: `lib/viewmodels/` (DrivingViewModel, LanguageViewModel)
- **Services**: `lib/services/` (background_service, supabase_service)
- **Models**: `lib/models/` (DrivingLog)

---

## 🔍 How to Find Specific Things

| Need to... | Location | File |
|-----------|----------|------|
| Change app primary color | `lib/theme/` | `app_colors.dart` → `AppColors.primary` |
| Change button text size | `lib/theme/` | `app_text_styles.dart` → `AppText.headline()` |
| Update sensor threshold | `lib/constants/` | `app_constants.dart` → `SensorThresholds.motionThreshold` |
| Use a button component | `lib/widgets/common/` | `common_widgets.dart` → `ActionButton` |
| Add animation delay | `lib/constants/` | `app_constants.dart` → `AnimationDurations` |
| Format time display | `lib/utils/` | `app_utils.dart` → `StringUtils.formatTime()` |
| Show error dialog | `lib/utils/` | `app_utils.dart` → `DialogUtils.showErrorDialog()` |
| Create glass card | `lib/widgets/common/` | `common_widgets.dart` → `GlassCard` |

---

## 💻 Common Code Patterns

### Using Constants
```dart
import 'constants/index.dart';

// Animation durations
await Future.delayed(AnimationDurations.outerRotation);

// Sensor thresholds  
if (motion > SensorThresholds.motionThreshold) { }

// UI sizes
EdgeInsets padding = EdgeInsets.all(UISizes.paddingXl);

// Strings
const channelId = AppStrings.channelId;
```

### Using Theme
```dart
import 'theme/index.dart';

Text('Hello', style: AppText.headline(color: AppColors.primary))
Container(decoration: glassCard(leftBorderColor: AppColors.error))
```

### Using Common Widgets
```dart
import 'widgets/common/index.dart';

GlassCard(
  leftBorderColor: Colors.red,
  padding: EdgeInsets.all(16),
  child: Text('Content'),
)

ActionButton(
  label: 'Click me',
  onPressed: () => print('Clicked!'),
  isLoading: false,
)

BottomNav(
  currentIndex: _index,
  onTap: (i) => setState(() => _index = i),
  homeLabel: 'HOME',
  historyLabel: 'HISTORY',
  settingsLabel: 'SETTINGS',
  onSettingsTap: () => Navigator.pushNamed(context, '/settings'),
)
```

### Using Utilities
```dart
import 'utils/index.dart';

// Format strings
String time = StringUtils.formatTime(120);  // "2h"
String motion = StringUtils.formatMotion(2.5);  // "2.5 m/s²"
String noise = StringUtils.formatNoise(65.5);  // "66 dB"

// Show dialogs
DialogUtils.showErrorDialog(context, 'Something went wrong');
DialogUtils.showConfirmDialog(
  context,
  title: 'Delete?',
  message: 'Are you sure?',
  confirmText: 'Delete',
);

// Responsive sizes
double padding = SizeUtils.getResponsivePadding(context);
double fontSize = SizeUtils.getResponsiveFontSize(
  context,
  mobile: 14,
  tablet: 16,
  desktop: 18,
);
```

---

## 🔄 Import Cheat Sheet

```dart
// ✅ RECOMMENDED PATTERNS

// Get everything from a module
import 'theme/index.dart';           // All theme stuff
import 'config/index.dart';          # All config stuff  
import 'constants/index.dart';       # All constants
import 'widgets/common/index.dart';  # All common widgets
import 'utils/index.dart';           # All utilities

// ❌ AVOID (outdated)
import 'app_theme.dart';             # Old, use 'theme/index.dart'
import '../theme/app_colors.dart';   # Use barrel export
import '../theme/app_text_styles.dart'; # Use barrel export
```

---

## 📊 Module Responsibility Matrix

| Module | Responsibility | Key Files |
|--------|----------------|-----------|
| `theme/` | Design tokens | colors, typography, decorations |
| `config/` | App setup | theme config, routes |
| `constants/` | Magic values | durations, thresholds, sizes |
| `widgets/common/` | Shared UI | reusable components |
| `widgets/home/` | Home-specific UI | status ring, stat card |
| `utils/` | Helpers | string format,dialogs, animations |
| `viewmodels/` | State & logic | ViewModel pattern |
| `services/` | External APIs | Supabase, background tasks |
| `models/` | Data structures | DrivingLog, enums |
| `views/` | Screens | Full page UI |

---

## ✅ Best Practices

1. **Always use barrel exports** (`import 'module/index.dart'`)
2. **Extract magic numbers to constants**
3. **Create reusable widgets for repeated UI**
4. **Keep decorations in theme module**
5. **Use AppColors, AppText consistently**
6. **Leverage utility functions instead of inline logic**
7. **One widget per class (or closely related)**
8. **Document complex animations with comments**

---

## 🆘 Troubleshooting

### Import not found?
- Check you're using barrel export: `import 'module/index.dart'`
- Verify the file exists in the correct folder
- Check for typos in folder/file names

### Constant value not updating?
- Make sure you're using the constant, not hardcoding
- Check `lib/constants/app_constants.dart` for the value
- Ensure the service is using constants too

### Widget not rendering?
- Check all required parameters are provided
- Verify parent has proper constraints (width/height)
- Look for console errors

### Style not applied?
- Check you imported `'theme/index.dart'`
- Verify using correct class: `AppText.headline()` not `TextStyle(...)`
- Check color is correct: `AppColors.primary` not hardcoded

---

## 📞 Need Help?

| Issue | Solution |
|-------|----------|
| Don't know where to put something | See "Where to Find Everything" above |
| Need to reuse UI component | Check `widgets/common/` or `widgets/home/` |
| Need a common function | Check `utils/app_utils.dart` |
| Need to change design | Go to `theme/` files |
| Need timing values | Check `constants/app_constants.dart` |

---

**Your app is now modular, maintainable, and ready to scale!** 🚀
