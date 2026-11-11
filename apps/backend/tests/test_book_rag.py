from tests.conftest import auth, register


async def test_book_chat_uses_the_matching_note_only(client):
    user = await register(client, "rag@example.com")
    headers = auth(user)
    await client.post(
        "/items",
        json={
            "type": "quote",
            "source": "manual",
            "text": "The old library stayed open after dark",
            "language": "en",
            "meta": {"book_id": "book-1"},
        },
        headers=headers,
    )
    await client.post(
        "/items",
        json={
            "type": "quote",
            "source": "manual",
            "text": "The tram was late",
            "language": "en",
            "meta": {"book_id": "book-1"},
        },
        headers=headers,
    )
    other = await register(client, "rag-other@example.com")
    hidden = await client.post(
        "/ai/book-chat",
        json={"title": "Field Guide", "book_id": "book-1", "question": "When did the library stay open?"},
        headers=auth(other),
    )
    assert hidden.status_code == 200
    assert hidden.json()["kind"] == "general"

    found = await client.post(
        "/ai/book-chat",
        json={"title": "Field Guide", "book_id": "book-1", "question": "library open after dark"},
        headers=headers,
    )
    assert found.status_code == 200
    body = found.json()
    assert body["kind"] == "from_notes"
    assert body["sources"][0] == "The old library stayed open after dark"
    assert "tram" not in body["sources"][0]

    summary = await client.post(
        "/ai/summary",
        json={"title": "Field Guide", "book_id": "book-1", "chapter": ""},
        headers=headers,
    )
    assert summary.status_code == 200
    assert summary.json()["kind"] == "from_notes"
    assert summary.json()["sources"]