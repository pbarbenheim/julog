# ADR-0001: Ausgetretener Jugendlicher is still selectable in Eintrag form on their exit date

**Status**: Accepted

## Context

When a Jugendlicher's Austritt is recorded, the `exitDate` field marks the last day of membership. The Eintrag form must filter out ausgetretene Jugendliche from the picker. The question is where the boundary falls: is a Jugendlicher excluded starting on their `exitDate`, or only after it has strictly passed?

## Decision

A Jugendlicher is excluded from the Eintrag form picker only once `exitDate < today` (strictly past). On the exit date itself they are still selectable.

## Consequences

- An Eintrag can be recorded on the same day as a Jugendlicher's Austritt, which reflects reality: a Jugendlicher may attend their last session on the day they formally leave.
- The filter logic is `exitDate == null || !exitDate.isBefore(today)` using date-level comparison (time component ignored).
- A future reader must not change this to `<=` without understanding that it would prevent recording attendance on the final day.
