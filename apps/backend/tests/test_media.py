from tests.conftest import auth, register


async def test_ocr_rejects_bad_language_and_large_files(client):
    tokens = await register(client, "ocr@example.com")
    headers = auth(tokens)
    bad = await client.post(
        "/ocr",
        headers=headers,
        data={"language": "fr"},
        files={"image": ("page.jpg", b"not-an-image", "image/jpeg")},
    )
    assert bad.status_code == 422
    assert bad.json()["error"]["code"] == "invalid_language"

    huge = await client.post(
        "/ocr",
        headers=headers,
        data={"language": "en"},
        files={"image": ("page.jpg", b"x" * (8_388_608 + 1), "image/jpeg")},
    )
    assert huge.status_code == 413
    assert huge.json()["error"]["code"] == "file_too_large"
