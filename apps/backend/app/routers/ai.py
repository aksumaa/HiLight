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
from app.models import AiUsage, Item, User
from app.rag import rank_notes

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


class NotesIn(BaseModel):
    title: str = Field(min_length=1, max_length=300)
    book_id: str = ""
    chapter: str = ""
    notes: list[str] = Field(default_factory=list, max_length=40)


class SummaryOut(BaseModel):
    text: str
    kind: str
    sources: list[str]
    remaining: int


class BookChatIn(NotesIn):
    question: str = Field(min_length=1, max_length=2000)


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


def _clip(notes: list[str]) -> list[str]:
    cleaned: list[str] = []
    for note in notes:
        text = note.strip()[:2000]
        if text and text not in cleaned:
            cleaned.append(text)
        if len(cleaned) == 40:
            break
    return cleaned


async def _book_notes(session: AsyncSession, user: User, book_id: str, chapter: str) -> list[str]:
    if not book_id:
        return []
    rows = await session.scalars(select(Item).where(Item.user_id == user.id, Item.deleted_at.is_(None)))
    notes: list[str] = []
    for row in rows:
        meta = row.meta or {}
        if str(meta.get("book_id") or "") != book_id:
            continue
        if chapter and str(meta.get("chapter") or "") not in {"", chapter}:
            continue
        if row.text:
            notes.append(row.text)
    return notes


@router.post("/summary", response_model=SummaryOut)
async def summary(
    body: NotesIn,
    user: User = Depends(current_user),
    session: AsyncSession = Depends(get_session),
    settings: Settings = Depends(get_settings),
) -> SummaryOut:
    notes = _clip([*body.notes, *await _book_notes(session, user, body.book_id, body.chapter)])
    chosen = notes[:8]
    remaining = await _charge(session, user, settings.ai_daily_limit)
    if not chosen:
        text = await ai_provider(settings).chat(f"There are no notes for {body.title}.", "explain", "en")
        return SummaryOut(text=text, kind="general", sources=[], remaining=remaining)
    chapter = f" Chapter: {body.chapter}." if body.chapter else ""
    prompt = f"Summarize these reading notes from {body.title}.{chapter}\n" + "\n".join(f"- {note}" for note in chosen)
    text = await ai_provider(settings).chat(prompt, "explain", "en")
    return SummaryOut(text=text, kind="from_notes", sources=chosen, remaining=remaining)


@router.post("/book-chat", response_model=SummaryOut)
async def book_chat(
    body: BookChatIn,
    user: User = Depends(current_user),
    session: AsyncSession = Depends(get_session),
    settings: Settings = Depends(get_settings),
) -> SummaryOut:
    notes = _clip([*body.notes, *await _book_notes(session, user, body.book_id, body.chapter)])
    chosen = rank_notes(body.question, notes, limit=5)
    remaining = await _charge(session, user, settings.ai_daily_limit)
    if not chosen:
        text = await ai_provider(settings).chat(body.question, "explain", "en")
        return SummaryOut(text=text, kind="general", sources=[], remaining=remaining)
    prompt = (
        "Answer from these notes only. If they do not say, say so.\n"
        + "\n".join(f"- {note}" for note in chosen)
        + f"\nQuestion: {body.question}"
    )
    text = await ai_provider(settings).chat(prompt, "explain", "en")
    return SummaryOut(text=text, kind="from_notes", sources=chosen, remaining=remaining)
