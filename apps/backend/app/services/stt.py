import asyncio
import tempfile
from pathlib import Path
from typing import Protocol

from app.errors import AppError


class SttProvider(Protocol):
    async def transcribe(self, data: bytes, language: str, suffix: str) -> str: ...


class FakeStt:
    async def transcribe(self, data: bytes, language: str, suffix: str) -> str:
        return f"fake stt {language}"


class WhisperStt:
    """Local faster-whisper. No per-minute API fee. The base model is the default
    because it is small enough to run on a laptop CPU.

    Whisper's trained languages include English and Russian. Uzbek is not one
    of those languages, so uz transcription may be poor or detected as another
    language. I have not verified Uzbek audio against this model.
    """

    def __init__(self, model_name: str, device: str) -> None:
        self._model_name = model_name
        self._device = device
        self._model = None

    async def transcribe(self, data: bytes, language: str, suffix: str) -> str:
        if language not in {"en", "ru", "uz"}:
            raise AppError(422, "unsupported_language", "Language must be en, ru, or uz.")
        return await asyncio.to_thread(self._read, data, language, suffix)

    def _read(self, data: bytes, language: str, suffix: str) -> str:
        model = self._load()
        # Passing uz makes Whisper look for a language it was not trained on.
        whisper_language = None if language == "uz" else language
        with tempfile.NamedTemporaryFile(suffix=suffix or ".m4a") as handle:
            handle.write(data)
            handle.flush()
            segments, _info = model.transcribe(handle.name, language=whisper_language)
            return " ".join(segment.text.strip() for segment in segments).strip()

    def _load(self):
        if self._model is not None:
            return self._model
        try:
            from faster_whisper import WhisperModel
        except ImportError as exc:
            raise AppError(
                500,
                "stt_unavailable",
                "Install the whisper extra: pip install '.[whisper]'.",
            ) from exc
        self._model = WhisperModel(self._model_name, device=self._device, compute_type="int8")
        return self._model


def build_stt(name: str, model_name: str, device: str) -> SttProvider:
    if name == "fake":
        return FakeStt()
    if name == "whisper":
        return WhisperStt(model_name, device)
    raise AppError(500, "stt_unavailable", f"Unknown STT provider {name}.")


def suffix_for(filename: str | None, content_type: str | None) -> str:
    if filename and Path(filename).suffix:
        return Path(filename).suffix.lower()
    if content_type and "wav" in content_type:
        return ".wav"
    if content_type and "mpeg" in content_type:
        return ".mp3"
    return ".m4a"
