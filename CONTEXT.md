# Glossary

## Jugendlicher
A youth member tracked by the system. Has a name, gender, birth date, and member-since date. May carry a `pass` reference. Can be in one of three states: **aktiv**, **ausgetreten**, or **ersetzt** (see below).

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
A classification tag for an Eintrag.
