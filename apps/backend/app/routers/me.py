from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.db import get_session
from app.deps import current_user
from app.errors import AppError
from app.models import User
from app.schemas import SettingsIn, UserOut

router = APIRouter(prefix="/me", tags=["me"])


def _user_out(user: User) -> UserOut:
    return UserOut(id=user.id, email=user.email, settings=user.settings or {})


@router.get("", response_model=UserOut)
async def me(user: User = Depends(current_user)) -> UserOut:
    return _user_out(user)


@router.get("/settings", response_model=UserOut)
async def get_settings(user: User = Depends(current_user)) -> UserOut:
    return _user_out(user)


@router.patch("/settings", response_model=UserOut)
async def patch_settings(
    body: SettingsIn,
    user: User = Depends(current_user),
    session: AsyncSession = Depends(get_session),
) -> UserOut:
    encoded = str(body.settings)
    if len(encoded) > 16_000:
        raise AppError(422, "validation_error", "Settings are too large.")
    user.settings = body.settings
    await session.commit()
    await session.refresh(user)
    return _user_out(user)
