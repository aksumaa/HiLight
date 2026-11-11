import hashlib
from uuid import UUID

from fastapi import Depends
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import Settings, get_settings
from app.db import get_session
from app.errors import AppError
from app.models import User
from app.security import decode_token

bearer = HTTPBearer(auto_error=False)


async def current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer),
    session: AsyncSession = Depends(get_session),
    settings: Settings = Depends(get_settings),
) -> User:
    if credentials is None or credentials.scheme.lower() != "bearer":
        raise AppError(401, "unauthorized", "Sign in required.")
    try:
        user_id = decode_token(settings, credentials.credentials, "access")
    except ValueError as exc:
        raise AppError(401, "unauthorized", "Sign in required.") from exc
    user = await session.get(User, user_id)
    if user is None:
        raise AppError(401, "unauthorized", "Sign in required.")
    return user


def token_hash(token: str) -> str:
    return hashlib.sha256(token.encode()).hexdigest()


async def require_owned_item(session: AsyncSession, user_id: UUID, item_id: UUID):
    from app.models import Item

    item = await session.scalar(select(Item).where(Item.id == item_id, Item.user_id == user_id))
    if item is None:
        raise AppError(404, "not_found", "Item not found.")
    return item
