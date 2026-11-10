import time
from collections import defaultdict, deque
from uuid import UUID

from app.errors import AppError


class RateLimiter:
    """In-process window. One API replica; a second process has its own counters."""

    def __init__(self) -> None:
        self._hits: dict[tuple[str, str], deque[float]] = defaultdict(deque)

    def hit(self, user_id: UUID, bucket: str, limit: int, window_seconds: int) -> None:
        key = (str(user_id), bucket)
        now = time.monotonic()
        queue = self._hits[key]
        cutoff = now - window_seconds
        while queue and queue[0] < cutoff:
            queue.popleft()
        if len(queue) >= limit:
            raise AppError(429, "rate_limited", f"Too many {bucket} requests. Try again shortly.")
        queue.append(now)


limiter = RateLimiter()
