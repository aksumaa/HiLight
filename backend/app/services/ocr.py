import asyncio
import io
from typing import Protocol

from PIL import Image, UnidentifiedImageError

from app.errors import AppError

_TESS_LANG = {"en": "eng", "ru": "rus", "uz": "uzb"}


class OcrProvider(Protocol):
    async def recognize(self, data: bytes, language: str) -> str: ...


class FakeOcr:
    async def recognize(self, data: bytes, language: str) -> str:
        return f"fake ocr {language}"


class TesseractOcr:
    """Local Tesseract. No per-page fee.

    Expected packs: eng (English), rus (Russian), uzb (Uzbek Latin).
    uzb quality on phone photos of books is uneven; I have not verified it
    against real pages. Cyrillic Uzbek is not this pack.
    """

    async def recognize(self, data: bytes, language: str) -> str:
        lang = _TESS_LANG.get(language)
        if lang is None:
            raise AppError(422, "unsupported_language", "Language must be en, ru, or uz.")
        return await asyncio.to_thread(self._read, data, lang)

    def _read(self, data: bytes, lang: str) -> str:
        try:
            import pytesseract
        except ImportError as exc:
            raise AppError(500, "ocr_unavailable", "Tesseract bindings are not installed.") from exc
        try:
            image = Image.open(io.BytesIO(data))
            image.load()
        except UnidentifiedImageError as exc:
            raise AppError(422, "invalid_image", "The file is not an image.") from exc
        try:
            text = pytesseract.image_to_string(image, lang=lang)
        except pytesseract.TesseractError as exc:
            raise AppError(500, "ocr_failed", "Tesseract could not read this image.") from exc
        return text.strip()


def build_ocr(name: str) -> OcrProvider:
    if name == "fake":
        return FakeOcr()
    if name == "tesseract":
        return TesseractOcr()
    raise AppError(500, "ocr_unavailable", f"Unknown OCR provider {name}.")
