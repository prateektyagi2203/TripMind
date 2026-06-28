# 007_TRANSLATOR_ENGINE.md

# Translator Engine

Version: 1.0

Status: Module Specification

------------------------------------------------------------------------

# Purpose

The Translator Engine enables seamless communication while traveling by
translating text, speech and images. It supports both online AI-powered
translation and offline language packs.

------------------------------------------------------------------------

# Responsibilities

-   Translate text
-   Translate speech
-   Translate camera images (OCR)
-   Support conversation mode
-   Work offline with downloaded language packs
-   Integrate with Trip Context

------------------------------------------------------------------------

# Business Rules

-   User selects source language or enables auto-detect.
-   Offline translation is used whenever possible.
-   Cloud translation is used only when required and permitted.

------------------------------------------------------------------------

# Features

## Text Translation

-   Type text
-   Paste text
-   Auto language detection
-   Copy translated text

## Camera Translation

-   Capture menu, sign or document
-   OCR extracts text
-   Translate into selected language
-   Overlay translated text (future)

## Voice Translation

-   Record speech
-   Convert speech to text
-   Translate
-   Display translated text
-   Optional text-to-speech playback

## Conversation Mode

Two-way conversation:

-   Traveler language
-   Local language

Supports alternating speakers.

------------------------------------------------------------------------

# Supported Modes

-   Online translation
-   Offline translation
-   OCR translation
-   Speech translation
-   Phrasebook (Destination Pack)

------------------------------------------------------------------------

# APIs

-   POST /translate/text
-   POST /translate/image
-   POST /translate/speech
-   GET /translate/languages

------------------------------------------------------------------------

# Database Tables

-   translation_history
-   downloaded_language_packs
-   favourite_phrases

------------------------------------------------------------------------

# Events

-   TranslationCompleted
-   LanguagePackDownloaded
-   OCRCompleted

------------------------------------------------------------------------

# Offline Behaviour

Available offline after downloading language packs:

-   Text translation
-   Phrasebook
-   OCR (device capabilities dependent)

Cloud-only enhancements are disabled gracefully.

------------------------------------------------------------------------

# Dependencies

-   Camera Engine
-   Trip Context Engine
-   Destination Packs
-   AI Model Strategy

------------------------------------------------------------------------

# Acceptance Criteria

-   Text translation \< 2 seconds online.
-   OCR translation available from captured image.
-   Offline language packs function without internet.
-   Conversation mode supports alternating speakers.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- ---------------------------
  1.0       Initial Translator Engine
