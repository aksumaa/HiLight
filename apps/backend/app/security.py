from datetime import datetime, timedelta, timezone
from uuid import UUID, uuid4

import bcrypt
import jwt

from app.config import Settings


def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()


def verify_password(password: str, password_hash: str) -> bool:
    return bcrypt.checkpw(password.encode(), password_hash.encode())


def _encode(settings: Settings, user_id: UUID, kind: str, ttl: timedelta) -> str:
    now = datetime.now(timezone.utc)
    payload = {
        "sub": str(user_id),
        "typ": kind,
        "jti": str(uuid4()),
        "iat": int(now.timestamp()),
        "exp": int((now + ttl).timestamp()),
    }
    return jwt.encode(payload, settings.jwt_secret, algorithm="HS256")


def access_token(settings: Settings, user_id: UUID) -> str:
    return _encode(settings, user_id, "access", timedelta(minutes=settings.jwt_access_minutes))


def refresh_token(settings: Settings, user_id: UUID) -> str:
    return _encode(settings, user_id, "refresh", timedelta(days=settings.jwt_refresh_days))


def decode_token(settings: Settings, token: str, expected_type: str) -> UUID:
    try:
        payload = jwt.decode(token, settings.jwt_secret, algorithms=["HS256"])
    except jwt.PyJWTError as exc:
        raise ValueError("invalid token") from exc
    if payload.get("typ") != expected_type:
        raise ValueError("wrong token type")
    return UUID(payload["sub"])
