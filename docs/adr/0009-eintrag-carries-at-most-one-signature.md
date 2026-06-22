# ADR-0009: An Eintrag carries at most one Signatur

**Status**: Accepted

## Context

The data model allowed zero or more Signaturen per Eintrag, and multiple identities could each add an independent signature. Two alternatives were considered for meaningful multi-signature support:

1. **Chained (countersignature)**: each subsequent signature's payload includes all prior signatures, creating a cryptographic chain of trust.
2. **Independent co-signatures**: multiple identities each sign the same Eintrag content independently.

Neither pattern was ever used in practice, and no concrete workflow requiring multiple signatures exists. The chained approach would significantly increase signing and verification complexity (new payload version, ordering constraints, chain validation). Independent co-signatures offer no cryptographic relationship between signers and add no audit value over a single signature.

## Decision

An Eintrag carries at most one Signatur. The first Signatur finalises the Eintrag. A second signature by any identity — including a different one — is not permitted. This is enforced by a UNIQUE constraint on `eintrag_id` in the signatures table.

## Consequences

- The signing flow simplifies: once signed, the sign action is no longer available regardless of which identity is selected.
- `possibleSigners` on a `SelectedEintrag` remains meaningful only for unsigned Einträge (identity selection before signing).
- If a multi-signature workflow is needed in the future, this constraint must be revisited along with the signing payload schema and verification logic.
