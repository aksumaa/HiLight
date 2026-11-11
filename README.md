# HiLight

A personal library for sentences you scan, speak, or type. The phone keeps
the notes. The API is for sync, server OCR, and speech-to-text.

```
apps/mobile    Flutter app
apps/backend   FastAPI
apps/web       reserved
firmware       reserved
docs           notes
```

## Mobile

From `apps/mobile`:

```bash
flutter pub get
flutter run
flutter run -d <iphone-id>
flutter run --release -d <iphone-id>
flutter analyze
flutter test
```

Debug against an API on this Mac (same Wi-Fi):

```bash
flutter run -d <iphone-id> --dart-define=API_BASE=http://192.168.1.20:8000
```

## Backend

From `apps/backend`:

```bash
cp .env.example .env
docker compose up --build
```

Tests, with Postgres running:

```bash
python3.12 -m venv .venv
source .venv/bin/activate
pip install -e ".[dev]"
pytest
```

Longer notes: `docs/DEVELOPMENT.md` and `apps/backend/README.md`.
