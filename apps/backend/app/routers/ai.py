from datetime import datetime, timezone

from fastapi import APIRouter, Depends
from pydantic import BaseModel, Field
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.ai_provider import DISCLAIMER, ai_provider
from app.config import Settings, get_settings
from app.db import get_session
from app.deps import current_user
from app.errors import AppError
from app.models import AiUsage, User

router = APIRouter(prefix="/ai", tags=["ai"])
_MODES = {"explain", "simplify", "translate", "grammar", "quiz"}


class ChatIn(BaseModel):
    text: str = Field(min_length=1, max_length=8000)
    mode: str
    target_language: str = "en"


class ChatOut(BaseModel):
    mode: str
    text: str
    kind: str
    remaining: int
    disclaimer: str


class RewriteIn(BaseModel):
    sentence: str = Field(min_length=1, max_length=2000)
    task: str = ""
    topic: str = ""


class RewriteVersion(BaseModel):
    text: str
    explanation: str


class RewriteOut(BaseModel):
    disclaimer: str
    versions: list[RewriteVersion]
    remaining: int


async def _charge(session: AsyncSession, user: User, limit: int) -> int:
    today = datetime.now(timezone.utc).date()
    row = await session.scalar(select(AiUsage).where(AiUsage.user_id == user.id, AiUsage.used_on == today))
    if row is None:
        row = AiUsage(user_id=user.id, used_on=today, count=0)
        session.add(row)
        await session.flush()
    if row.count >= limit:
        raise AppError(429, "daily_limit", f"The daily tutor limit is {limit}.")
    row.count += 1
    await session.commit()
    return limit - row.count


@router.post("/chat", response_model=ChatOut)
async def chat(
    body: ChatIn,
    user: User = Depends(current_user),
    session: AsyncSession = Depends(get_session),
    settings: Settings = Depends(get_settings),
) -> ChatOut:
    if body.mode not in _MODES:
        raise AppError(422, "validation_error", "Mode must be explain, simplify, translate, grammar, or quiz.")
    if body.target_language not in {"en", "ru", "uz"}:
        raise AppError(422, "validation_error", "Language must be en, ru, or uz.")
    remaining = await _charge(session, user, settings.ai_daily_limit)
    text = await ai_provider(settings).chat(body.text.strip(), body.mode, body.target_language)
    return ChatOut(mode=body.mode, text=text, kind="general", remaining=remaining, disclaimer=DISCLAIMER)


@router.post("/rewrite", response_model=RewriteOut)
async def rewrite(
    body: RewriteIn,
    user: User = Depends(current_user),
    session: AsyncSession = Depends(get_session),
    settings: Settings = Depends(get_settings),
) -> RewriteOut:
    remaining = await _charge(session, user, settings.ai_daily_limit)
    versions = await ai_provider(settings).rewrite(body.sentence.strip(), body.task.strip(), body.topic.strip())
    return RewriteOut(
        disclaimer=DISCLAIMER,
        versions=[RewriteVersion(**row) for row in versions if row.get("text")],
        remaining=remaining,
    )
