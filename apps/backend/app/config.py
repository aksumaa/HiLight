from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    database_url: str = "postgresql+asyncpg://hilight:hilight@localhost:5432/hilight"
    jwt_secret: str = "dev-only-change-me"
    jwt_access_minutes: int = 15
    jwt_refresh_days: int = 30
    ocr_provider: str = "tesseract"
    stt_provider: str = "whisper"
    whisper_model: str = "base"
    whisper_device: str = "cpu"
    ocr_max_bytes: int = 8_388_608
    stt_max_bytes: int = 26_214_400
    ocr_rate_limit: int = 10
    ocr_rate_window_seconds: int = 60
    stt_rate_limit: int = 6
    stt_rate_window_seconds: int = 60
    # fake (tests and offline) or llm (OpenAI-compatible chat completions)
    dictionary_provider: str = "fake"
    dictionary_api_key: str = ""
    dictionary_base_url: str = "https://api.openai.com/v1"
    dictionary_model: str = "gpt-4o-mini"
    dictionary_rate_limit: int = 30
    dictionary_rate_window_seconds: int = 60
    # fake or llm. llm uses AI_API_KEY, or DICTIONARY_API_KEY if that is empty.
    ai_provider: str = "fake"
    ai_api_key: str = ""
    ai_model: str = "gpt-4o-mini"
    ai_daily_limit: int = 20
    # hash is free. openai uses text-embedding-3-small shortened to 384 dims.
    embedding_provider: str = "hash"
    embedding_model: str = "text-embedding-3-small"


@lru_cache
def get_settings() -> Settings:
    return Settings()
