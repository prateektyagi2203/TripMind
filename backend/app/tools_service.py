"""Tools service: small GPT-4o helpers for the Tools screens (e.g. Translator).

Reuses the Concierge's lazy OpenAI client so it works with OR without a key.
Without a key it returns a tiny built-in phrasebook fallback.
"""
from __future__ import annotations

from .concierge_service import _get_client, _model
from .models import TranslateResponse

# Minimal offline phrasebook (English -> Thai) used when no OpenAI key is set.
_FALLBACK_THAI: dict[str, tuple[str, str]] = {
    "hello": ("สวัสดี", "sa-wat-dee"),
    "thank you": ("ขอบคุณ", "khop-khun"),
    "how much is this?": ("อันนี้ราคาเท่าไหร่", "an-nee raa-kaa tao-rai"),
    "where is the bathroom?": ("ห้องน้ำอยู่ที่ไหน", "hong-naam yoo tee-nai"),
    "two waters, no ice please": ("ขอน้ำสองขวด ไม่ใส่น้ำแข็ง", "kor naam song-kuat mai sai naam-khaeng"),
}


async def translate(text: str, target_lang: str) -> TranslateResponse:
    client = _get_client()
    if client is None:
        key = text.strip().lower().rstrip("?.! ")
        for phrase, (thai, pron) in _FALLBACK_THAI.items():
            if key == phrase.rstrip("?.! "):
                return TranslateResponse(
                    translated=thai, pronunciation=pron, source="fallback"
                )
        return TranslateResponse(
            translated=f"[{target_lang}] {text}",
            pronunciation="",
            source="fallback",
        )

    prompt = (
        f"Translate the following text into {target_lang}. "
        f"Respond with ONLY two lines:\n"
        f"Line 1: the translation in the target script.\n"
        f"Line 2: a simple romanized pronunciation (or '-' if not applicable).\n\n"
        f"Text: {text}"
    )
    try:
        res = await client.chat.completions.create(
            model=_model(),
            messages=[{"role": "user", "content": prompt}],
            temperature=0.2,
            max_tokens=120,
        )
        content = (res.choices[0].message.content or "").strip()
        lines = [ln.strip() for ln in content.splitlines() if ln.strip()]
        translated = lines[0] if lines else text
        pronunciation = lines[1] if len(lines) > 1 and lines[1] != "-" else ""
        return TranslateResponse(
            translated=translated, pronunciation=pronunciation, source="ai"
        )
    except Exception:
        return TranslateResponse(
            translated=f"[{target_lang}] {text}", pronunciation="", source="fallback"
        )
