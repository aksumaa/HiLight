from uuid import UUID

from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db import get_session
from app.deps import current_user
from app.errors import AppError
from app.models import Collection, Item, ItemCollection, User
from app.schemas import CollectionIn, CollectionOut

router = APIRouter(prefix="/collections", tags=["collections"])


def _out(row: Collection) -> CollectionOut:
    return CollectionOut(id=row.id, name=row.name, created_at=row.created_at, updated_at=row.updated_at)


@router.get("", response_model=list[CollectionOut])
async def list_collections(
    user: User = Depends(current_user),
    session: AsyncSession = Depends(get_session),
) -> list[CollectionOut]:
    rows = await session.scalars(
        select(Collection).where(Collection.user_id == user.id).order_by(Collection.created_at.asc())
    )
    return [_out(row) for row in rows]


@router.post("", response_model=CollectionOut, status_code=201)
async def create_collection(
    body: CollectionIn,
    user: User = Depends(current_user),
    session: AsyncSession = Depends(get_session),
) -> CollectionOut:
    row = Collection(user_id=user.id, name=body.name.strip())
    session.add(row)
    await session.commit()
    await session.refresh(row)
    return _out(row)


@router.delete("/{collection_id}", status_code=204)
async def delete_collection(
    collection_id: UUID,
    user: User = Depends(current_user),
    session: AsyncSession = Depends(get_session),
) -> None:
    row = await session.scalar(
        select(Collection).where(Collection.id == collection_id, Collection.user_id == user.id)
    )
    if row is None:
        raise AppError(404, "not_found", "Collection not found.")
    await session.delete(row)
    await session.commit()


@router.post("/{collection_id}/items/{item_id}", status_code=204)
async def add_item(
    collection_id: UUID,
    item_id: UUID,
    user: User = Depends(current_user),
    session: AsyncSession = Depends(get_session),
) -> None:
    collection = await session.scalar(
        select(Collection).where(Collection.id == collection_id, Collection.user_id == user.id)
    )
    item = await session.scalar(select(Item).where(Item.id == item_id, Item.user_id == user.id))
    if collection is None or item is None:
        raise AppError(404, "not_found", "Collection or item not found.")
    existing = await session.scalar(
        select(ItemCollection).where(
            ItemCollection.collection_id == collection_id, ItemCollection.item_id == item_id
        )
    )
    if existing is None:
        session.add(ItemCollection(collection_id=collection_id, item_id=item_id))
        await session.commit()
