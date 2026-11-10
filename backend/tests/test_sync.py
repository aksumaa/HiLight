from tests.conftest import auth, register


async def test_updated_since_and_last_write_wins(client):
    tokens = await register(client, "sync@example.com")
    headers = auth(tokens)
    created = await client.post(
        "/items",
        json={
            "type": "note",
            "source": "manual",
            "text": "first",
            "language": "ru",
            "updated_at": "2026-01-01T00:00:00Z",
        },
        headers=headers,
    )
    assert created.status_code == 201
    item = created.json()
    item_id = item["id"]

    stale = await client.patch(
        f"/items/{item_id}",
        json={"text": "stale", "updated_at": "2025-01-01T00:00:00Z"},
        headers=headers,
    )
    assert stale.status_code == 200
    assert stale.json()["text"] == "first"

    fresh = await client.patch(
        f"/items/{item_id}",
        json={"text": "second", "updated_at": "2026-06-01T00:00:00Z"},
        headers=headers,
    )
    assert fresh.status_code == 200
    assert fresh.json()["text"] == "second"

    cursor = item["updated_at"]
    changed = await client.get("/items", params={"updated_since": cursor}, headers=headers)
    assert changed.status_code == 200
    ids = [row["id"] for row in changed.json()["items"]]
    assert item_id in ids

    deleted = await client.delete(f"/items/{item_id}", headers=headers)
    assert deleted.status_code == 204

    visible = await client.get("/items", headers=headers)
    assert visible.json()["items"] == []

    tombstones = await client.get(
        "/items", params={"updated_since": "2026-01-01T00:00:00Z"}, headers=headers
    )
    match = [row for row in tombstones.json()["items"] if row["id"] == item_id]
    assert match and match[0]["deleted_at"] is not None
