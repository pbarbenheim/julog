# ADR-0004: Eintrag PDF export includes cryptographic signature value and version for audit

**Status**: Accepted

## Context

The Eintrag PDF export renders a human-readable representation of a group session record. Each Eintrag can carry one or more cryptographic signatures (Ed25519/SHA512). The question is whether the PDF should include only the human-readable metadata of each signature (signer name, function, timestamp, validity) or also the raw cryptographic artefacts (signing version and Base64-encoded signature value).

## Decision

The PDF includes the full Base64-encoded signature value and the signing version for every signature, rendered in a small monospace font with line wrapping. The human-readable fields (signer name, function, timestamp, validity) are shown alongside them.

## Consequences

- The PDF can serve as a self-contained audit document: anyone with the signer's public key can independently verify the signature without querying the database.
- The Base64 value (~88 characters for a SHA512 signature) adds visual noise but remains on one or two lines at small font sizes.
- The signing version is required context for verification, since the signing payload schema differs between versions.
- Changing the display format (e.g. switching to hex or truncating) would silently break any external audit process that relies on copy-pasting the value from the PDF.
