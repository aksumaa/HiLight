# HiLight

A personal library for sentences you scan, speak, or type. The iPhone keeps
the notes. The API is optional.

## Run on the iOS Simulator

```bash
cd ~/Desktop/HiLight
flutter pub get
flutter run
```

`flutter run` lists devices when more than one is connected. Pick the
simulator:

```bash
flutter devices
flutter run -d <simulator-id>
```

The first launch asks for a language, shows three slides, then the sign-in
screen. "Continue on this iPhone" opens the library without an account.
Twelve sample notes are added once, only when the library is empty.

## Run on your iPhone

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Select the Runner target, Signing & Capabilities, and choose your Apple ID team.
3. On the iPhone, turn on Developer Mode (Settings → Privacy & Security).
4. Plug the phone in, or use the wireless device Flutter already sees, then:

```bash
flutter run -d <iphone-id>
```

The camera and microphone need the physical phone. The Simulator has no camera.

## API

The app works offline. To sync, OCR, and speech-to-text, start the API from
`backend/README.md`, then pass your Mac's address:

```bash
flutter run -d <iphone-id> --dart-define=API_BASE=http://192.168.1.20:8000
```

Replace the address with the Mac. The phone and the Mac must be on the same
Wi-Fi. Set `JWT_SECRET` in `backend/.env` before sharing the API beyond your
own machine. Do not commit `.env`.

## Checks

```bash
flutter analyze
flutter test
```
