import json
from typing import Protocol

import httpx

from app.config import Settings
from app.errors import AppError

DISCLAIMER = "Practice feedback, not an official IELTS score."
_MODES = {"explain", "simplify", "translate", "grammar", "quiz"}


class AiProvider(Protocol):
    async def chat(self, text: str, mode: str, target_language: str) -> str: ...

    async def rewrite(self, sentence: str, task: str, topic: str) -> list[dict[str, str]]: ...


class FakeAiProvider:
    async def chat(self, text: str, mode: str, target_language: str) -> str:
        if mode == "simplify":
            return text.split(".")[0].strip() or text
        if mode == "translate":
            return f"{text} ({target_language})"
        if mode == "grammar":
            return "Look for the subject, the verb, and what the verb acts on."
        if mode == "quiz":
            words = text.split()
            if not words:
                return "Type a sentence first."
            hidden = words[-1]
            return f"Fill the gap: {' '.join(words[:-1])} _____. Missing word: {hidden}"
        return f"In plain words: {text}"

    async def rewrite(self, sentence: str, task: str, topic: str) -> list[dict[str, str]]:
        return [
            {
                "text": f"{sentence.rstrip('.')} because the point is easier to see.",
                "explanation": "Adds a reason, still in your own words.",
            },
            {
                "text": f"On {topic or 'this topic'}, {sentence[:1].lower() + sentence[1:] if sentence else sentence}",
                "explanation": f"Names the topic. This is for {task or 'practice'} only.",
            },
        ]


class LlmAiProvider:
    def __init__(self, settings: Settings) -> None:
        self._settings = settings

    async def chat(self, text: str, mode: str, target_language: str) -> str:
        if mode not in _MODES:
            raise AppError(422, "validation_error", "Unknown tutor mode.")
        content = await self._complete(
            "You are a language tutor. Do not give an official exam score. "
            f"Mode: {mode}. Target language: {target_language}. Reply in plain text.",
            text,
        )
        return content

    async def rewrite(self, sentence: str, task: str, topic: str) -> list[dict[str, str]]:
        content = await self._complete(
            "Return JSON {\"versions\": [{\"text\": \"\", \"explanation\": \"\"}]} with 2 or 3 "
            "clearer versions of the user's sentence. Do not give a band score or claim this is "
            "an official IELTS result.",
            json.dumps({"sentence": sentence, "task": task, "topic": topic}),
        )
        data = json.loads(content)
        versions = data.get("versions") or []
        return [
            {"text": str(row.get("text", "")), "explanation": str(row.get("explanation", ""))}
            for row in versions[:3]
            if isinstance(row, dict)
        ]

    async def _complete(self, system: str, user: str) -> str:
        key = self._settings.ai_api_key or self._settings.dictionary_api_key
        if not key:
            raise AppError(503, "ai_unconfigured", "AI_API_KEY is not set.")
        async with httpx.AsyncClient(timeout=30) as client:
            response = await client.post(
                f"{self._settings.dictionary_base_url.rstrip('/')}/chat/completions",
                headers={"Authorization": f"Bearer {key}"},
                json={
                    "model": self._settings.ai_model,
                    "messages": [
                        {"role": "system", "content": system},
                        {"role": "user", "content": user[:8000]},
                    ],
                },
            )
        if response.status_code >= 400:
            raise AppError(502, "ai_failed", "The tutor provider failed.")
        return response.json()["choices"][0]["message"]["content"]


def ai_provider(settings: Settings) -> AiProvider:
    if settings.ai_provider == "llm":
        return LlmAiProvider(settings)
    return FakeAiProvider()
