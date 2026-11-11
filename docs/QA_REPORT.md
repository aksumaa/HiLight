# HiLight QA

Date: 2026-11-10. `docs/HILIGHT_REDESIGN.md` is not in the repository. This
pass followed `.cursor/rules/hilight.md` and the code that is actually there.
No new product features were added.

Screenshots: none. The iPhone screen was not driven (no tap, camera, or
microphone control from this Mac), so there is nothing honest to describe.

## How it was checked

| Check | Result |
| --- | --- |
| `docker compose down -v && docker compose up` | Fail. `docker` is not on `PATH` and Docker.app is not installed. The API container was not started. Homebrew Postgres 16 was already accepting connections on port 5432, so the API tests used that server instead. |
| `pytest` | Pass. 5 tests, from `apps/backend/` with `.venv/bin/pytest`. Auth, item isolation, last-write-wins, and OCR language/size rejection. |
| `flutter analyze` | Pass. No issues found. |
| `flutter test` | Pass. 14 tests. |
| `flutter run --release -d 00008110-001C495E223A801E` | Build succeeded. Launch from `flutter run` failed (`Could not run build/ios/iphoneos/Runner.app`, exit 2). `flutter install --release` then showed HiLight 1.0.0 (2) on the phone. `devicectl` refused to open it: the development profile is not trusted (`FBSOpenApplicationServiceErrorDomain` / Security). The UI was not exercised. |

## Scenarios

| Scenario | Result | Notes |
| --- | --- | --- |
| a. First launch: language, onboarding, register, login | Not run on device | Code path: onboarding until `onboarding_complete`, then the account screen until `gate_passed`. Register and login call `/auth/register` and `/auth/login`. They cannot succeed while the API is down. |
| a. "Try it" hints | Fail | No such UI exists. Not added. |
| b. Write a note | Not run on device | `ManualInputSource` saves a note through the capture pipeline. No photo or microphone involved. |
| b. Scan EN / RU / UZ, record voice in each, edit, save, see in Library | Not run on device | EN and UZ Latin use ML Kit on the phone. RU scan and every voice note need the API. Uzbek Cyrillic is not handled by the Latin model. I did not photograph a page or record audio. |
| c. Search, filters, 3 layouts | Pass in widget tests | `test/library_screen_test.dart` covers empty library, the voice filter, tag search, and the cards layout key. |
| c. Tags | Pass in widget test | Search matches the tag `Poems`. Editing a tag is on the note screen; that screen was not opened on the phone. |
| c. Delete with Undo | Fail | Delete asks for confirmation and soft-deletes the row. There is no Undo. Not added. |
| c. Persistence after restart | Not run on device | Notes are in Drift (`hilight.sqlite`). A process restart was not performed on the phone. |
| d. HiLight AI text and voice, notes / general / nothing-found, daily limit, offline, cancel, spoken answer | Fail | `FakeAiRepository` does a local keyword match and the chat screen shows a fixed sentence from the translation files. No model, stream, voice input, daily limit, cancel, or speech output. |
| e. Assistant commands | Fail | No command parser. Open Library, create a note, search, theme, and language are ordinary controls, not voice commands. |
| f. Airplane mode, add 3, sync, no duplicates | Not run on device | Offline writes stay in the Drift outbox. Sync pushes that outbox, then pulls. Newer `updated_at` wins (`test/sync_merge_test.dart`). A delete the server never stored used to fail the whole queue with 404; a 404 is now treated as already gone. Airplane mode was not switched on the phone, and the API was not up, so sync itself was not observed. |
| g. Two accounts cannot see each other's items or AI sources | Partial | `apps/backend/tests/test_items.py` passed: one user does not see the other's items. AI does not use the server, so "AI sources" isolation was not tested. It was not tried with two accounts on the phone. |
| h. Appearance: theme, layout, accent, font scale, language | Partial | `test/appearance_screen_test.dart` saves dark theme and compact layout and checks the preview. Accent, font scale, and a live language switch were not exercised on the phone. The system text size is no longer replaced by the in-app slider; the slider multiplies it. |
| i. Mock device: connect, receive a scan and a voice clip | Fail | The screen has no connect step. The button saves one sample sentence as a device note. It does not receive an image or audio. |
| j. Delete account and export | Fail | Neither exists in the app or the API. |

## Performance

Library lists use `ListView.builder`. A widget test builds 2,000 notes,
finds row 0, asserts row 1999 is not built, then drags the list and asserts
row 1999 is still not built. That is a widget test, not a frame-time
measurement on the phone. Scrolling was not watched on the device.

Cold start time was not measured. Camera and recording memory were not
measured. There is no Instruments trace.

## Accessibility

- Dynamic Type: the app multiplies the system text scaler by the in-app font
  scale instead of discarding the system size.
- VoiceOver: the tab buttons and the Capture ring expose their labels. The
  shutter already has a button label. Icon buttons that had a tooltip keep it.
- Contrast: secondary `#7C7167` on `#FCFAF7` is 4.57:1, which meets WCAG AA
  for normal text (4.5:1). It was calculated, not checked with a screen reader
  on device.
- Tap targets: the Capture ring is 56pt. Tab rows use 10pt of vertical padding
  around a 22pt icon and a 13pt label. This was not measured with the largest
  Dynamic Type on a phone, where a long translation can overflow.

## Security

- `git ls-files` shows no `.env`, `.pem`, or `.p12`. `.gitignore` ignores
  `.env`, `apps/backend/.env`, and `.venv`.
- Tokens are written only through `FlutterSecureStorage` with
  `KeychainAccessibility.first_unlock_this_device` and iCloud keychain sync off.
- A release build with a missing or `http` `API_BASE` uses
  `https://api.hilight.invalid`. Debug may use http. The built release
  `Info.plist` has no `NSAllowsLocalNetworking`. Debug builds use
  `ios/Runner/Info-Debug.plist`, which allows local networking. Flutter reads
  the source plist with `plutil`, so a preprocessor `#if` cannot live in
  `Info.plist`.
- The API rejects empty uploads, non-image OCR, non-audio speech, files over
  the configured byte limits, and a language other than `en`, `ru`, or `uz`.
  `tests/test_media.py` posted a `fr` language and a file one byte over 8 MB;
  both were rejected (422 `invalid_language`, 413 `file_too_large`). Passwords
  shorter than 8 characters are rejected (`test_short_password_is_rejected`).
  Item text is capped at 20,000 characters in the schema; that cap was read,
  not posted.
- The default `JWT_SECRET` in code is `dev-only-change-me`. It is a placeholder,
  not a committed production secret. Change it before the API is reachable.

## Release prep done in the tree

- Display name `HiLight`. Version `1.0.0+2`.
- App icon replaced the Flutter logo with a cream tile, a dark ring, and a
  gold line. Launch screen is the same cream, with no logo.
- Camera, microphone, and local-network strings in `en`, `ru`, and `uz`.
- No Bluetooth usage string and no Speech-framework string: the app does not
  call those APIs. Voice notes are recorded and, when online and signed in,
  sent to the API.
- `ios/Runner/PrivacyInfo.xcprivacy` declares email and notes for app
  functionality, no tracking, and the UserDefaults, file-timestamp, and disk
  space reasons Flutter and shared preferences use.
