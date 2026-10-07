# EduNexus

School · Parents · Students — connected.

EduNexus is a school ERP mobile app for Indian schools, built in Flutter. One app serves three roles:

| Role | What they get |
|---|---|
| **Parent** | Home dashboard with today's attendance, next class, pending homework, live bus and fee dues; homework, class work, attendance calendar and insights, marks and NEP 2020 Holistic Progress Card, e-content, timetable, school calendar, online tests, STEAM lab (single sign-on), fees via UPI (part-payments, Autopay, receipts), live bus tracking, gallery, one-time pickup pass with OTP/QR, health record, canteen wallet, school store, PTM slot booking, Write to School (ticketed, 48-hour SLA escalation, satisfaction rating), leave requests, announcements, notice board, Refer & Earn, AI weekly summary |
| **Teacher** | One-tap attendance (absent alerts to parents), post homework / class work / notices, approve leave, reply to parents, AI report-card remarks |
| **Principal** | KPIs, fee collection vs target, defaulters with WhatsApp reminders, Tally export, SLA escalations, admissions CRM pipeline, broadcast announcements |

Cross-cutting: English / తెలుగు / हिंदी, dark mode, Lite mode for low-end phones, DPDP-Act consent and masked Aadhaar, APAAR / PEN / UDISE+ fields.

> **Demo build.** All data is local sample data (no backend yet), and it resets when the app restarts. Sign in with any role, tap **Get OTP** and enter **1234**. Actions in one role show up in the others (e.g. a teacher approving leave, or marking roll 14 absent).

## Build

```bash
flutter pub get
flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk
```

Every push to `main` also builds the APK on GitHub Actions (download it from the run's artifacts).

Regenerate the launcher icons after changing the logo:

```bash
python tool/make_icon.py
```

## Project layout

```
lib/
  data/        models, sample data, AppState (single shared state for all roles)
  screens/
    parent/    shell + home dashboard
    teacher/   teacher app
    principal/ principal dashboard
    features/  feature screens shared by roles
  widgets/     common UI pieces and the brand mark
  l10n.dart    English / Telugu / Hindi strings
tool/make_icon.py   launcher icon generator
```

## Roadmap to production

1. Backend (multi-tenant): OTP auth, API, Postgres.
2. Payment gateway (Razorpay / Cashfree) with UPI Autopay mandates; Tally export.
3. WhatsApp Business API + SMS + FCM push.
4. Bus GPS devices + RFID boarding; maps.
5. Offline cache and background sync.
6. Admin web panel for the school office.
7. Release signing and Play Store listing (per-school white-label builds via flavors).
