from datetime import datetime
from typing import Literal
from uuid import UUID

from pydantic import BaseModel, EmailStr, Field


class ErrorBody(BaseModel):
    code: str
    message: str
    details: dict | list | None = None


class ErrorResponse(BaseModel):
    error: ErrorBody


class RegisterIn(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)


class LoginIn(BaseModel):
    email: EmailStr
    password: str = Field(min_length=1, max_length=128)


class RefreshIn(BaseModel):
    refresh_token: str


class TokenOut(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class UserOut(BaseModel):
    id: UUID
    email: EmailStr
    settings: dict


class SettingsIn(BaseModel):
    settings: dict = Field(default_factory=dict)


ItemType = Literal["quote", "voice", "note", "ai"]
ItemSource = Literal["scan", "voice", "manual", "device"]
Language = Literal["en", "ru", "uz"]


class ItemIn(BaseModel):
    id: UUID | None = None
    type: ItemType
    source: ItemSource
    text: str = Field(default="", max_length=20_000)
    page: int | None = Field(default=None, ge=1, le=20_000)
    language: Language
    audio_url: str | None = Field(default=None, max_length=2_000)
    image_url: str | None = Field(default=None, max_length=2_000)
    meta: dict = Field(default_factory=dict)
    updated_at: datetime | None = None


class ItemPatch(BaseModel):
    type: ItemType | None = None
    source: ItemSource | None = None
    text: str | None = Field(default=None, max_length=20_000)
    page: int | None = Field(default=None, ge=1, le=20_000)
    language: Language | None = None
    audio_url: str | None = Field(default=None, max_length=2_000)
    image_url: str | None = Field(default=None, max_length=2_000)
    meta: dict | None = None
    updated_at: datetime | None = None


class ItemOut(BaseModel):
    id: UUID
    type: str
    source: str
    text: str
    page: int | None
    language: str
    audio_url: str | None
    image_url: str | None
    meta: dict
    created_at: datetime
    updated_at: datetime
    deleted_at: datetime | None


class ItemPage(BaseModel):
    items: list[ItemOut]
    next_offset: int | None
    server_time: datetime


class CollectionIn(BaseModel):
    name: str = Field(min_length=1, max_length=200)


class CollectionOut(BaseModel):
    id: UUID
    name: str
    created_at: datetime
    updated_at: datetime


class TextOut(BaseModel):
    text: str
