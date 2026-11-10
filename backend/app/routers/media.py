from fastapi import APIRouter, Depends, File, Form, UploadFile

from app.config import Settings, get_settings
from app.deps import current_user
from app.errors import AppError
from app.models import User
from app.rate_limit import limiter
from app.schemas import TextOut
from app.services.ocr import build_ocr
from app.services.stt import build_stt, suffix_for

router = APIRouter(tags=["recognition"])


async def _read_limited(upload: UploadFile, max_bytes: int) -> bytes:
    data = await upload.read(max_bytes + 1)
    if len(data) > max_bytes:
        raise AppError(413, "file_too_large", "File is too large.")
    if not data:
        raise AppError(422, "empty_file", "File is empty.")
    return data


@router.post("/ocr", response_model=TextOut)
async def ocr(
    image: UploadFile = File(...),
    language: str = Form("en"),
    user: User = Depends(current_user),
    settings: Settings = Depends(get_settings),
) -> TextOut:
    limiter.hit(user.id, "ocr", settings.ocr_rate_limit, settings.ocr_rate_window_seconds)
    content_type = (image.content_type or "").lower()
    if content_type and not content_type.startswith("image/"):
        raise AppError(422, "invalid_image", "Upload an image file.")
    data = await _read_limited(image, settings.ocr_max_bytes)
    provider = build_ocr(settings.ocr_provider)
    text = await provider.recognize(data, language)
    return TextOut(text=text)


@router.post("/stt", response_model=TextOut)
async def stt(
    audio: UploadFile = File(...),
    language: str = Form("en"),
    user: User = Depends(current_user),
    settings: Settings = Depends(get_settings),
) -> TextOut:
    limiter.hit(user.id, "stt", settings.stt_rate_limit, settings.stt_rate_window_seconds)
    content_type = (audio.content_type or "").lower()
    allowed = content_type.startswith("audio/") or content_type in {
        "",
        "application/octet-stream",
        "video/mp4",
    }
    if not allowed:
        raise AppError(422, "invalid_audio", "Upload an audio file.")
    data = await _read_limited(audio, settings.stt_max_bytes)
    provider = build_stt(settings.stt_provider, settings.whisper_model, settings.whisper_device)
    text = await provider.transcribe(data, language, suffix_for(audio.filename, content_type))
    return TextOut(text=text)
