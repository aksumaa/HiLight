from uuid import uuid4

from tests.conftest import auth, register


async def test_books_words_cards_and_logs_are_per_user(client):
    ada = await register(client, "shelf-ada@example.com")
    grace = await register(client, "shelf-grace@example.com")
    book_id = str(uuid4())
    created = await client.put(
        f"/books/{book_id}",
        json={"title": "Ada's book", "author": "A. Reader", "total_pages": 120},
        headers=auth(ada),
    )
    assert created.status_code == 200
    hidden = await client.get(f"/books/{book_id}", headers=auth(grace))
    assert hidden.status_code == 404
    listing = await client.get("/books", headers=auth(grace))
    assert listing.json()["items"] == []
    ada_list = await client.get("/books", headers=auth(ada))
    assert ada_list.json()["items"][0]["title"] == "Ada's book"

    deleted = await client.put(
        f"/books/{book_id}",
        json={"title": "Ada's book", "deleted_at": "2099-01-01T00:00:00Z", "updated_at": "2099-01-01T00:00:00Z"},
        headers=auth(ada),
    )
    assert deleted.status_code == 200
    gone = await client.get("/books", headers=auth(ada))
    assert gone.json()["items"] == []

    word_id = str(uuid4())
    word = await client.put(
        f"/words/{word_id}",
        json={"word": "luminous", "source_language": "en", "target_language": "ru", "translation": "yorqin"},
        headers=auth(ada),
    )
    assert word.status_code == 200
    assert (await client.get("/words", headers=auth(grace))).json()["items"] == []

    card_id = str(uuid4())
    card = await client.put(
        f"/cards/{card_id}",
        json={"kind": "word", "prompt": "luminous", "answer": "yorqin", "word_id": word_id},
        headers=auth(ada),
    )
    assert card.status_code == 200
    assert (await client.get("/cards", headers=auth(grace))).json()["items"] == []

    log_id = str(uuid4())
    log = await client.put(
        f"/review-logs/{log_id}",
        json={"card_id": card_id, "rating": 4, "interval_days": 1},
        headers=auth(ada),
    )
    assert log.status_code == 200
    assert (await client.get("/review-logs", headers=auth(grace))).json()["items"] == []
