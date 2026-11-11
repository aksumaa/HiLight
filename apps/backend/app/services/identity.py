"""Sign-in providers.

Password is implemented. Apple and Google verify an identity token and return
a stable subject. They are not wired to a live client yet.

App Store rule: if the iOS app offers Google (or any other third-party login),
it must also offer Sign in with Apple.
"""

from dataclasses import dataclass
from typing import Protocol


@dataclass(frozen=True)
class ExternalProfile:
    provider: str
    subject: str
    email: str | None


class ExternalIdentityVerifier(Protocol):
    provider: str

    async def verify(self, identity_token: str) -> ExternalProfile: ...


class AppleIdentityVerifier:
    provider = "apple"

    async def verify(self, identity_token: str) -> ExternalProfile:
        raise NotImplementedError("Sign in with Apple is not configured.")


class GoogleIdentityVerifier:
    provider = "google"

    async def verify(self, identity_token: str) -> ExternalProfile:
        raise NotImplementedError("Google sign-in is not configured.")
