from tests.conftest import auth, register


async def test_register_login_and_refresh(client):
    tokens = await register(client, "ada@example.com")
    me = await client.get("/me", headers=auth(tokens))
    assert me.status_code == 200
    assert me.json()["email"] == "ada@example.com"

    bad = await client.post("/auth/login", json={"email": "ada@example.com", "password": "nope-nope"})
    assert bad.status_code == 401
    assert bad.json()["error"]["code"] == "invalid_credentials"

    logged_in = await client.post(
        "/auth/login", json={"email": "ada@example.com", "password": "password123"}
    )
    assert logged_in.status_code == 200

    refreshed = await client.post("/auth/refresh", json={"refresh_token": tokens["refresh_token"]})
    assert refreshed.status_code == 200
    assert refreshed.json()["access_token"]

    reused = await client.post("/auth/refresh", json={"refresh_token": tokens["refresh_token"]})
    assert reused.status_code == 401

    duplicate = await client.post(
        "/auth/register", json={"email": "ada@example.com", "password": "password123"}
    )
    assert duplicate.status_code == 409


async def test_short_password_is_rejected(client):
    response = await client.post("/auth/register", json={"email": "short@example.com", "password": "short"})
    assert response.status_code == 422
    assert response.json()["error"]["code"] == "validation_error"
