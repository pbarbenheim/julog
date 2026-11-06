# ADR-0010: Herkunft is stored on the Jugendlicher

**Status**: Accepted

## Context

The Jahresbericht splits Zugänge into `Neu`, `AndereOrganisation` and `Kinderfeuerwehr`. Julog only knows `memberSince`, so it cannot tell these apart. Two alternatives:

1. **Yearly manual counts**: the Jahresbericht wizard asks for the AO and KF counts per gender each year; Neu is the remainder.
2. **Herkunft on the Jugendlicher**: a field set when the Jugendlicher is created.

Option 1 needs no schema change, but the answer is detached from the person, must be re-entered every year, and cannot be audited later.

## Decision

A Jugendlicher carries a **Herkunft** (`Neu`, `AndereOrganisation`, `Kinderfeuerwehr`), set at creation, defaulting to `Neu`, and editable afterwards so wrongly migrated records can be corrected. Existing records migrate to `Neu`. The Jahresbericht derives the Zugang breakdown from it.

## Consequences

- Requires a jldb migration, a model change and a form field.
- Existing Jugendliche who actually came from another organisation or a Kinderfeuerwehr must be corrected by hand if they fall into a Berichtsjahr that is reported.
- Reports for past years stay reproducible from the stored data.
