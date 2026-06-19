# ADR-0003: PDF export uses ad-hoc Jugendliche selection — no persistent Veranstaltung entity

**Status**: Accepted

## Context

The PDF export feature was motivated by the need to generate registration lists for events (e.g. a camp or excursion) that require prior sign-up. This use case naturally suggests introducing a persistent `Veranstaltung` (event) entity that stores a named event and its registered Jugendliche, which could then be exported.

## Decision

No `Veranstaltung` entity is introduced. The export is ad-hoc: the user selects a title, fields, and a subset of Jugendliche at export time. Nothing is persisted between exports.

## Consequences

- The domain model stays simpler — no new table, no registration lifecycle.
- Export configurations cannot be saved or reused; the user repeats field and Jugendliche selection each time.
- If a persistent Veranstaltung concept is needed in the future (e.g. to track which Jugendliche attended a specific event over time), it will require a new domain entity and schema migration. This ADR should be revisited at that point.
