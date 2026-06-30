"""Authentication for TripMind.

Dev mode: `POST /api/auth/login` upserts a user by email and returns a token
that is simply the user id. Clients send it as `Authorization: Bearer <token>`.
This is intentionally simple so the create/join flow works end-to-end now; swap
`get_current_user` for real Google ID-token verification later (google-auth is
already a dependency).
"""
from __future__ import annotations

from fastapi import Depends, Header, HTTPException, status
from sqlmodel import Session, select

from .db import get_session
from .db_models import User
from .trip_schemas import LoginRequest


def login_or_create(req: LoginRequest, session: Session) -> User:
    email = req.email.strip().lower()
    user = session.exec(select(User).where(User.email == email)).first()
    if user is None:
        user = User(
            email=email,
            name=req.name.strip() or email.split("@")[0],
            photo_url=req.photo_url.strip(),
        )
        session.add(user)
        session.commit()
        session.refresh(user)
    elif req.name and user.name != req.name.strip():
        user.name = req.name.strip()
        session.add(user)
        session.commit()
        session.refresh(user)
    return user


def get_current_user(
    authorization: str = Header(default=""),
    session: Session = Depends(get_session),
) -> User:
    token = ""
    if authorization.lower().startswith("bearer "):
        token = authorization[7:].strip()
    if not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing bearer token.",
        )
    user = session.get(User, token)
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token.",
        )
    return user
