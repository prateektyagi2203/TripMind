# 007_RESTAURANTS_API.md

# Restaurants API

Version: 1.0

Status: Backend API Specification

------------------------------------------------------------------------

# Purpose

Defines REST endpoints for restaurant discovery, favourites and
recommendations.

------------------------------------------------------------------------

# Resource

`/restaurants`

------------------------------------------------------------------------

## GET /restaurants/nearby

Returns nearby restaurants.

### Query Parameters

-   latitude
-   longitude
-   radius
-   cuisine
-   vegetarian
-   family_friendly
-   open_now
-   page
-   page_size

------------------------------------------------------------------------

## GET /restaurants/{restaurantId}

Returns detailed restaurant information.

Includes:

-   Name
-   Address
-   Cuisine
-   Rating
-   Opening hours
-   Coordinates
-   AI recommendation reason

------------------------------------------------------------------------

## POST /restaurants/favourites

Adds a restaurant to favourites.

### Request

``` json
{
  "restaurant_id":"uuid"
}
```

------------------------------------------------------------------------

## DELETE /restaurants/favourites/{restaurantId}

Removes a favourite.

------------------------------------------------------------------------

## GET /restaurants/favourites

Returns saved restaurants.

------------------------------------------------------------------------

## POST /restaurants/recommend

Returns personalized recommendations using:

-   Trip Context
-   Travel DNA
-   Budget
-   Family size
-   Time of day

------------------------------------------------------------------------

# Response Schema

``` json
{
  "success":true,
  "data":{
    "restaurants":[]
  }
}
```

------------------------------------------------------------------------

# Validation

-   Coordinates required for nearby search.
-   Radius limited to configured maximum.
-   Authentication required.

------------------------------------------------------------------------

# Events

-   RestaurantRecommended
-   FavouriteAdded
-   FavouriteRemoved

------------------------------------------------------------------------

# Security

JWT authentication required.

------------------------------------------------------------------------

# Acceptance Criteria

-   Nearby search \<2 seconds.
-   Cached results supported.
-   Personalized recommendations available.
-   OpenAPI documentation generated.

------------------------------------------------------------------------

# Revision History

  Version   Description
  --------- -------------------------
  1.0       Initial Restaurants API
