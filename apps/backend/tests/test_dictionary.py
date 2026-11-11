from app.config import get_settings
from app.dictionary import FakeDictionaryProvider
from tests.conftest import auth, register


async def test_lookup_is_cached_and_validated(client):
    FakeDictionaryProvider.calls = 0
    ada = await register(client, "dict@example.com")
    body = {"word": "luminous", "source_language": "en", "target_language": "ru", "sentence": "A luminous page."}
    first = await client.post("/dictionary/lookup", json=body, headers=auth(ada))
    assert first.status_code == 200
    assert first.json()["cached"] is False
    assert first.json()["translation"] == "luminous (ru)"
    second = await client.post("/dictionary/lookup", json=body, headers=auth(ada))
    assert second.json()["cached"] is True
    assert FakeDictionaryProvider.calls == 1

    invalid = await client.post(
        "/dictionary/lookup",
        json={"word": "two words", "source_language": "en", "target_language": "en"},
        headers=auth(ada),
    )
    assert invalid.status_code == 422

    language = await client.post(
        "/dictionary/lookup",
        json={"word": "page", "source_language": "fr", "target_language": "en"},
        headers=auth(ada),
    )
    assert language.status_code == 422


async def test_dictionary_is_rate_limited(client):
    settings = get_settings()
    settings.dictionary_rate_limit = 1
    try:
        user = await register(client, "limit@example.com")
        body = {"word": "rate", "source_language": "en", "target_language": "en"}
        first = await client.post("/dictionary/lookup", json=body, headers=auth(user))
        second = await client.post("/dictionary/lookup", json=body, headers=auth(user))
        assert first.status_code == 200
        assert second.status_code == 429
    finally:
        settings.dictionary_rate_limit = 30
