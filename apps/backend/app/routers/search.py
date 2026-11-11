from uuid import UUID

from fastapi import APIRouter, Depends
from pydantic import BaseModel, Field
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import Settings, get_settings
from app.db import get_session
from app.deps import current_user
from app.embeddings import embed_text
from app.models import Item, User

router = APIRouter(tags=["search"])


class SearchIn(BaseModel):
    query: str = Field(min_length=1, max_length=500)
    limit: int = Field(default=8, ge=1, le=20)


class SearchHit(BaseModel):
    id: UUID
    text: str
    score: float


class SearchOut(BaseModel):
    hits: list[SearchHit]


@router.post("/search", response_model=SearchOut)
async def search(
    body: SearchIn,
    user: User = Depends(current_user),
    session: AsyncSession = Depends(get_session),
    settings: Settings = Depends(get_settings),
) -> SearchOut:
    missing = list(
        await session.scalars(
            select(Item)
            .where(Item.user_id == user.id, Item.deleted_at.is_(None), Item.embedding.is_(None))
            .limit(20)
        )
    )
    if missing:
        for row in missing:
            row.embedding = await embed_text(row.text or "", settings)
        await session.commit()
    query_vector = await embed_text(body.query, settings)
    distance = Item.embedding.cosine_distance(query_vector)
    rows = list(
        await session.execute(
            select(Item, distance.label("distance"))
            .where(Item.user_id == user.id, Item.deleted_at.is_(None), Item.embedding.is_not(None))
            .order_by(distance)
            .limit(body.limit)
        )
    )
    return SearchOut(
        hits=[
            SearchHit(id=item.id, text=item.text, score=max(0.0, 1.0 - float(dist or 1)))
            for item, dist in rows
            if dist is not None and float(dist) < 0.999
        ]
    )
