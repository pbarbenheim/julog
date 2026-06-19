# ADR-0005: SelectedEintrag exposes Jugendliche with undefiniert Anwesenheit as a third list

**Status**: Accepted

## Context

The `Eintrag` domain model tracks attendance via two sets: `anwesendeJugendlicherIds` and `entschuldigteJugendlicherIds`. Jugendliche linked to an Eintrag via the `eintrag_jugendlicher` junction table with status `undefiniert` (status ≠ 1 and ≠ 2) are stored in the database but were silently dropped when parsing the API model. They do not appear in the UI.

The signing payload (v5) is derived directly from the database and includes all linked Jugendliche regardless of status, with both `anwesend` and `entschuldigt` flags set to 0 for undefiniert ones. This means an Eintrag whose PDF omits undefiniert Jugendliche would not fully reflect the data that was actually signed.

In practice, undefiniert Jugendliche occur frequently (attendance is not always fully recorded at session time).

## Decision

`EintragApiModel` and `Eintrag` are extended with an `undefinierteJugendlicherIds` set. `SelectedEintrag` (the assembled view model) gains a third list `undefinierteJugendliche: List<Jugendlicher>`, resolved by `EintragAssembly`. The Eintrag PDF export renders them as a separate group ("Nicht erfasst").

The main Eintrag UI display (`EintragDisplay`) does not yet show this third group — that is a separate concern.

## Consequences

- The PDF accurately represents all Jugendliche that were part of the signed data.
- `EintragApiModel` and `Eintrag` now carry a field that was previously implicit (silently zero), which is a breaking change for callers that construct these models directly (e.g. tests).
- A future reader must not collapse the three attendance lists back into two without revisiting the signing payload schema and the PDF export.
