# Gym Manager 🏋️‍♂️

A cross-platform Gym Management and Member Tracking System built with **Flutter 3.24+** and **Material Design 3**, designed to mirror the exact UI/UX, workflow, and architecture of **library-app-N**.

---

## 📱 Features

- **Exact Screenshot Match**:
  - Deep Teal Theme (`#005C53`) with status bar coordination.
  - Custom AppBar with notification badge (`3`), recycle bin, and guide actions.
  - Dual Search Bar: Dynamic switching between **Mobile Number** and **Member ID** via the `M ID` toggle.
  - Horizontally scrollable filter pills: `All`, `Needs Attention First`, `All Plans`, `Select Batch`.
  - Empty state with direct admission action: `No Members Found`.
  - Extended Floating Action Button: `+ Add Member`.
  - Pinned business alerts: `💰 You haven't selected a currency yet.` with multi-currency picker.
  - 4-Tab Bottom Navigation: **Members**, **Dashboard**, **Reports**, **Gym**.

- **Offline-First Reactive State**:
  - Managed by `GymService` singleton with real-time `StreamController` broadcasts.
  - Member demographic data, plans, dues, and batch tracking.

- **Automated CI/CD**:
  - Automated GitHub Actions building Android Release APK and deploying web application to GitHub Pages.

---

## 🏗️ Project Architecture

```
lib/
├── constants/
│   └── app_colors.dart
├── models/
│   └── gym_models.dart
├── screens/
│   ├── dashboard_screen.dart
│   ├── gym_screen.dart
│   ├── main_hub_screen.dart
│   ├── members_screen.dart
│   └── reports_screen.dart
├── services/
│   └── gym_service.dart
├── widgets/
│   ├── add_member_dialog.dart
│   ├── currency_picker_dialog.dart
│   └── filter_bottom_sheet.dart
└── main.dart
```
