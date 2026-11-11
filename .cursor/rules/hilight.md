# HiLight: project rules
HiLight is a personal knowledge app (Flutter, iOS + Android). Users capture
sentences by scanning book pages with the phone camera, recording voice
(speech-to-text) or typing. Everything lands as text items in one Library.
Users chat with "HiLight AI" about their own notes. Later a Bluetooth pen
device will also send scans/voice into the same flow.

Product rules:
- Library is one feed of Items. Books/tags are OPTIONAL collections.
- Item types: quote, voice, note, ai. Sources: scan, voice, manual, device.
- 3 languages: Uzbek (uz), Russian (ru), English (en), all UI strings via
  gen-l10n .arb files, never hardcoded.
- Themes: light, dark, system. Design tokens only, no hardcoded colors.
- Must work fully offline and without the hardware device.
- HiLight AI answers carry a label: "From your notes" (with source chips) or
  "General knowledge".

Architecture:
- Dart 3, feature-first folders: lib/core (theme, l10n, router, utils),
  lib/data (db, repositories, models), lib/features/<feature>/
  {presentation,application,domain}.
- State: flutter_riverpod. Navigation: go_router. Local DB: drift.
  Settings: shared_preferences.
- Input sources implement `abstract class CaptureSource` and emit
  `CaptureEvent`s: PhoneCameraSource, PhoneMicSource, ManualInputSource,
  HiLightDeviceSource (BLE, later), MockDeviceSource.
- OCR and STT behind `OcrService` and `SttService` interfaces.
- UI never touches drift directly, only repositories.
- Library layouts are strategies behind one `LibraryLayout` interface.

Design: warm, minimalist, editorial. Light: bg #F4EFE8, card #FBF8F3, text
#2B2622, secondary #8A7F74, primary #6B4A2F. Dark: bg #1C1917, card #26221F,
text #F1EBE3. Accent per type: quote #D9A441, voice #8B6FBF, note #6B4A2F,
ai #5B8DB8. Radius 20-24, soft shadows. Fonts: Inter (UI), Lora (quotes).
Bottom nav: Home, Library, center round Capture button, Insights, Profile.

Code quality: small widgets, const constructors, no business logic in widgets,
handle loading/empty/error states, unit tests for repositories and the capture
pipeline, no new packages without a reason, `flutter analyze` must be clean.

Folder structure:
- `apps/mobile` — Flutter app (lib, ios, test, assets, pubspec).
- `apps/backend` — FastAPI, Alembic, docker-compose, tests.
- `apps/web` — reserved for a future web frontend.
- `firmware` — reserved for device firmware.
- `docs` — project notes.
- `.cursor/rules/hilight.md` — these rules, at the repo root.
