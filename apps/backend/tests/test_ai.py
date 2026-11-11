from tests.conftest import auth, register


async def test_chat_and_rewrite_share_a_daily_limit(client):
    from app.config import get_settings

    settings = get_settings()
    settings.ai_daily_limit = 2
    try:
        user = await register(client, "tutor@example.com")
        headers = auth(user)
        chat = await client.post(
            "/ai/chat",
            json={"text": "The library stayed open.", "mode": "explain", "target_language": "en"},
            headers=headers,
        )
        assert chat.status_code == 200
        assert chat.json()["kind"] == "general"
        assert "library" in chat.json()["text"].lower()
        rewrite = await client.post(
            "/ai/rewrite",
            json={"sentence": "School is useful.", "task": "task2", "topic": "education"},
            headers=headers,
        )
        assert rewrite.status_code == 200
        assert "official IELTS score" in rewrite.json()["disclaimer"]
        assert len(rewrite.json()["versions"]) >= 2
        blocked = await client.post(
            "/ai/chat",
            json={"text": "Again.", "mode": "quiz"},
            headers=headers,
        )
        assert blocked.status_code == 429
    finally:
        settings.ai_daily_limit = 20


async def test_unknown_tutor_mode_is_rejected(client):
    user = await register(client, "mode@example.com")
    response = await client.post(
        "/ai/chat",
        json={"text": "Hello.", "mode": "score"},
        headers=auth(user),
    )
    assert response.status_code == 422
