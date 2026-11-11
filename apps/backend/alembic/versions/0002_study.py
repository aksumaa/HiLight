"""Books, vocabulary, cards, review logs, and dictionary cache."""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision: str = "0002_study"
down_revision: str | None = "0001_initial"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def _id() -> sa.Column:
    return sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True)


def _user() -> sa.Column:
    return sa.Column("user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False)


def _times() -> list[sa.Column]:
    return [
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("deleted_at", sa.DateTime(timezone=True)),
    ]


def upgrade() -> None:
    op.create_table(
        "dictionary_cache",
        _id(),
        sa.Column("word", sa.String(80), nullable=False),
        sa.Column("source_language", sa.String(8), nullable=False),
        sa.Column("target_language", sa.String(8), nullable=False),
        sa.Column("translation", sa.Text, nullable=False, server_default=""),
        sa.Column("definition", sa.Text, nullable=False, server_default=""),
        sa.Column("example", sa.Text, nullable=False, server_default=""),
        sa.Column("part_of_speech", sa.String(32), nullable=False, server_default=""),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.UniqueConstraint("word", "source_language", "target_language", name="uq_dictionary_lookup"),
    )
    op.create_table(
        "books",
        _id(),
        _user(),
        sa.Column("title", sa.String(300), nullable=False),
        sa.Column("author", sa.String(300)),
        sa.Column("cover_url", sa.Text),
        sa.Column("total_pages", sa.Integer),
        sa.Column("isbn", sa.String(20)),
        *_times(),
    )
    op.create_index("ix_books_user_id", "books", ["user_id"])
    op.create_table(
        "words",
        _id(),
        _user(),
        sa.Column("word", sa.String(80), nullable=False),
        sa.Column("source_language", sa.String(8), nullable=False),
        sa.Column("target_language", sa.String(8), nullable=False),
        sa.Column("translation", sa.Text, nullable=False, server_default=""),
        sa.Column("definition", sa.Text, nullable=False, server_default=""),
        sa.Column("example", sa.Text, nullable=False, server_default=""),
        sa.Column("part_of_speech", sa.String(32), nullable=False, server_default=""),
        sa.Column("source_sentence", sa.Text, nullable=False, server_default=""),
        sa.Column("source_item_id", sa.String(64)),
        sa.Column("tags", sa.String(200), nullable=False, server_default=""),
        sa.Column("mastery", sa.String(16), nullable=False, server_default="newWord"),
        *_times(),
    )
    op.create_index("ix_words_user_id", "words", ["user_id"])
    op.create_table(
        "study_cards",
        _id(),
        _user(),
        sa.Column("kind", sa.String(16), nullable=False),
        sa.Column("word_id", sa.String(64)),
        sa.Column("item_id", sa.String(64)),
        sa.Column("prompt", sa.Text, nullable=False, server_default=""),
        sa.Column("answer", sa.Text, nullable=False, server_default=""),
        sa.Column("ease", sa.Float, nullable=False, server_default="2.5"),
        sa.Column("interval_days", sa.Integer, nullable=False, server_default="0"),
        sa.Column("repetitions", sa.Integer, nullable=False, server_default="0"),
        sa.Column("due_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        *_times(),
    )
    op.create_index("ix_study_cards_user_id", "study_cards", ["user_id"])
    op.create_table(
        "review_logs",
        _id(),
        _user(),
        sa.Column("card_id", sa.String(64), nullable=False),
        sa.Column("rating", sa.Integer, nullable=False),
        sa.Column("interval_days", sa.Integer, nullable=False, server_default="0"),
        sa.Column("reviewed_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column("deleted_at", sa.DateTime(timezone=True)),
    )
    op.create_index("ix_review_logs_user_id", "review_logs", ["user_id"])


def downgrade() -> None:
    op.drop_table("review_logs")
    op.drop_table("study_cards")
    op.drop_table("words")
    op.drop_table("books")
    op.drop_table("dictionary_cache")
