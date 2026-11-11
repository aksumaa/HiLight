from fastapi import APIRouter, Depends
from pydantic import BaseModel, Field
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import Settings, get_settings
from app.db import get_session
from app.deps import current_user
from app.dictionary import dictionary_provider
from app.errors import AppError
from app.models import DictionaryCache, User
from app.rate_limit import limiter

router = APIRouter(prefix="/dictionary", tags=["dictionary"])

_LANGS = {"en", "ru", "uz"}


class LookupIn(BaseModel):
    word: str = Field(min_length=1, max_length=80)
    source_language: str
    target_language: str
    sentence: str | None = Field(default=None, max_length=2000)


class LookupOut(BaseModel):
    word: str
    translation: str
    definition: str
    example: str
    part_of_speech: str
    cached: bool


def _check_language(code: str) -> None:
    if code not in _LANGS:
        raise AppError(422, "validation_error", "Language must be en, ru, or uz.")


@router.post("/lookup", response_model=LookupOut)
async def lookup(
    body: LookupIn,
    user: User = Depends(current_user),
    session: AsyncSession = Depends(get_session),
    settings: Settings = Depends(get_settings),
) -> LookupOut:
    word = body.word.strip().lower()
    if not word or " " in word:
        raise AppError(422, "validation_error", "Look up one word.")
    _check_language(body.source_language)
    _check_language(body.target_language)
    limiter.hit(user.id, "dictionary", settings.dictionary_rate_limit, settings.dictionary_rate_window_seconds)
    cached = await session.scalar(
        select(DictionaryCache).where(
            DictionaryCache.word == word,
            DictionaryCache.source_language == body.source_language,
            DictionaryCache.target_language == body.target_language,
        )
    )
    if cached is not None:
        return LookupOut(
            word=cached.word,
            translation=cached.translation,
            definition=cached.definition,
            example=cached.example,
            part_of_speech=cached.part_of_speech,
            cached=True,
        )
    result = await dictionary_provider(settings).lookup(
        word, body.source_language, body.target_language, body.sentence
    )
    session.add(
        DictionaryCache(
            word=word,
            source_language=body.source_language,
            target_language=body.target_language,
            translation=result.translation,
            definition=result.definition,
            example=result.example,
            part_of_speech=result.part_of_speech,
        )
    )
    await session.commit()
    return LookupOut(
        word=result.word,
        translation=result.translation,
        definition=result.definition,
        example=result.example,
        part_of_speech=result.part_of_speech,
        cached=False,
    )
