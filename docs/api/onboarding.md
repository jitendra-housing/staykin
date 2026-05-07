# Staykin onboarding API

Spec for the seven onboarding submits the iOS client makes during first-run signup. Source of truth for the iOS request payloads is `Staykin/Features/Onboarding/`.

> **Status:** Most canonical lists are confirmed by backend (Jitendra Lakhmani). `Gender` and `Intent` are still iOS-proposed — flagged inline. Two endpoints are conditional on backend's preference (single-shot vs per-screen submit).

## Contents

- [Overview](#overview)
- [Auth & headers](#auth--headers)
- [Endpoints](#endpoints)
  - [1. Send OTP](#1-send-otp)
  - [2. Verify OTP](#2-verify-otp)
  - [3. Profile](#3-profile)
  - [4. Intent](#4-intent)
  - [5. Flat preferences](#5-flat-preferences)
  - [6. Vibe preferences](#6-vibe-preferences)
  - [7. Complete onboarding](#7-complete-onboarding)
  - [Photo upload (helper)](#photo-upload-helper)
- [Canonical reference lists](#canonical-reference-lists)
- [Wire-format invariants](#wire-format-invariants)
- [Open items](#open-items)

---

## Overview

Onboarding is **seven screens**, each with its own submit endpoint. Per-screen submit is the working assumption — it lets a user kill the app and resume where they left off.

| # | Screen | Endpoint | Auth |
|---|---|---|---|
| 1 | Phone | `POST /auth/send-otp` | none |
| 2 | OTP | `POST /auth/verify-otp` | none → returns JWT |
| 3 | Profile | `POST /onboarding/profile` | Bearer JWT |
| 4 | Intent | `POST /onboarding/intent` | Bearer JWT |
| 5 | Flat prefs | `POST /onboarding/flat-preferences` | Bearer JWT |
| 6 | Vibe prefs | `POST /onboarding/vibe-preferences` | Bearer JWT |
| 7 | Vibe card | `POST /onboarding/complete` | Bearer JWT |
| — | Photo upload | `POST /uploads/photo` | Bearer JWT |

Endpoint paths are proposed — backend's call to rename or namespace them differently. The bodies and IDs are what matters and are baked into the iOS client.

## Auth & headers

```
Content-Type: application/json
Authorization: Bearer <jwt>      // from POST /auth/verify-otp
```

JWT lifetime, refresh strategy, and revocation are backend concerns; client just persists the token returned by `verify-otp` and sends it on every onboarding endpoint.

---

## Endpoints

### 1. Send OTP

```http
POST /auth/send-otp
```

```json
{
  "country_code": "+91",
  "phone_number": "9876543210"
}
```

| Field | Type | Required | Validation |
|---|---|---|---|
| `country_code` | string | yes | E.164 prefix; v1 = `"+91"` only |
| `phone_number` | string | yes | exactly 10 digits, no formatting |

**Success — 200 OK**
```json
{ "status": "sent" }
```

Optional: include an `otp_session_id` if backend wants to bind verify to a specific send.

**Errors**
- `400 invalid_phone` — bad format
- `429 rate_limited` — too many sends in window

---

### 2. Verify OTP

```http
POST /auth/verify-otp
```

```json
{
  "country_code": "+91",
  "phone_number": "9876543210",
  "otp_code":     "739182"
}
```

| Field | Type | Required | Validation |
|---|---|---|---|
| `otp_code` | string | yes | exactly 6 digits |

**Success — 200 OK**
```json
{
  "access_token": "eyJ...",
  "token_type":   "Bearer",
  "expires_in":   2592000,
  "user_id":      12345,
  "is_new_user":  true
}
```

`is_new_user` lets the client decide whether to enter onboarding or jump to home.

**Errors**
- `401 invalid_otp` — wrong code
- `410 otp_expired` — code expired (client offers Resend)

---

### 3. Profile

Photo is uploaded first via [`POST /uploads/photo`](#photo-upload-helper); the returned URL is sent here.

```http
POST /onboarding/profile
```

```json
{
  "name":       "Aanya Sharma",
  "age":        23,
  "gender":     1,
  "occupation": "Product Designer",
  "photo_url":  "https://cdn.staykin.app/u/abc123.jpg"
}
```

| Field | Type | Required | Validation |
|---|---|---|---|
| `name` | string | yes | trimmed, non-empty, ≤ 80 chars |
| `age` | int | yes | 18–99 |
| `gender` | int | yes | id ∈ {1..4} — see [Gender](#gender) |
| `occupation` | string | yes | trimmed, non-empty, ≤ 80 chars |
| `photo_url` | string (URL) | optional | must be a Staykin CDN URL returned by `/uploads/photo` |

> `city` is **not sent**. v1 is Gurgaon-only and assumed server-side. Add the field once more cities launch.

---

### 4. Intent

```http
POST /onboarding/intent
```

```json
{ "intent": 1 }
```

| Field | Type | Required | Validation |
|---|---|---|---|
| `intent` | int | yes | id ∈ {1..3} — see [Intent](#intent) |

---

### 5. Flat preferences

```http
POST /onboarding/flat-preferences
```

```json
{
  "areas":      [1, 3, 5],
  "budget_min": 15000,
  "budget_max": 30000,
  "bhk":        [2, 3],
  "room_type":  1,
  "furnishing": [1, 2],
  "move_in":    1
}
```

| Field | Type | Required | Validation |
|---|---|---|---|
| `areas` | int[] | yes | min 1, each id ∈ {1..7}, no dupes — see [Areas](#areas-gurgaon) |
| `budget_min` | int (INR rupees) | yes | ≥ 5000, ≤ 50000, multiple of 1000, ≤ `budget_max − 1000` |
| `budget_max` | int (INR rupees) | yes | ≥ 5000, ≤ 50000, multiple of 1000, ≥ `budget_min + 1000` |
| `bhk` | int[] | yes | min 1, each id ∈ {1..4}, no dupes — see [BHK](#bhk) |
| `room_type` | int | yes | id ∈ {1..3} — see [Room Type](#room-type) |
| `furnishing` | int[] | yes | min 1, each id ∈ {1..3}, no dupes — see [Furnishing](#furnishing) |
| `move_in` | int | yes | id ∈ {1..3} — see [Move-in](#move-in) |

**Success — 200 OK** (echoes saved data; `204 No Content` is also fine)
```json
{
  "status": "saved",
  "preferences": {
    "areas":      [1, 3, 5],
    "budget_min": 15000,
    "budget_max": 30000,
    "bhk":        [2, 3],
    "room_type":  1,
    "furnishing": [1, 2],
    "move_in":    1,
    "updated_at": "2026-05-07T11:42:18Z"
  }
}
```

---

### 6. Vibe preferences

```http
POST /onboarding/vibe-preferences
```

```json
{ "vibe_prefs": [1, 7, 4, 16, 22] }
```

| Field | Type | Required | Validation |
|---|---|---|---|
| `vibe_prefs` | int[] | yes | ≥ 5, ≤ 24, each id ∈ {1..24}, no dupes — see [Vibe prefs](#vibe-prefs) |

---

### 7. Complete onboarding

```http
POST /onboarding/complete
```

Empty body. Backend marks the user as fully onboarded; client transitions to home.

**Alternative:** backend can mark completion implicitly on a successful `/onboarding/vibe-preferences` and skip this call. Pick one.

---

### Photo upload (helper)

Called from the Profile screen if the user picks a photo.

```http
POST /uploads/photo
Content-Type: multipart/form-data
Authorization: Bearer <jwt>

file=<binary jpeg/png>
```

**Success — 200 OK**
```json
{ "photo_url": "https://cdn.staykin.app/u/abc123.jpg" }
```

| Constraint | Value |
|---|---|
| Accepted MIME | `image/jpeg`, `image/png` |
| Max size | 5 MB (suggested) |

The returned URL goes into the `photo_url` field of `/onboarding/profile`.

---

## Canonical reference lists

> ✅ = backend-confirmed · ⚠ = iOS-proposed, awaiting backend confirmation

### Gender ⚠

| id | value | label |
|---:|---|---|
| 1 | `FEMALE` | Female |
| 2 | `MALE` | Male |
| 3 | `NON_BINARY` | Non-binary |
| 4 | `PREFER_NOT_TO_SAY` | Prefer not to say |

### Intent ⚠

| id | value | label | meaning |
|---:|---|---|---|
| 1 | `MOVE_INTO_FLAT` | Move into a flat | Find an existing flat with rooms available |
| 2 | `FILL_ROOMS_IN_MY_FLAT` | Fill rooms in my flat | I have a place, find flatmates to fill it |
| 3 | `TEAM_UP_TO_RENT` | Team up to rent a flat | Find your squad, then hunt together |

### Areas (Gurgaon) ✅

| id | name |
|---:|---|
| 1 | DLF Phase 1 |
| 2 | Sector 46 |
| 3 | Cyber City |
| 4 | Manesar |
| 5 | Golf Course Road |
| 6 | Sushant Lok 1 |
| 7 | South City 1 |

### BHK ✅

| id | value | label |
|---:|---|---|
| 1 | `ONE_BHK` | 1BHK |
| 2 | `TWO_BHK` | 2BHK |
| 3 | `THREE_BHK` | 3BHK |
| 4 | `STUDIO` | Studio |

### Room Type ✅

| id | value | label |
|---:|---|---|
| 1 | `SINGLE_ROOM` | Single Room |
| 2 | `SHARING` | Sharing |
| 3 | `EITHER` | Either |

### Furnishing ✅

| id | value | label |
|---:|---|---|
| 1 | `FURNISHED` | Furnished |
| 2 | `SEMI` | Semi |
| 3 | `UNFURNISHED` | Unfurnished |

### Move-in ✅

| id | value | label |
|---:|---|---|
| 1 | `ASAP` | ASAP |
| 2 | `WITHIN_ONE_MONTH` | Within 1 month |
| 3 | `ONE_TO_THREE_MONTHS` | 1–3 months |

### Vibe prefs ✅

| id | value | label |
|---:|---|---|
| 1 | `PLANT_PARENTS` | Plant parents |
| 2 | `WFH_GRIND` | WFH grind |
| 3 | `MUSIC_HEADS` | Music heads |
| 4 | `BOOKWORM` | Bookworm |
| 5 | `YOGA_CHAI` | Yoga + chai |
| 6 | `FOODIES` | Foodies |
| 7 | `LATE_NIGHTS` | Late nights |
| 8 | `EARLY_BIRDS` | Early birds |
| 9 | `PET_FRIENDLY` | Pet friendly |
| 10 | `SMOKE_FREE` | Smoke free |
| 11 | `QUIET_VIBES` | Quiet vibes |
| 12 | `PARTY_OK` | Party ok |
| 13 | `CREATIVE` | Creative |
| 14 | `OUTDOORSY` | Outdoorsy |
| 15 | `HOSTS_OFTEN` | Hosts often |
| 16 | `FITNESS_FREAK` | Fitness freak |
| 17 | `VEGAN` | Vegan |
| 18 | `NON_ALCOHOLIC` | Non-alcoholic |
| 19 | `WANDERER` | Wanderer |
| 20 | `CLEAN_FREAK` | Clean freak |
| 21 | `CHILL_VIBES` | Chill vibes |
| 22 | `GAMERS` | Gamers |
| 23 | `MOVIE_NIGHTS` | Movie nights |
| 24 | `SPORTY` | Sporty |

---

## Wire-format invariants

These hold across **every** endpoint above.

- Every selectable option (intent, gender, BHK, room type, furnishing, move-in, areas, vibe prefs) is sent as **`id` (integer)**, never `value` or `label`.
- IDs are 1-indexed and stable. Backend must never renumber existing items — only append new ones.
- Multi-select fields are `int[]`; single-select are plain `int`.
- All text fields trimmed before send.
- Phone numbers and OTP codes are digit-only strings (no spaces, no formatting).
- Money is integer rupees (no paise, no decimals, no currency symbol).
- Date/time fields (server-side only) are ISO-8601 UTC strings.

## Standard error envelope

```json
{
  "error":   "validation_failed",
  "message": "Invalid request body",
  "details": [
    { "field": "budget_min", "code": "below_minimum", "message": "must be ≥ 5000" }
  ]
}
```

| HTTP | Error code | Meaning |
|---:|---|---|
| 400 | `validation_failed` | request body failed validation; `details[]` lists offending fields |
| 401 | `unauthorized` | missing / expired / invalid token |
| 401 | `invalid_otp` | wrong OTP code |
| 409 | `already_submitted` | onboarding step already completed (optional gate) |
| 410 | `otp_expired` | OTP expired before verify |
| 429 | `rate_limited` | OTP send / login throttled |

---

## Open items

1. **Gender** and **Intent** — confirm or revise the canonical IDs above.
2. **Per-screen submit vs single-shot** — current spec assumes per-screen so users can resume. Confirm, or switch to one `POST /onboarding/submit` that takes the entire payload.
3. **Resume support** — if per-screen, expose `GET /onboarding/state` returning whatever the client has already submitted, so iOS can rehydrate `OnboardingData` after a kill.
4. **Photo upload shape** — separate `POST /uploads/photo` (current spec) or accept multipart inline on `POST /onboarding/profile`?
5. **Idempotency** — should onboarding endpoints accept an `Idempotency-Key` header so the client can safely retry?
6. **Completion signal** — explicit `POST /onboarding/complete` or implicit on vibe-prefs success?
