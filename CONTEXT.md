# Glossary

## Jugendlicher
A youth member tracked by the system. Has a name, gender, birth date, member-since date, and a **Herkunft**. May carry a `pass` reference. Can be in one of three states: **aktiv**, **ausgetreten**, or **ersetzt** (see below).

## Austritt
The act of a Jugendlicher leaving the group. Recorded once and is irreversible. Captured by two required fields on the Jugendlicher: `exitDate` (the date membership ends) and `exitReason` (an `AustrittsGrund`). A Jugendlicher is considered **ausgetreten** once their `exitDate` has strictly passed (i.e. `exitDate < today`; on the exit date itself they are still **aktiv**).

## AustrittsGrund
An enum of reasons a Jugendlicher may leave. Values: `Uebernahme`, `Wohnortwechsel`, `NoInterest`, `Schule`, `Ausbildung`, `Ausschluss`, `NoUebernahme`. Stored as an integer in the database; the mapping is an implementation detail.

## Aktiver Jugendlicher
A Jugendlicher with no `exitDate`, or whose `exitDate` has not yet strictly passed. Selectable in the Eintrag form.

## Ausgetretener Jugendlicher
A Jugendlicher whose `exitDate` has strictly passed (`exitDate < today`). Not selectable in the Eintrag form. Still visible in the Jugendliche list, visually distinguished and sorted to the bottom.

## Ersetzter Jugendlicher
A Jugendlicher with a `replacedById` set — they have been superseded by a newer record (e.g. after a legal name change). Not selectable in the Eintrag form. Not shown in the Jugendliche list. Only referenced by historical entities. Independent of Austritt.

## Eintrag
A group session record. Captures date/time, category (Kategorie), topic (Thema), location, notes, and the attendance of Jugendliche and Betreuer. A Jugendlicher present in a historical Eintrag remains there regardless of their current state.

## Anwesenheit
The attendance status of a Jugendlicher in an Eintrag. Values: `anwesend`, `entschuldigt`, `undefiniert`.

## Betreuer
A group leader/supervisor. Linked to Einträge as facilitators.

## Kategorie
A classification tag for an Eintrag. Is assigned a **Berichtsthema** (optional until a Jahresbericht needs it).

## Signatur
A cryptographic signature (RSA with SHA-512) attached to an Eintrag by an Identity. An Eintrag carries at most one Signatur. Each Signatur records the signer's Identity, a timestamp, a version, and a validity flag.

## Unsignierter Eintrag
An Eintrag that carries no Signatur. An unsignierter Eintrag is considered a draft — it has not yet been finalised and may be edited or deleted. Once a Signatur is added (regardless of validity), the Eintrag is considered signiert and can no longer be modified or deleted.

## Signierter Eintrag
An Eintrag that carries exactly one Signatur. A signierter Eintrag is considered finalised and is immutable — it cannot be edited or deleted.

## Jahresbericht
The yearly report a Jugendfeuerwehr submits to the Deutsche Jugendfeuerwehr. Produced as an XML file and uploaded to the Jahresberichtstool. Field definitions: `docs/jahresbericht-felder.md`. Most values are derived from Julog data; the rest are entered manually. Derived work values can be overridden; derived member counts cannot.

## Berichtsjahr
The calendar year a Jahresbericht covers. Chosen when creating the report.

## Stichtag
31 December of the Berichtsjahr. Reference date for member counts and ages in the Jahresbericht.

## Mitglied (im Jahresbericht)
A Jugendlicher with `memberSince ≤ Stichtag` and no `exitDate` or `exitDate > Stichtag`. Unlike **Aktiver Jugendlicher**, someone whose `exitDate` is the Stichtag is not a Mitglied; they only count as an Abgang. A replacement chain (see **Ersetzter Jugendlicher**) counts as one Mitglied, using the current record. Age is in full years on the Stichtag.

## Zugang
A Jugendlicher whose `memberSince` lies in the Berichtsjahr. Broken down by **Herkunft**.

## Abgang
A Jugendlicher whose `exitDate` lies in the Berichtsjahr. `Uebernahme` is an Abgang into the Einsatzabteilung; every other **AustrittsGrund** is a sonstiger Abgang, broken down by reason.

## Herkunft
Where a Jugendlicher came from when joining. Values: `Neu`, `AndereOrganisation`, `Kinderfeuerwehr`. Set when the Jugendlicher is created; defaults to `Neu`.

## Berichtsthema
One of seven fixed topics the Jahresbericht groups Einträge into: feuerwehrtechnische Ausbildung, Wettbewerbstraining, Spiele und Kreatives, mit anderem Verein oder Gruppe, Sport, Erste Hilfe und Prävention, Sonstiges. Each **Kategorie** is assigned one. "Sonstiges" is an explicit choice, distinct from "not yet assigned".

## Betreuer (im Jahresbericht)
A Betreuer counts for a Berichtsjahr if they appear in at least one Eintrag of that year.

## Tagesveranstaltung
An Eintrag lasting at least 5 hours. In the Jahresbericht it counts as a Gruppenabend under its Berichtsthema and additionally as a Tagesveranstaltung.
