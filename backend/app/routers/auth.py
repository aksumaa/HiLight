from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import Settings, get_settings
from app.db import get_session
from app.deps import token_hash
from app.errors import AppError
from app.models import Identity, RefreshToken, User
from app.schemas import LoginIn, RefreshIn, RegisterIn, TokenOut
from app.security import access_token, decode_token, hash_password, refresh_token, verify_password

router = APIRouter(prefix="/auth", tags=["auth"])


async def _issue(session: AsyncSession, settings: Settings, user: User) -> TokenOut:
    access = access_token(settings, user.id)
    refresh = refresh_token(settings, user.id)
    session.add(
        RefreshToken(
            user_id=user.id,
            token_hash=token_hash(refresh),
            expires_at=datetime.now(timezone.utc) + timedelta(days=settings.jwt_refresh_days),
        )
    )
    await session.commit()
    return TokenOut(access_token=access, refresh_token=refresh)


@router.post("/register", response_model=TokenOut, status_code=201)
async def register(
    body: RegisterIn,
    session: AsyncSession = Depends(get_session),
    settings: Settings = Depends(get_settings),
) -> TokenOut:
    existing = await session.scalar(select(User).where(User.email == body.email.lower()))
    if existing is not None:
        raise AppError(409, "email_taken", "An account with this email already exists.")
    user = User(email=body.email.lower(), password_hash=hash_password(body.password), settings={})
    session.add(user)
    await session.flush()
    session.add(Identity(user_id=user.id, provider="password", subject=user.email))
    await session.commit()
    await session.refresh(user)
    return await _issue(session, settings, user)


@router.post("/login", response_model=TokenOut)
async def login(
    body: LoginIn,
    session: AsyncSession = Depends(get_session),
    settings: Settings = Depends(get_settings),
) -> TokenOut:
    user = await session.scalar(select(User).where(User.email == body.email.lower()))
    if user is None or not user.password_hash or not verify_password(body.password, user.password_hash):
        raise AppError(401, "invalid_credentials", "Email or password is wrong.")
    return await _issue(session, settings, user)


@router.post("/refresh", response_model=TokenOut)
async def refresh(
    body: RefreshIn,
    session: AsyncSession = Depends(get_session),
    settings: Settings = Depends(get_settings),
) -> TokenOut:
    try:
        user_id = decode_token(settings, body.refresh_token, "refresh")
    except ValueError as exc:
        raise AppError(401, "unauthorized", "Refresh token is invalid.") from exc
    stored = await session.scalar(
        select(RefreshToken).where(RefreshToken.token_hash == token_hash(body.refresh_token))
    )
    now = datetime.now(timezone.utc)
    if stored is None or stored.user_id != user_id or stored.expires_at <= now:
        raise AppError(401, "unauthorized", "Refresh token is invalid.")
    await session.delete(stored)
    user = await session.get(User, user_id)
    if user is None:
        raise AppError(401, "unauthorized", "Refresh token is invalid.")
    return await _issue(session, settings, user)
