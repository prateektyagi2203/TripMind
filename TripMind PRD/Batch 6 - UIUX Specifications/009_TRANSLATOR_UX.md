# 009_TRANSLATOR_UX.md

# Translator UX Specification

Version: 1.0

Status: UI/UX Specification

------------------------------------------------------------------------

# Purpose

The Translator screen enables travelers to communicate effortlessly
using text, voice and camera translation. It is designed for quick,
one-handed use in real-world travel situations.

------------------------------------------------------------------------

# UX Goals

-   Translate within two taps
-   Support offline language packs
-   Minimize typing
-   Integrate camera and microphone
-   Keep translated text easy to share

------------------------------------------------------------------------

# Screen Layout

    --------------------------------------------------
    Language Selector
    --------------------------------------------------
    Mode Tabs
     Text | Voice | Camera | Conversation
    --------------------------------------------------
    Translation Area
    --------------------------------------------------
    Action Buttons
    --------------------------------------------------
    History
    --------------------------------------------------
    Bottom Navigation
    --------------------------------------------------

------------------------------------------------------------------------

# Language Selector

Displays:

-   Source language
-   Target language
-   Auto Detect
-   Swap languages

------------------------------------------------------------------------

# Text Mode

Features:

-   Text input
-   Paste
-   Copy result
-   Favorite phrases
-   Share translation
-   Speak translation

------------------------------------------------------------------------

# Voice Mode

Workflow:

1.  Tap microphone
2.  Speak
3.  Speech-to-text
4.  Translate
5.  Optional speech playback

Shows confidence score when available.

------------------------------------------------------------------------

# Camera Mode

Capture:

-   Menus
-   Street signs
-   Tickets
-   Receipts
-   Hotel information

Workflow:

Camera → OCR → Translation → Editable Result

Future: - Live translation overlay

------------------------------------------------------------------------

# Conversation Mode

Two large buttons:

-   Traveler
-   Local Speaker

Supports alternating speech with translated transcript.

------------------------------------------------------------------------

# Translation History

Stores:

-   Original text
-   Translation
-   Date
-   Language pair
-   Favorite status

------------------------------------------------------------------------

# Offline Behaviour

Available offline:

-   Downloaded language packs
-   Phrasebook
-   Text translation
-   Camera OCR (device dependent)

Cloud enhancements resume automatically online.

------------------------------------------------------------------------

# Flutter Widgets

-   TabBar
-   TextField
-   IconButton
-   CameraPreview
-   ListView
-   FloatingActionButton
-   BottomSheet

------------------------------------------------------------------------

# Acceptance Criteria

-   Translation starts within 1 second.
-   Offline packs work without internet.
-   Camera translation requires no manual cropping for common documents.
-   Conversation mode supports rapid speaker switching.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- -----------------------
  1.0       Initial Translator UX
