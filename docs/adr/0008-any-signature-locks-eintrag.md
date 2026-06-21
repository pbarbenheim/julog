# ADR-0008: Any Signatur — including an invalid one — makes an Eintrag immutable

An Eintrag without any Signatur is considered a draft and may be edited or deleted. Once any Signatur is attached, the Eintrag is considered finalised and can no longer be modified or deleted, even if that Signatur's `isValid` flag is `false`.

The alternative would be to treat only *valid* Signaturen as locking. This was rejected because an invalid Signatur still proves that someone attempted to sign — and therefore reviewed — the Eintrag at a point in time. Allowing edits after an invalid signature would let the content silently diverge from what the signer saw, which defeats the audit purpose. If a signature is invalid (e.g. corrupted key or tampered data), the correct response is to investigate, not to quietly edit the underlying record.
