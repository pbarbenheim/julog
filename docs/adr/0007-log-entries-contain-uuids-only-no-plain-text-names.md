# ADR-0007: Log entries contain UUIDs only, no plain-text names

**Status**: Accepted

## Context

The app stores personal data about Jugendliche and Betreuer. Log entries are written to a plain-text file that end users are expected to email to the developer for diagnosis. Including names (Jugendlicher names, Identity names) in log entries would make the file a personal-data artefact subject to data-protection requirements and uncomfortable to share.

## Decision

Log entries may include UUIDs (Eintrag IDs, Identity IDs), exception types, stack traces, and technical metadata. Plain-text names of any person are never written to the log. The developer can cross-reference UUIDs against the user's database file if a specific record needs to be inspected.

## Consequences

- Log files can be emailed without data-protection concerns.
- A future developer adding logging must actively resist the temptation to include names for "easier debugging" — this ADR is the reason not to.
- Diagnosing issues that depend on the specific content of a record (e.g. a name with unusual characters) requires the user to share their database file separately, which they may be unwilling to do.
