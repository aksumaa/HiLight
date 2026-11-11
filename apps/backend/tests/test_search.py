from tests.conftest import auth, register


def _item(text: str) -> dict:
    return {"type": "note", "source": "manual", "text": text, "language": "en", "meta": {}}


async def test_meaning_search_stays_inside_one_account(client):
    ada = await register(client, "search-ada@example.com")
    grace = await register(client, "search-grace@example.com")
    await client.post("/items", json=_item("The old library stayed open after dark"), headers=auth(ada))
    await client.post("/items", json=_item("The tram was late"), headers=auth(ada))
    await client.post("/items", json=_item("The old library stayed open after dark"), headers=auth(grace))

    found = await client.post("/search", json={"query": "library open after dark", "limit": 5}, headers=auth(ada))
    assert found.status_code == 200
    hits = found.json()["hits"]
    assert hits
    assert "library" in hits[0]["text"]
    assert all("tram" not in hit["text"] or hits[0]["text"] != hit["text"] for hit in hits[:1])

    hidden = await client.post("/search", json={"query": "library"}, headers=auth(grace))
    assert hidden.status_code == 200
    assert all(hit["text"] != "The tram was late" for hit in hidden.json()["hits"])
    assert len(hidden.json()["hits"]) == 1
