from datetime import datetime, timezone
from typing import Any
from uuid import UUID

from fastapi import APIRouter, Depends, Query
from pydantic import BaseModel, Field
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db import get_session
from app.deps import current_user
from app.errors import AppError
from app.models import Book, ReviewLog, StudyCard, User, Word

router = APIRouter(tags=["study"])


def _aware(value: datetime | None) -> datetime | None:
    if value is None:
        return None
    if value.tzinfo is None:
        return value.replace(tzinfo=timezone.utc)
    return value


class BookIn(BaseModel):
    title: str = Field(min_length=1, max_length=300)
    author: str | None = None
    cover_url: str | None = None
    total_pages: int | None = Field(default=None, ge=1, le=20000)
    isbn: str | None = Field(default=None, max_length=20)
    updated_at: datetime | None = None
    deleted_at: datetime | None = None


class WordIn(BaseModel):
    word: str = Field(min_length=1, max_length=80)
    source_language: str = Field(max_length=8)
    target_language: str = Field(max_length=8)
    translation: str = ""
    definition: str = ""
    example: str = ""
    part_of_speech: str = ""
    source_sentence: str = ""
    source_item_id: str | None = None
    tags: str = ""
    mastery: str = "newWord"
    updated_at: datetime | None = None
    deleted_at: datetime | None = None


class CardIn(BaseModel):
    kind: str = Field(max_length=16)
    word_id: str | None = None
    item_id: str | None = None
    prompt: str = ""
    answer: str = ""
    ease: float = 2.5
    interval_days: int = 0
    repetitions: int = 0
    due_at: datetime | None = None
    updated_at: datetime | None = None
    deleted_at: datetime | None = None


class ReviewLogIn(BaseModel):
    card_id: str = Field(max_length=64)
    rating: int = Field(ge=0, le=5)
    interval_days: int = 0
    reviewed_at: datetime | None = None
    updated_at: datetime | None = None
    deleted_at: datetime | None = None


def _dump(row: Any) -> dict:
    data = {}
    for column in row.__table__.columns:
        if column.name == "user_id":
            continue
        value = getattr(row, column.name)
        if isinstance(value, datetime):
            value = value.isoformat()
        elif isinstance(value, UUID):
            value = str(value)
        data[column.name] = value
    return data


async def _upsert(session: AsyncSession, model: type, user: User, row_id: UUID, body: BaseModel):
    existing = await session.scalar(select(model).where(model.id == row_id, model.user_id == user.id))
    now = datetime.now(timezone.utc)
    data = body.model_dump()
    client_time = _aware(data.pop("updated_at", None)) or now
    if existing is not None and existing.updated_at and _aware(existing.updated_at) > client_time:
        return existing
    target = existing or model(id=row_id, user_id=user.id)
    for key, value in data.items():
        if isinstance(value, datetime):
            value = _aware(value)
        setattr(target, key, value)
    target.updated_at = client_time
    if existing is None:
        if getattr(target, "created_at", None) is None:
            target.created_at = client_time
        session.add(target)
    await session.commit()
    await session.refresh(target)
    return target


async def _list(session: AsyncSession, model: type, user: User, updated_since: datetime | None, limit: int, offset: int):
    stmt = select(model).where(model.user_id == user.id)
    since = _aware(updated_since)
    if since is not None:
        stmt = stmt.where(model.updated_at > since)
    else:
        stmt = stmt.where(model.deleted_at.is_(None))
    stmt = stmt.order_by(model.updated_at.asc()).offset(offset).limit(limit + 1)
    rows = list(await session.scalars(stmt))
    page = rows[:limit]
    return {
        "items": [_dump(row) for row in page],
        "next_offset": offset + limit if len(rows) > limit else None,
        "server_time": datetime.now(timezone.utc).isoformat(),
    }


def _routes(path: str, model: type, body_type: type[BaseModel]) -> None:
    bound = model

    async def upsert(
        row_id: UUID,
        body: body_type,
        user: User = Depends(current_user),
        session: AsyncSession = Depends(get_session),
    ) -> dict:
        row = await _upsert(session, bound, user, row_id, body)
        return _dump(row)

    async def one(
        row_id: UUID,
        user: User = Depends(current_user),
        session: AsyncSession = Depends(get_session),
    ) -> dict:
        row = await session.scalar(select(bound).where(bound.id == row_id, bound.user_id == user.id))
        if row is None or row.deleted_at is not None:
            raise AppError(404, "not_found", "Not found.")
        return _dump(row)

    async def listing(
        updated_since: datetime | None = None,
        limit: int = Query(default=100, ge=1, le=100),
        offset: int = Query(default=0, ge=0),
        user: User = Depends(current_user),
        session: AsyncSession = Depends(get_session),
    ) -> dict:
        return await _list(session, bound, user, updated_since, limit, offset)

    router.put(f"/{path}/{{row_id}}", name=f"upsert_{path}")(upsert)
    router.get(f"/{path}/{{row_id}}", name=f"get_{path}_one")(one)
    router.get(f"/{path}", name=f"list_{path}")(listing)


_routes("books", Book, BookIn)
_routes("words", Word, WordIn)
_routes("cards", StudyCard, CardIn)
_routes("review-logs", ReviewLog, ReviewLogIn)
