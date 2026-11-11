from app.embeddings import hash_embedding


def _cosine(left: list[float], right: list[float]) -> float:
    return sum(a * b for a, b in zip(left, right, strict=False))


def rank_notes(query: str, notes: list[str], limit: int = 5) -> list[str]:
    """Nearest notes by the local embedding. Empty overlap is left out."""

    vector = hash_embedding(query)
    scored: list[tuple[float, str]] = []
    for note in notes:
        text = note.strip()
        if not text:
            continue
        score = _cosine(vector, hash_embedding(text))
        if score > 0:
            scored.append((score, text))
    scored.sort(key=lambda row: row[0], reverse=True)
    seen: list[str] = []
    for _, text in scored:
        if text not in seen:
            seen.append(text)
        if len(seen) == limit:
            break
    return seen
