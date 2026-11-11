# ADR-0012: A Kategorie used by a signed Eintrag cannot be renamed

**Status:** Accepted

## Context

Eintrag signatures embed the Kategorie's `id` and `name` at signing time (via the `signV4Query` / `signV5Query` SQL). Renaming a Kategorie in place would silently invalidate the signatures of every signed Eintrag that uses it, with no way to detect or recover the discrepancy. This is the same problem as for the name of a Jugendlicher (ADR-0002).

Unlike a Jugendlicher, a Kategorie has no replacement chain, and adding one would be heavy for a plain classification tag. The **Berichtsthema** is not part of any signing payload.

## Decision

A Kategorie that is used by at least one signed Eintrag (any Signatur, see ADR-0008 and ADR-0009) cannot be renamed.

- `Jldb.updateKategorie` returns a `Failure` holding a `KategorieNameGesperrtException` when the name would change; nothing is written. `Jldb.isKategorieNameGesperrt` answers the question up front.
- The Berichtsthema stays editable, also for such a Kategorie.
- The Kategorie form disables the name field and explains why. The check in jldb remains the authority.

## Consequences

- Past signatures stay verifiable: the signing query still reads the original `name`.
- To get a different name, create a new Kategorie and use it for new Einträge. Unsigned Einträge can still be moved to it, because they remain editable.
- A Kategorie used only by unsigned Einträge, or by none, can be renamed freely.
