# 009_TRANSLATOR_API.md

# Translator API

Version: 1.0

Status: Backend API Specification

------------------------------------------------------------------------

# Purpose

Defines REST endpoints for text, speech and image translation services.

------------------------------------------------------------------------

# Resource

`/translate`

------------------------------------------------------------------------

## POST /translate/text

Translates text.

### Request

``` json
{
  "source_language":"auto",
  "target_language":"en",
  "text":"สวัสดี"
}
```

------------------------------------------------------------------------

## POST /translate/image

Accepts OCR text or image reference and returns translated text.

------------------------------------------------------------------------

## POST /translate/speech

Accepts speech transcript or audio reference and returns translated
text.

------------------------------------------------------------------------

## GET /translate/languages

Returns supported language pairs and downloadable offline packs.

------------------------------------------------------------------------

## GET /translate/history

Returns translation history for the authenticated user.

------------------------------------------------------------------------

## DELETE /translate/history/{id}

Deletes a history item.

------------------------------------------------------------------------

# Response Schema

``` json
{
  "success": true,
  "data": {
    "translation":"Hello",
    "detected_language":"th"
  }
}
```

------------------------------------------------------------------------

# Validation

-   Target language required.
-   Empty text rejected.
-   Audio and image size limits enforced.

------------------------------------------------------------------------

# Security

-   JWT authentication required.
-   Uploaded media scanned and validated.
-   Translation history belongs only to the authenticated user.

------------------------------------------------------------------------

# Acceptance Criteria

-   Text translation \<2 seconds online.
-   Offline language packs discoverable.
-   History synchronized across devices.
-   OpenAPI documentation generated.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- ------------------------
  1.0       Initial Translator API
