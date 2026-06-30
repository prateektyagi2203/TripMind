"""SQLite persistence for TripMind (users, trips, members, destinations, journeys).

Uses SQLModel (SQLAlchemy core) with a local file DB `tripmind.db` so trips and
memberships survive backend restarts. Easy to point at Postgres later by changing
DATABASE_URL.
"""
from __future__ import annotations

import os
from collections.abc import Iterator

from sqlalchemy import text
from sqlmodel import Session, SQLModel, create_engine

_DB_PATH = os.getenv(
    "DATABASE_URL",
    f"sqlite:///{os.path.join(os.path.dirname(os.path.dirname(__file__)), 'tripmind.db')}",
)

# check_same_thread=False lets FastAPI's threadpool share the connection.
engine = create_engine(_DB_PATH, echo=False, connect_args={"check_same_thread": False})


def init_db() -> None:
    """Create all tables. Import db_models so they register with SQLModel.metadata."""
    from . import db_models  # noqa: F401

    SQLModel.metadata.create_all(engine)
    _migrate_journey_columns()


# Columns added after the initial release. SQLite's create_all does not ALTER
# existing tables, so we add any missing columns idempotently here.
_JOURNEY_ADDED_COLUMNS = {
    "flight_number": "TEXT DEFAULT ''",
    "status": "TEXT DEFAULT ''",
    "status_note": "TEXT DEFAULT ''",
    "departure_terminal": "TEXT DEFAULT ''",
    "departure_gate": "TEXT DEFAULT ''",
    "arrival_terminal": "TEXT DEFAULT ''",
    "arrival_gate": "TEXT DEFAULT ''",
    "scheduled_departure": "TEXT DEFAULT ''",
    "estimated_departure": "TEXT DEFAULT ''",
    "scheduled_arrival": "TEXT DEFAULT ''",
    "estimated_arrival": "TEXT DEFAULT ''",
    "status_checked_at": "TEXT DEFAULT ''",
}


def _migrate_journey_columns() -> None:
    with engine.begin() as conn:
        rows = conn.execute(text("PRAGMA table_info(journeys)")).fetchall()
        existing = {r[1] for r in rows}
        for col, ddl in _JOURNEY_ADDED_COLUMNS.items():
            if col not in existing:
                conn.execute(text(f"ALTER TABLE journeys ADD COLUMN {col} {ddl}"))



def get_session() -> Iterator[Session]:
    """FastAPI dependency yielding a DB session."""
    with Session(engine) as session:
        yield session
