# Bankbox — Build Plan

> **Constraint:** No Android Studio on dev machine. All code is written locally, zipped, and shipped to a build machine (Mac) for compilation & APK generation.

---

## 1. What Bankbox Does

Reads SMS → Filters bank messages (86 sender codes) → Displays list → Exports all data to Excel (.xlsx) → Saves to device → Share via WhatsApp.

---

## 2. Bank SMS Sender Codes (86 codes)

These codes are matched against the SMS sender field to extract bank transaction messages.
The sender field typically appears as `AD-HDFCBK`, `HP-SBIINB`, `BZ-ICICIB`, etc.
We use a **contains()** match — if any of these codes appear anywhere in the sender string, it's a bank SMS.

```
SBIINB   HDFCBK   ICICIB   AXISBK   PNBSMS   KOTAKB   BARBNK   CANBNK
UBINRA   IDFCFB   IOBCHN   IOB      INDBNK   YESBNK   INDUSB   FEDBNK
CSBKOL   AIRBNK   PYTMBN   DBSSBK   AUFBIN   UJJIBF   DCBLTD   RATNBO
TMBLTD   CUBIND   KARBKB   MAHBIN   SBININ   BOIIND   CENTBK   INDIAN
UCOBAN   ABNABK   ADCBBK   AMEXBK   ANZBGK   BANDHK   MAYBKI   BOABK
BBKBK    BOCBK    BOCHK    BARCBK   BNPBK    CITIBK   CRSUIS   CREBK
DEUTBK   DHLBK    DOHBK    EMRNBD   ESAFBK   FINOPB   FABBK    FRBNK
HNDLBK   HSBCBK   IDBIBK   IPPB     ICBCBK   IBKBK    JKBK     JPMBK
KEBHBK   KOOKBK   KTHBK    MIZUBK   MUFGBK   NAINBK   NATWBK   PSBBK
QNBBK    RABOBK   SAXOBK   SBERBK   SCOTBK   SHINBK   SOCGBK   SONBK
SIBK     SCBK     SMBCBK   UOBBK    WESTBK   WOORIBK
```

**Filtering logic:** For each SMS, run `sender.toUpperCase().contains(code)` against all 86 codes. First match wins and tags the message with that bank.

---

## 3. Tech Stack

| Layer       | Choice                                   |
| ----------- | ---------------------------------------- |
| Framework   | Flutter 3.x                              |
| UI Kit      | `shadcn_flutter` (shadcn/ui for Flutter) |
| SMS Read    | `flutter_sms_inbox` ^1.0.2               |
| Permissions | `permission_handler` ^12.0.1             |
| Excel       | `syncfusion_flutter_xlsio` ^27.1.58      |
| File Paths  | `path_provider` ^2.1.4                   |
| Share       | `share_plus` ^10.1.4                     |
| Date Format | `intl` ^0.19.0                           |

---

## 4. Project Structure

```
bankbox/
├── lib/
│   ├── main.dart                   # App entry, ShadcnApp setup
│   ├── models/
│   │   └── bank_sms_data.dart      # SMS data model
│   ├── data/
│   │   └── bank_directory.dart     # 86 bank codes + names + colors
│   ├── services/
│   │   ├── sms_service.dart        # Permission + Read + Filter SMS
│   │   └── excel_service.dart      # Build Excel + Save + Share
│   └── screens/
│       ├── permission_screen.dart  # Grant permission (landing)
│       ├── home_screen.dart        # Bank-wise summary cards
│       └── sms_list_screen.dart    # Filtered SMS list + Export btn
├── android/
│   └── app/src/main/AndroidManifest.xml  # SMS permissions declared
├── pubspec.yaml
├── PLAN.md          ← this file
└── README.md        ← build machine setup guide
```

---

## 5. App Screens & Flow

```
┌─────────────────────┐
│  Permission Screen   │  → Shadcn PrimaryButton: "Allow SMS Access"
│  (one-time)          │  → On deny: show alert dialog with rationale
└────────┬────────────┘
         ▼
┌─────────────────────┐
│  Home Screen         │  → Scaffold with AppBar
│                      │  → Summary Card: "Found X bank messages"
│                      │  → Bank-wise breakdown (Card per bank)
│                      │  → Each card: bank name, count, color strip
│                      │  → FAB: "Export All to Excel"
└────────┬────────────┘
         ▼
┌─────────────────────┐
│  SMS List Screen     │  → Tap a bank card → see its messages
│                      │  → ListView of SMS (sender, date, body)
│                      │  → Search/filter bar (optional v2)
└─────────────────────┘
         ▼
┌─────────────────────┐
│  Export & Share       │  → Progress indicator while writing Excel
│                      │  → Snackbar: "Saved to Downloads"
│                      │  → BottomSheet: Share via WhatsApp / other
└─────────────────────┘
```

---

## 6. Data Model

```dart
class BankSmsData {
  final int? id;
  final String sender;        // Raw sender e.g. "AD-HDFCBK"
  final String bankCode;      // Matched from 86 sender codes above
  final String bankName;      // e.g. "HDFC Bank"
  final String body;          // Full SMS text
  final DateTime? date;
  final bool isRead;
}
```

---

## 7. Excel Output Columns

| Col | Header      | Source                 |
| --- | ----------- | ---------------------- |
| A   | S.No        | Auto-increment         |
| B   | Date & Time | `sms.date`             |
| C   | Sender      | `sms.sender` (raw)     |
| D   | Bank Code   | Matched from 86 codes  |
| E   | Bank Name   | From bank directory    |
| F   | SMS Body    | `sms.body` (full text) |
| G   | Read Status | Read / Unread          |
| H   | SMS ID      | `sms.id`               |

File saved as: `Bankbox_<timestamp>.xlsx` in Downloads.

---

## 8. App Theme — Black & White

The app uses a **strict black and white theme** — no brand colors, no gradients. Clean, minimal, high-contrast.

```dart
ShadcnApp(
  title: 'Bankbox',
  theme: ThemeData(
    colorScheme: LegacyColorSchemes.darkZinc(), // black & white zinc palette
    radius: 0.5,
  ),
);
```

| Element          | Color                           |
| ---------------- | ------------------------------- |
| Background       | Pure black `#000000`            |
| Cards / Surface  | Dark grey `#111111` / `#1A1A1A` |
| Text (primary)   | White `#FFFFFF`                 |
| Text (secondary) | Grey `#A1A1A1`                  |
| Buttons          | White on black                  |
| Borders          | Subtle grey `#2A2A2A`           |
| Accents          | White only — no color           |

No bank brand colors in the UI. Bank names are shown as plain white text. The only visual distinction between banks is the name and count — not color.

---

## 9. shadcn_flutter UI Components Used

| Component               | Where                                       |
| ----------------------- | ------------------------------------------- |
| `ShadcnApp`             | Root app widget with dark zinc theme        |
| `PrimaryButton`         | Permission grant, Export, Share buttons     |
| `Card` / `CardContent`  | Bank summary cards on home screen           |
| `Alert` / `AlertDialog` | Permission denied rationale, export success |
| `Badge`                 | SMS count per bank                          |
| `Scaffold` + `AppBar`   | Screen layout                               |
| `CircularProgress`      | Loading states (SMS fetch, Excel export)    |
| `BottomSheet`           | Share options after export                  |
| `DataTable`             | SMS list view (optional, or use ListView)   |

---

## 10. Build Steps (Coding Order)

### Step 1 — Scaffold the project _(30 min)_

- [ ] Create `pubspec.yaml` with all dependencies
- [ ] Set up `AndroidManifest.xml` with permissions
- [ ] Set `minSdkVersion: 21` in `build.gradle`
- [ ] Create folder structure under `lib/`

### Step 2 — Bank Directory with 86 codes _(30 min)_

- [ ] Create `bank_directory.dart` with all 86 sender codes from Section 2
- [ ] Map each code → bank name (from attached bank_directory.py)
- [ ] Implement `isBankSender()`, `findBankCode()`, `getBankName()`

### Step 3 — SMS Service _(1–2 hrs)_

- [ ] `requestPermission()` → returns bool
- [ ] `fetchAllSms()` → returns raw SMS list
- [ ] `filterBankSms()` → matches sender against 86 codes → returns `List<BankSmsData>`
- [ ] Handle edge cases: null sender, empty body

### Step 4 — Excel Service _(1–2 hrs)_

- [ ] Create workbook with headers + styling
- [ ] Loop through messages, write rows
- [ ] Auto-fit columns
- [ ] Save to Downloads path
- [ ] Return file path for sharing

### Step 5 — Permission Screen _(1 hr)_

- [ ] shadcn Card with app icon + explanation text
- [ ] PrimaryButton → triggers permission request
- [ ] If granted → navigate to Home
- [ ] If denied → show AlertDialog with rationale

### Step 6 — Home Screen _(1–2 hrs)_

- [ ] On init: call SMS service, show loading
- [ ] Display total count in a summary Card
- [ ] Group by bank → show Card per bank (name, count, color)
- [ ] Tap card → navigate to SMS List Screen
- [ ] FAB → trigger Excel export

### Step 7 — SMS List Screen _(1 hr)_

- [ ] Receive bank code as param
- [ ] ListView.builder with SMS items
- [ ] Each item: sender, date, body preview

### Step 8 — Export + Share _(1 hr)_

- [ ] Show CircularProgress during export
- [ ] On complete: Snackbar + share_plus to open share sheet
- [ ] WhatsApp / file manager share

### Step 9 — Zip & Ship _(15 min)_

- [ ] `zip -r bankbox.zip bankbox/`
- [ ] Transfer zip to build machine (AirDrop / Drive / USB)
- [ ] On build machine: follow README.md steps

---

## 11. Android Permissions Required

Add to `android/app/src/main/AndroidManifest.xml` before `<application>`:

```xml
<uses-permission android:name="android.permission.READ_SMS"/>
<uses-permission android:name="android.permission.RECEIVE_SMS"/>
<uses-permission android:name="android.permission.READ_PHONE_STATE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE"/>
```

---

## 12. Known Gotchas

1. **Emulator has no real SMS** — must test on physical device
2. **Android 10+ scoped storage** — use `MANAGE_EXTERNAL_STORAGE` or save via `path_provider` then share
3. **SMS sender format varies** — `AD-HDFCBK`, `HP-SBIINB`, `BZ-ICICIB` etc. — `contains()` handles this
4. **Large SMS volume** — use async + loading indicator; consider pagination if 10k+ messages
5. **ProGuard** — if release APK crashes, add keep rules for SMS library
6. **shadcn_flutter version** — pin version in pubspec to avoid breaking changes
7. **No Android Studio on dev machine** — all code is written blind, zipped, and built on the build machine. Use `flutter analyze` on the build machine before building APK to catch errors early
