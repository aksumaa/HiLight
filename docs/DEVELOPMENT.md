# HiLight development notes

A personal library for sentences you scan, speak, or type. The iPhone keeps
the notes. The API is optional and is only required for sync, server OCR, and
speech-to-text.

## Run

From `apps/mobile`:

```bash
flutter pub get
flutter run
```

On a connected iPhone:

```bash
flutter devices
flutter run -d <iphone-id>
```

Release (https only; it will not call a local `http://` API):

```bash
flutter run --release -d <iphone-id>
```

A development install is signed with the Apple Development certificate for
team `2K296QJDKN`. If the phone refuses to open it, trust that certificate in
Settings → General → VPN & Device Management.

Debug against the API on this Mac (phone and Mac on the same Wi-Fi):

```bash
flutter run -d <iphone-id> --dart-define=API_BASE=http://192.168.1.20:8000
```

Replace the address with the Mac (`ipconfig getifaddr en0`). Plain http is
allowed only in debug builds. The Debug configuration uses
`apps/mobile/ios/Runner/Info-Debug.plist`, which permits local networking.
Release and Profile use `Info.plist` and do not.

The camera and microphone need the physical phone. The Simulator has no camera.

## API

Docker is required. From `apps/backend`:

```bash
cp .env.example .env
# Set a long JWT_SECRET. Do not commit .env.
docker compose down -v   # only when you want a clean database
docker compose up --build
```

Postgres with pgvector listens on port 5432. The API listens on port 8000.
`http://127.0.0.1:8000/health` should return `{"status":"ok"}`.

This machine did not have a `docker` command when the release checklist was
written. If `docker` is missing, install Docker Desktop and open it once
before `docker compose`.

## Test

From `apps/mobile`:

```bash
flutter analyze
flutter test
```

Backend tests need Postgres (the compose `db` service is enough). From
`apps/backend`:

```bash
python3.12 -m venv .venv
source .venv/bin/activate
pip install -e ".[dev]"
pytest
```

## Environment

App:

| Variable | Debug | Release |
| --- | --- | --- |
| `API_BASE` | `http://127.0.0.1:8000` if unset | must be `https://…`; otherwise the app uses `https://api.hilight.invalid` and will not connect |
| `USE_FAKE_OCR` | off | off |
| `USE_FAKE_STT` | off | off |

API (see `apps/backend/.env.example`): `DATABASE_URL`, `JWT_SECRET`,
`JWT_ACCESS_MINUTES`, `JWT_REFRESH_DAYS`, `OCR_PROVIDER`, `STT_PROVIDER`,
`WHISPER_MODEL`, `WHISPER_DEVICE`, `OCR_MAX_BYTES` (8 MB), `STT_MAX_BYTES`
(25 MB), and the OCR/STT rate limits. Change `JWT_SECRET` before anyone else
can reach the API.

## Architecture

Flutter, feature-first: `apps/mobile/lib/core` (theme, l10n, router),
`lib/data` (Drift, repositories, sync),
`lib/features/<feature>/{presentation,application,domain}`.
State is Riverpod. Navigation is go_router. Settings are shared preferences.
Access and refresh tokens are in the iOS Keychain (`flutter_secure_storage`),
not in preferences.

Capture sources (`PhoneCameraSource`, `PhoneMicSource`, `ManualInputSource`,
`MockDeviceSource`) emit a `CaptureEvent`. The capture pipeline runs OCR or
speech-to-text, then the edit screen saves a library item. English and Uzbek
Latin photos use on-device ML Kit. Russian photos and all voice notes go to
the API when you are signed in and online.

The API is FastAPI. Accounts, items, collections, OCR, and speech-to-text are
the routes that exist. Items are scoped to the signed-in user. Sync pushes a
local outbox, then pulls changes. The newer `updated_at` wins; equal times
keep the server copy.

## What is stubbed

These are not built. They are not hidden behind a switch.

- HiLight AI matches keywords in the notes already on the phone and shows a
  fixed sentence. It does not call a model, stream, speak, or enforce a daily
  limit.
- There is no assistant that opens Library, writes a note, searches, or
  changes theme or language from a command.
- The device screen saves one sample sentence through `MockDeviceSource`. It
  does not scan for Bluetooth, and it does not receive a photo or an audio file.
- Export, delete account, delete-with-undo, Sign in with Apple, and Google
  sign-in are not in the app. The Apple and Google verifiers on the server
  raise `NotImplementedError`.
- Insights is a short explanation, not a report.
- There is no "Try it" coach mark on first launch.

## TestFlight, by hand

1. Install Docker, start the API, and put a real `https` URL in the release
   build with `--dart-define=API_BASE=https://…` when you want sync in release.
2. In Xcode, open `apps/mobile/ios/Runner.xcworkspace`. Signing & Capabilities:
   your team is already `2K296QJDKN`. Confirm the bundle id `com.muslima.hilight`.
3. Add no extra capabilities yet. Sign in with Apple and Bluetooth are not
   implemented, so do not turn those capabilities on until the code exists.
4. Archive (Product → Archive) and upload with the Organizer or
   `xcodebuild -exportArchive`.
5. In App Store Connect, create the app, answer the privacy questionnaire to
   match `apps/mobile/ios/Runner/PrivacyInfo.xcprivacy` (email and notes for
   app functionality, no tracking), and add a tester.
6. The usage strings cover camera, microphone, and local network, in English,
   Russian, and Uzbek. There is no Bluetooth string and no Speech framework
   string, because the app uses neither.
7. Version in `apps/mobile/pubspec.yaml` is `1.0.0+2`. Raise the build number
   for every upload.
