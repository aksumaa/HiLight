from tests.conftest import auth, register


def _item(text: str) -> dict:
    return {"type": "quote", "source": "manual", "text": text, "language": "en", "meta": {"tag": "book"}}


async def test_users_cannot_see_each_others_items(client):
    ada = await register(client, "ada@example.com")
    grace = await register(client, "grace@example.com")

    created = await client.post("/items", json=_item("Ada's sentence"), headers=auth(ada))
    assert created.status_code == 201
    item_id = created.json()["id"]

    hidden = await client.get(f"/items/{item_id}", headers=auth(grace))
    assert hidden.status_code == 404

    listing = await client.get("/items", headers=auth(grace))
    assert listing.status_code == 200
    assert listing.json()["items"] == []

    stolen = await client.patch(
        f"/items/{item_id}", json={"text": "changed"}, headers=auth(grace)
    )
    assert stolen.status_code == 404

    ada_list = await client.get("/items", headers=auth(ada))
    assert ada_list.json()["items"][0]["text"] == "Ada's sentence"

    search = await client.get("/items", params={"q": "sentence"}, headers=auth(ada))
    assert len(search.json()["items"]) == 1
