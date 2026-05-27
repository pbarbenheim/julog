# ADR 0002: Name change on a Jugendlicher triggers a replacement record

**Status:** Accepted

## Context

Eintrag signatures embed the Jugendlicher's `id` and `name` at signing time (via the `signV4Query` / `signV5Query` SQL). Mutating `name` in-place would silently invalidate all past signatures for Einträge that included that Jugendlicher, with no way to detect or recover the discrepancy.

The `replacedBy` / `replacesId` chain already exists in the data model for exactly this purpose (e.g. legal name changes).

## Decision

Editing a Jugendlicher is split into two paths:

- **Safe fields** (`gender`, `pass`, `birthDate`, `memberSince`) — updated in-place via `updateJugendlicher`. These fields are not included in any signing payload.
- **Signature-breaking field** (`name`) — triggers a replacement: a new Jugendlicher record is created with `replacesId` pointing to the old one, and the old record gets `replacedById` set. The old record becomes an *Ersetzter Jugendlicher* and is hidden from the list.

The edit UI handles both paths transparently: if the name did not change, the same ID is returned and the view stays put; if the name changed, the view navigates to the new record's ID.

## Consequences

- Past signatures remain verifiable: the signing query still reads the original `name` from the original record, which is preserved in the database.
- The old record is never deleted; it remains reachable via historical Einträge.
- Ausgetreten Jugendliche cannot be edited (the edit button is hidden), avoiding the question of whether exit status transfers to the replacement.
