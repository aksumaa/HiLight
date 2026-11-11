# HiLight API

FastAPI service for accounts, the library, sync, OCR, and speech-to-text.
The phone keeps its own database and uses this API when it is online.

## Run with Docker

From this folder:

```bash
cp .env.example .env
# Put a long random value in JWT_SECRET.
docker compose up --build
```

Postgres (with pgvector) listens on port 5432. The API listens on port 8000.
Open `http://127.0.0.1:8000/health` and you should see `{"status":"ok"}`.

Migrations run when the API container starts (`alembic upgrade head`).

## How the iPhone reaches this Mac

`localhost` on the phone is the phone, not your computer.

1. Mac and iPhone on the same Wi-Fi.
2. Find the Mac's address: System Settings → Network, or `ipconfig getifaddr en0`.
3. In the Flutter run command, pass that address:

From `apps/mobile`:

```bash
flutter run -d <iphone-id> --dart-define=API_BASE=http://192.168.1.20:8000
```

Replace `192.168.1.20` with your Mac. The app allows local HTTP
(`NSAllowsLocalNetworking`). The API container publishes port 8000 on the Mac,
so the phone uses that same port.

If the phone cannot connect, allow incoming connections for Docker/Python in
the macOS firewall, and confirm both devices are on the same network.

## Providers

OCR default is **Tesseract** on the API machine (`eng`, `rus`, `uzb` packs in
the image). It costs nothing per page. English and Russian printed text are
the realistic cases. Uzbek Latin (`uzb`) is installed, but photo quality on
book pages is not something I have verified.

Speech-to-text default is **faster-whisper**, model `base`, on CPU. It costs
nothing per minute. The first transcription downloads the model into the
container. English and Russian are languages Whisper was trained on. Uzbek is
not; the service does not force `language=uz` and Whisper may guess another
language. Treat Uzbek transcripts as unverified.

Set `OCR_PROVIDER=fake` and `STT_PROVIDER=whisper` is the docker default.
Tests force both to `fake`.

## Auth

Email and password, with a short JWT access token and a rotating refresh
token. Apple and Google are separate verifier classes in
`app/services/identity.py` and are not connected yet. If you add Google on
iOS, Apple's App Store rules also require Sign in with Apple.

## Tests

Postgres must be running (the `db` service is enough):

```bash
docker compose up -d db
python3.12 -m venv .venv
source .venv/bin/activate
pip install -e ".[dev]"
pytest
```

Tests create a `hilight_test` database and empty it between cases.

## Environment

See `.env.example`. You must set `JWT_SECRET`. The database password in the
example matches `docker-compose.yml` and is only for this local stack.
