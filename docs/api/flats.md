# Staykin flats API (section 07 · Move in to a flat flow)

Spec for the five screens in the "Move in to a flat" flow: Flats Tab list, Flat Detail, Flatmate Profile sheet, Enquire sheet, Filter sheet. Source of truth for iOS request payloads is `Staykin/Features/Flats/` (to be added).

> **Status:** All canonical lists below are **iOS-proposed** — no backend echo yet. The list-row schema (`type`, `locality`, `rent`, `score`, `amenities[]`) was normalised in the latest design and explicitly tagged as "pickable from API"; this doc takes that as the canonical shape.

## Contents

- [Overview](#overview)
- [Auth & headers](#auth--headers)
- [Endpoints](#endpoints)
  - [1. List flats](#1-list-flats)
  - [2. Get flat detail](#2-get-flat-detail)
  - [3. Submit enquiry](#3-submit-enquiry)
  - [4. Filter options metadata](#4-filter-options-metadata-optional)
- [Canonical reference lists](#canonical-reference-lists)
  - [Flat type](#flat-type)
  - [Amenities](#amenities)
  - [Sort options](#sort-options)
  - [Application mode](#application-mode)
- [Photo handling](#photo-handling)
- [Match score](#match-score)
- [Wire-format invariants](#wire-format-invariants)
- [Open items](#open-items)

---

## Overview

Five screens; three of them are bottom sheets (Flatmate, Enquire, Filter). Net of the photos, the data fits four endpoints:

| Endpoint | Used by |
|---|---|
| `GET /flats` | Flats Tab list (Screen 23b), Filter Sheet (re-fetches with new params) |
| `GET /flats/:id` | Flat Detail (Screen 26) |
| `POST /enquiries` | Enquire Sheet (Screen 27) |
| `GET /flats/filter-options` *(optional)* | Filter Sheet — dynamic options |

Flatmate profile data (Screens 26b/c) is **embedded** inside `GET /flats/:id` rather than a separate endpoint. If you'd rather keep them separate, see [Open items](#open-items).

## Auth & headers

```
Content-Type: application/json
Authorization: Bearer <jwt>      // from /auth/verify-otp
```

Match scores are personalised, so every endpoint here requires the user JWT.

---

## Endpoints

### 1. List flats

```http
GET /flats?<query>
```

#### Query parameters

| Param | Type | Default | Notes |
|---|---|---|---|
| `city` | string | `gurgaon` | v1 hardcoded; backend can omit and infer from user. |
| `type[]` | int[] | — | Filter by [flat type](#flat-type) ids. Empty = all. |
| `areas[]` | int[] | — | `Area.id` values from onboarding canon. |
| `rent_min` | int (INR) | `5000` | |
| `rent_max` | int (INR) | `50000` | |
| `bhk[]` | int[] | — | `BHK.id` values. |
| `amenities[]` | int[] | — | `Amenity.id` values — see [Amenities](#amenities). |
| `verified_only` | bool | `false` | Maps to "Verified" filter chip. |
| `available_now` | bool | `false` | Maps to "Available now" filter chip. |
| `sort` | int | `1` (best match) | `SortOption.id` — see [Sort options](#sort-options). |
| `limit` | int | `20` | Page size. |
| `offset` | int | `0` | Pagination offset. |

#### Success — 200 OK

```json
{
  "total": 248,
  "items": [
    {
      "id":         101,
      "type":       1,
      "locality":   "DLF Phase 1",
      "rent":       18000,
      "score":      92,
      "amenities":  [1, 2, 5],
      "photo_url":  "https://cdn.staykin.app/flats/101/thumb.jpg",
      "verified":   true,
      "available_now": true
    }
  ]
}
```

| Field | Type | Notes |
|---|---|---|
| `total` | int | total matching count (drives "248 flats in your vibe" header) |
| `items[].id` | int | flat id |
| `items[].type` | int | [flat type id](#flat-type) — title row |
| `items[].locality` | string | short area name (e.g. "DLF Phase 1") — second line |
| `items[].rent` | int (INR) | monthly rent |
| `items[].score` | int 0–100 | match % for **this user** |
| `items[].amenities` | int[] | top amenities to surface in the row (≤ 4 recommended) |
| `items[].photo_url` | string | thumbnail; full gallery loads in detail |
| `items[].verified` | bool | drives ✓ Verified badge if rendered |
| `items[].available_now` | bool | drives ⚡ chip |

---

### 2. Get flat detail

```http
GET /flats/:id
```

#### Success — 200 OK

```json
{
  "id":         101,
  "type":       1,
  "locality":   "DLF Phase 1",
  "address_line": "5th floor, Skylark Apartments",
  "rent":       45000,
  "bhk":        3,
  "furnishing": 1,
  "area_sqft":  1450,
  "verified":   true,
  "available_now": true,
  "score":      92,

  "photos": [
    { "id": 1, "url": "https://cdn.staykin.app/flats/101/p1.jpg" },
    { "id": 2, "url": "https://cdn.staykin.app/flats/101/p2.jpg" },
    { "id": 3, "url": "https://cdn.staykin.app/flats/101/p3.jpg" },
    { "id": 4, "url": "https://cdn.staykin.app/flats/101/p4.jpg" }
  ],

  "amenities": [1, 2, 3, 4, 5, 6, 7, 8],

  "flatmates": [
    {
      "id":        21,
      "name":      "Aarav",
      "age":       26,
      "role":      "POSTER",
      "job":       "Product @ Razorpay",
      "avatar_url": null,
      "emoji":     "🦊",
      "match_pct": 79,
      "vibe_prefs": [7, 4, 2, 6, 9, 3],
      "bio":       "your friendly neighbourhood PM…",
      "looking_for": [
        { "label": "Move-in",  "value": "1 May 2026" },
        { "label": "Lease",    "value": "11 months min" },
        { "label": "Vibe",     "value": "Chill, working pros" }
      ]
    }
  ],

  "combined_match": {
    "score":       83,
    "summary":     "Strong vibe",
    "participants": ["You", "Aarav", "Priya"]
  },

  "slots": {
    "total":  3,
    "filled": 2,
    "open":   1
  },

  "private_room": {
    "rent_share": 15000,
    "available_now": true
  },

  "about": "Spacious 3BHK in a quiet society with sunlit balconies…"
}
```

| Field | Type | Notes |
|---|---|---|
| `bhk` | int | `BHK.id` |
| `furnishing` | int | `Furnishing.id` |
| `area_sqft` | int | square feet (display only) |
| `score` | int | personalised match for the **flat** (used in row + hero) |
| `photos[]` | object[] | hero gallery — at least 1 |
| `amenities[]` | int[] | full amenity list (no cap, vs the truncated row list) |
| `flatmates[].role` | enum string | `POSTER` / `FLATMATE` / `HOST` — drives the sheet badge |
| `flatmates[].vibe_prefs` | int[] | `VibePref.id` values — used to render the chips on their VibeCard |
| `flatmates[].looking_for` | array | display-only key/value rows; backend formats values |
| `combined_match.score` | int 0–100 | "you + the existing flatmates" hero meter |
| `slots.open` | int | drives "1 spot left" + the dashed empty-row CTA |
| `private_room.rent_share` | int | rent share for the empty slot ("₹15K share · avail now") |

---

### 3. Submit enquiry

```http
POST /enquiries
```

```json
{
  "flat_id":   101,
  "mode":      1,
  "squad_id":  null,
  "move_in":   1,
  "message":   "Hey! Interested in the flat. My vibe…"
}
```

| Field | Type | Required | Notes |
|---|---|---|---|
| `flat_id` | int | yes | the flat being applied to |
| `mode` | int | yes | `ApplicationMode.id` — see [Application mode](#application-mode) |
| `squad_id` | int | conditional | required when `mode == 2` (Squad), else `null` |
| `move_in` | int | yes | `MoveInTimeline.id` (reuses onboarding canon) |
| `move_in_date` | ISO date | conditional | only when client picked a custom date instead of a preset; backend can ignore in v1 |
| `message` | string | yes | trimmed; backend should cap at ~500 chars |

**Success — 201 Created**
```json
{
  "id":          5012,
  "status":      "SENT",
  "flat_id":     101,
  "submitted_at":"2026-05-07T11:42:18Z"
}
```

**Errors**
- `409 already_enquired` — user has an open enquiry on this flat
- `410 flat_unavailable` — slot just filled / flat de-listed

---

### 4. Filter options metadata *(optional)*

If backend wants to drive the filter sheet from the server (so we can add new amenities or sort options without an iOS release):

```http
GET /flats/filter-options
```

```json
{
  "amenities": [
    { "id": 1, "value": "WIFI",     "label": "WiFi",     "emoji": "📶" }
  ],
  "sort_options": [
    { "id": 1, "value": "BEST_MATCH",   "label": "Best match" }
  ],
  "rent_range": { "min": 5000, "max": 50000, "step": 1000 }
}
```

If backend doesn't want this endpoint, the canonical lists below are baked into the iOS client.

---

## Canonical reference lists

> ⚠ All lists below are **iOS-proposed**, awaiting backend confirmation.

### Flat type

From the design's normalised schema comment in `vp-flat.jsx`. Used by the list row title and the "Private Room / Shared Room" filter chips.

| id | value | label |
|---:|---|---|
| 1 | `PRIVATE_ROOM` | Private Room |
| 2 | `SHARED_ROOM` | Shared Room |

### Amenities

Drawn from the Flat Detail amenities pill grid + list-row partial amenities text.

| id | value | label | emoji |
|---:|---|---|:---:|
| 1 | `WIFI` | WiFi | 📶 |
| 2 | `AC` | AC | ❄️ |
| 3 | `GEYSER` | Geyser | 🔥 |
| 4 | `WASHER` | Washing machine | 🧺 |
| 5 | `CCTV` | CCTV | 📹 |
| 6 | `PARKING` | Parking | 🅿️ |
| 7 | `LIFT` | Lift | 🛗 |
| 8 | `GYM` | Gym | 💪 |
| 9 | `FURNISHED` | Furnished | 🛋 |
| 10 | `ATTACHED_BATH` | Attached bath | 🛁 |
| 11 | `POOL` | Pool | 🏊 |
| 12 | `WFH_READY` | WFH ready | 💻 |
| 13 | `BALCONY` | Balcony | 🪴 |

> Emojis are iOS-side display only, same convention as `VibePref`. Backend stores `id` + `value` + `label`. Add to / re-order this list freely; iOS will sync.

### Sort options

Drives the "↓ Best match" affordance and the sort row in the Filter sheet.

| id | value | label |
|---:|---|---|
| 1 | `BEST_MATCH` | Best match |
| 2 | `PRICE_LOW_TO_HIGH` | Price (low → high) |
| 3 | `PRICE_HIGH_TO_LOW` | Price (high → low) |
| 4 | `NEWEST` | Newest |
| 5 | `MOST_POPULAR` | Most popular |

### Application mode

From the Solo / Squad toggle on the Enquire sheet.

| id | value | label |
|---:|---|---|
| 1 | `SOLO` | Solo |
| 2 | `SQUAD` | Squad |

When `mode == 2`, the client also sends `squad_id`. Squad creation flow is owned by another team (section 06) — for v1 of this section, treat squad as an unsupported mode if the user doesn't have one and gate the toggle.

---

## Photo handling

- The list endpoint returns one `photo_url` (thumbnail).
- The detail endpoint returns a `photos[]` array — minimum 1, no max for now (gallery shows the first 4–6).
- All URLs are CDN-hosted; client doesn't upload flat photos in this section (that's section 08).
- Suggest sizing variants: backend can serve `?w=400` style query params, or ship `thumb_url` + `full_url` per photo. Either works for client.

## Match score

`score` (0–100) on flats and `match_pct` on flatmates are **personalised per request** based on the authenticated user's vibe prefs.

- Backend computes — client doesn't.
- The `combined_match.score` on flat detail factors in the user **plus** all existing flatmates.
- A score of `null` (e.g., user hasn't completed onboarding's vibe-prefs step) should be tolerated by the client and rendered as "—" instead of a percentage.

---

## Wire-format invariants

(Same rules as `docs/api/onboarding.md`.)

- Every selectable option (flat type, amenities, sort, application mode, BHK, furnishing, move-in, areas, vibe prefs) is sent as **`id` (integer)**, never `value` or `label`.
- IDs are 1-indexed and stable. Backend must never renumber existing items — only append.
- Multi-select fields are `int[]`; single-select are plain `int`.
- All text fields trimmed before send.
- Money is integer rupees (no paise, no decimals, no currency symbol).
- Dates are ISO-8601 UTC strings.
- Booleans are JSON `true`/`false` (not `0`/`1`).

## Standard error envelope

(Same as `docs/api/onboarding.md`.)

```json
{
  "error":   "validation_failed",
  "message": "Invalid request body",
  "details": [
    { "field": "rent_min", "code": "below_minimum", "message": "must be ≥ 5000" }
  ]
}
```

| HTTP | Error code | Meaning |
|---:|---|---|
| 400 | `validation_failed` | bad query / body |
| 401 | `unauthorized` | missing / expired / invalid token |
| 404 | `flat_not_found` | unknown flat id |
| 409 | `already_enquired` | open enquiry exists for this flat |
| 410 | `flat_unavailable` | flat de-listed / no open slots |
| 429 | `rate_limited` | enquiry/list throttled |

---

## Open items

1. **All canonical lists** (Flat type, Amenities, Sort options, Application mode) — confirm or revise.
2. **Embed vs separate flatmates** — current spec embeds flatmates in `GET /flats/:id`. If the same flatmate could appear across multiple flats, separating into `GET /flatmates/:id` and referencing by id is cleaner. Pick one.
3. **Filter options endpoint** — ship `GET /flats/filter-options` so amenities/sort lists are server-driven, or keep them iOS-baked? Server-driven means new amenities don't need an iOS release.
4. **Squad mode** — v1 owns Solo. Squad depends on section 06's squad creation flow. Confirm: gate the toggle until the user has a squad? Or hide it entirely in v1?
5. **Pagination** — offset/limit (current spec) vs cursor? I picked offset for simplicity, switch if you prefer cursor.
6. **Pre-filled enquiry message** — design shows the message pre-filled with the user's top vibe prefs. Backend-generated suggestion (returned by `GET /flats/:id`) or client-built? I'd lean toward client-built since iOS already has the user's vibe prefs.
7. **Photo sizes** — single URL vs `thumb_url` + `full_url` per photo? Or query-param resizing on the CDN?
8. **Flatmate vibe prefs** — embedding `vibe_prefs: int[]` per flatmate uses our canonical list (matches user's). Confirm flatmates are tagged from the same 24-pref set, not a separate "lifestyle tag" set.
