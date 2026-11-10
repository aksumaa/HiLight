from datetime import datetime, timezone
from uuid import UUID

from fastapi import APIRouter, Depends, Query
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db import get_session
from app.deps import current_user
from app.errors import AppError
from app.models import Item, User
from app.schemas import ItemIn, ItemOut, ItemPage, ItemPatch

router = APIRouter(prefix="/items", tags=["items"])


def _aware(value: datetime | None) -> datetime | None:
    if value is None:
        return None
    if value.tzinfo is None:
        return value.replace(tzinfo=timezone.utc)
    return value


def _out(item: Item) -> ItemOut:
    return ItemOut(
        id=item.id,
        type=item.type,
        source=item.source,
        text=item.text,
        page=item.page,
        language=item.language,
        audio_url=item.audio_url,
        image_url=item.image_url,
        meta=item.meta or {},
        created_at=item.created_at,
        updated_at=item.updated_at,
        deleted_at=item.deleted_at,
    )


def _apply(item: Item, body: ItemIn | ItemPatch, now: datetime) -> None:
    data = body.model_dump(exclude_unset=True)
    data.pop("id", None)
    client_time = _aware(data.pop("updated_at", None))
    for key, value in data.items():
        setattr(item, key, value)
    item.updated_at = client_time or now


async def _owned(session: AsyncSession, user_id: UUID, item_id: UUID) -> Item:
    item = await session.scalar(select(Item).where(Item.id == item_id, Item.user_id == user_id))
    if item is None:
        raise AppError(404, "not_found", "Item not found.")
    return item


@router.get("", response_model=ItemPage)
async def list_items(
    q: str | None = None,
    limit: int = Query(default=50, ge=1, le=100),
    offset: int = Query(default=0, ge=0),
    updated_since: datetime | None = None,
    user: User = Depends(current_user),
    session: AsyncSession = Depends(get_session),
) -> ItemPage:
    stmt = select(Item).where(Item.user_id == user.id)
    since = _aware(updated_since)
    if since is not None:
        stmt = stmt.where(Item.updated_at > since)
    else:
        stmt = stmt.where(Item.deleted_at.is_(None))
    if q:
        stmt = stmt.where(Item.text.ilike(f"%{q.replace('%', '')}%"))
    stmt = stmt.order_by(Item.updated_at.asc(), Item.id.asc()).offset(offset).limit(limit + 1)
    rows = list(await session.scalars(stmt))
    page = rows[:limit]
    next_offset = offset + limit if len(rows) > limit else None
    return ItemPage(
        items=[_out(row) for row in page],
        next_offset=next_offset,
        server_time=datetime.now(timezone.utc),
    )


@router.post("", response_model=ItemOut, status_code=201)
async def create_item(
    body: ItemIn,
    user: User = Depends(current_user),
    session: AsyncSession = Depends(get_session),
) -> ItemOut:
    now = datetime.now(timezone.utc)
    if body.id is not None:
        existing = await session.get(Item, body.id)
        if existing is not None and existing.user_id != user.id:
            raise AppError(409, "conflict", "That id is not available.")
        if existing is not None:
            client_time = _aware(body.updated_at)
            if client_time is not None and client_time < existing.updated_at:
                return _out(existing)
            _apply(existing, body, now)
            await session.commit()
            await session.refresh(existing)
            return _out(existing)
    item = Item(
        user_id=user.id,
        type=body.type,
        source=body.source,
        text=body.text,
        page=body.page,
        language=body.language,
        audio_url=body.audio_url,
        image_url=body.image_url,
        meta=body.meta,
        updated_at=_aware(body.updated_at) or now,
    )
    if body.id is not None:
        item.id = body.id
    session.add(item)
    await session.commit()
    await session.refresh(item)
    return _out(item)


@router.get("/{item_id}", response_model=ItemOut)
async def get_item(
    item_id: UUID,
    user: User = Depends(current_user),
    session: AsyncSession = Depends(get_session),
) -> ItemOut:
    return _out(await _owned(session, user.id, item_id))


@router.patch("/{item_id}", response_model=ItemOut)
async def patch_item(
    item_id: UUID,
    body: ItemPatch,
    user: User = Depends(current_user),
    session: AsyncSession = Depends(get_session),
) -> ItemOut:
    item = await _owned(session, user.id, item_id)
    client_time = _aware(body.updated_at)
    if client_time is not None and client_time < item.updated_at:
        return _out(item)
    _apply(item, body, datetime.now(timezone.utc))
    await session.commit()
    await session.refresh(item)
    return _out(item)


@router.delete("/{item_id}", status_code=204)
async def delete_item(
    item_id: UUID,
    user: User = Depends(current_user),
    session: AsyncSession = Depends(get_session),
) -> None:
    item = await _owned(session, user.id, item_id)
    now = datetime.now(timezone.utc)
    item.deleted_at = now
    item.updated_at = now
    await session.commit()
