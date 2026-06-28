# 010_CAMERA_API.md

# Camera API

Version: 1.0

Status: Backend API Specification

------------------------------------------------------------------------

# Purpose

Defines REST endpoints for image analysis, OCR, landmark recognition and
receipt extraction.

------------------------------------------------------------------------

# Resource

`/camera`

------------------------------------------------------------------------

## POST /camera/analyze

Uploads an image for automatic content detection.

Detectable content:

-   Landmark
-   Receipt
-   Boarding pass
-   Hotel booking
-   Menu
-   Street sign

Returns detected document type and confidence.

------------------------------------------------------------------------

## POST /camera/ocr

Extracts text from an uploaded image.

Returns:

-   Raw text
-   Bounding boxes (future)
-   Language detection

------------------------------------------------------------------------

## POST /camera/landmark

Recognizes landmarks.

Returns:

-   Name
-   Description
-   Coordinates
-   Nearby attractions
-   Suggested visit duration

------------------------------------------------------------------------

## POST /camera/receipt

Extracts receipt information.

Returns:

-   Merchant
-   Amount
-   Currency
-   Tax
-   Date
-   Expense draft

------------------------------------------------------------------------

## POST /camera/boarding-pass

Extracts:

-   Airline
-   Flight number
-   Departure
-   Arrival
-   Seat
-   Gate
-   Boarding time

------------------------------------------------------------------------

# Response Schema

``` json
{
  "success": true,
  "data": {
    "document_type":"receipt",
    "confidence":0.98
  }
}
```

------------------------------------------------------------------------

# Validation

-   Supported image formats only.
-   Maximum image size enforced.
-   Authentication required.

------------------------------------------------------------------------

# Security

-   Uploaded images encrypted in transit.
-   Temporary processing storage only.
-   Sensitive documents never exposed to other users.

------------------------------------------------------------------------

# Acceptance Criteria

-   OCR accuracy \>95% on supported documents.
-   Landmark recognition completes in under 5 seconds.
-   Receipt extraction returns editable expense draft.
-   OpenAPI documentation generated.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- --------------------
  1.0       Initial Camera API
