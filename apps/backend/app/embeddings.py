import hashlib
import math

import httpx

from app.config import Settings


def hash_embedding(text: str) -> list[float]:
    """384-d token hash. Free, and the same idea as the mobile meaning search."""

    vector = [0.0] * 384
    for raw in text.lower().replace("'", " ").split():
        token = "".join(char for char in raw if char.isalpha() or char == "'")
        if not token:
            continue
        digest = hashlib.sha256(token.encode()).digest()
        index = int.from_bytes(digest[:2], "big") % 384
        sign = 1.0 if digest[2] % 2 == 0 else -1.0
        vector[index] += sign
    norm = math.sqrt(sum(value * value for value in vector))
    if norm == 0:
        return vector
    return [value / norm for value in vector]


async def embed_text(text: str, settings: Settings) -> list[float]:
    key = settings.ai_api_key or settings.dictionary_api_key
    if settings.embedding_provider == "openai" and key:
        try:
            return await _openai_embedding(text, settings, key)
        except (httpx.HTTPError, KeyError, ValueError):
            return hash_embedding(text)
    return hash_embedding(text)


async def _openai_embedding(text: str, settings: Settings, key: str) -> list[float]:
    async with httpx.AsyncClient(timeout=20) as client:
        response = await client.post(
            f"{settings.dictionary_base_url.rstrip('/')}/embeddings",
            headers={"Authorization": f"Bearer {key}"},
            json={"model": settings.embedding_model, "input": text[:8000], "dimensions": 384},
        )
    response.raise_for_status()
    vector = response.json()["data"][0]["embedding"]
    if len(vector) != 384:
        raise ValueError("Embedding length must be 384.")
    return [float(value) for value in vector]
