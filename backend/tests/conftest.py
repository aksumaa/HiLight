import os

import asyncpg
import pytest
from httpx import ASGITransport, AsyncClient
from sqlalchemy import text
from sqlalchemy.ext.asyncio import create_async_engine

os.environ.setdefault("JWT_SECRET", "test-secret")
os.environ["OCR_PROVIDER"] = "fake"
os.environ["STT_PROVIDER"] = "fake"
TEST_URL = os.environ.get(
    "TEST_DATABASE_URL",
    "postgresql+asyncpg://hilight:hilight@localhost:5432/hilight_test",
)
os.environ["DATABASE_URL"] = TEST_URL

from app.config import get_settings  # noqa: E402

get_settings.cache_clear()

from app.db import engine  # noqa: E402
from app.main import create_app  # noqa: E402
from app.models import Base  # noqa: E402


def _asyncpg_url(url: str) -> str:
    return url.replace("postgresql+asyncpg://", "postgresql://")


async def _ensure_database() -> None:
    url = _asyncpg_url(TEST_URL)
    database = url.rsplit("/", 1)[-1]
    admin = url.rsplit("/", 1)[0] + "/postgres"
    conn = await asyncpg.connect(admin)
    try:
        exists = await conn.fetchval("SELECT 1 FROM pg_database WHERE datname = $1", database)
        if not exists:
            await conn.execute(f'CREATE DATABASE "{database}"')
    finally:
        await conn.close()


@pytest.fixture(scope="session")
async def _schema():
    await _ensure_database()
    setup = create_async_engine(TEST_URL)
    async with setup.begin() as conn:
        await conn.execute(text("CREATE EXTENSION IF NOT EXISTS vector"))
        await conn.run_sync(Base.metadata.drop_all)
        await conn.run_sync(Base.metadata.create_all)
    await setup.dispose()
    yield
    await engine.dispose()


@pytest.fixture
async def client(_schema):
    async with engine.begin() as conn:
        for table in reversed(Base.metadata.sorted_tables):
            await conn.execute(table.delete())
    app = create_app()
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as http:
        yield http


async def register(client: AsyncClient, email: str, password: str = "password123") -> dict:
    response = await client.post("/auth/register", json={"email": email, "password": password})
    assert response.status_code == 201, response.text
    return response.json()


def auth(tokens: dict) -> dict:
    return {"Authorization": f"Bearer {tokens['access_token']}"}
