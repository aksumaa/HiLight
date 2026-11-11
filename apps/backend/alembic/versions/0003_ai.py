"""Daily tutor usage counter."""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision: str = "0003_ai"
down_revision: str | None = "0002_study"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "ai_usage",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("used_on", sa.Date, nullable=False),
        sa.Column("count", sa.Integer, nullable=False, server_default="0"),
        sa.UniqueConstraint("user_id", "used_on", name="uq_ai_usage_day"),
    )
    op.create_index("ix_ai_usage_user_id", "ai_usage", ["user_id"])


def downgrade() -> None:
    op.drop_index("ix_ai_usage_user_id", table_name="ai_usage")
    op.drop_table("ai_usage")
