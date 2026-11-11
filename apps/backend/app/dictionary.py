import json
from typing import Protocol

import httpx

from app.config import Settings
from app.errors import AppError


class Lookup:
    def __init__(
        self,
        word: str,
        translation: str,
        definition: str,
        example: str,
        part_of_speech: str,
    ) -> None:
        self.word = word
        self.translation = translation
        self.definition = definition
        self.example = example
        self.part_of_speech = part_of_speech


class DictionaryProvider(Protocol):
    async def lookup(
        self, word: str, source_language: str, target_language: str, sentence: str | None
    ) -> Lookup: ...


class FakeDictionaryProvider:
    calls = 0

    async def lookup(
        self, word: str, source_language: str, target_language: str, sentence: str | None
    ) -> Lookup:
        FakeDictionaryProvider.calls += 1
        return Lookup(
            word=word,
            translation=f"{word} ({target_language})",
            definition=f"A definition of {word}.",
            example=sentence or f"This is {word}.",
            part_of_speech="noun",
        )


class LlmDictionaryProvider:
    """One short chat completion per cache miss. The key stays in the environment."""

    def __init__(self, settings: Settings) -> None:
        self._settings = settings

    async def lookup(
        self, word: str, source_language: str, target_language: str, sentence: str | None
    ) -> Lookup:
        if not self._settings.dictionary_api_key:
            raise AppError(503, "dictionary_unconfigured", "DICTIONARY_API_KEY is not set.")
        prompt = {
            "word": word,
            "source_language": source_language,
            "target_language": target_language,
            "sentence": sentence or "",
        }
        async with httpx.AsyncClient(timeout=20) as client:
            response = await client.post(
                f"{self._settings.dictionary_base_url.rstrip('/')}/chat/completions",
                headers={"Authorization": f"Bearer {self._settings.dictionary_api_key}"},
                json={
                    "model": self._settings.dictionary_model,
                    "response_format": {"type": "json_object"},
                    "messages": [
                        {
                            "role": "system",
                            "content": (
                                "Return JSON with translation, definition, example, part_of_speech. "
                                "Translate into the requested target language."
                            ),
                        },
                        {"role": "user", "content": json.dumps(prompt)},
                    ],
                },
            )
        if response.status_code >= 400:
            raise AppError(502, "dictionary_failed", "The dictionary provider failed.")
        content = response.json()["choices"][0]["message"]["content"]
        data = json.loads(content)
        return Lookup(
            word=word,
            translation=str(data.get("translation", "")),
            definition=str(data.get("definition", "")),
            example=str(data.get("example", "")),
            part_of_speech=str(data.get("part_of_speech", "")),
        )


def dictionary_provider(settings: Settings) -> DictionaryProvider:
    if settings.dictionary_provider == "llm":
        return LlmDictionaryProvider(settings)
    return FakeDictionaryProvider()
