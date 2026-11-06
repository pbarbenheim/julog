# ADR-0011: A Jugendlicher exiting on the Stichtag is not a Mitglied

**Status**: Accepted

## Context

The glossary defines a Jugendlicher as still **aktiv** on their `exitDate` (see ADR-0001). The Jahresbericht counts Mitglieder on the Stichtag (31 December) and Abgänge with `exitDate` in the Berichtsjahr. With the aktiv rule, someone exiting on 31 December would be counted both as Mitglied and as Abgang.

## Decision

For the Jahresbericht, a Mitglied has `exitDate` empty or `exitDate > Stichtag`. Someone with `exitDate` on the Stichtag counts only as an Abgang. The general aktiv rule is unchanged outside the Jahresbericht.

## Consequences

- Mitglieder + Zugang − Abgang stays consistent across years.
- The same person can be aktiv in the app on 31 December but not a Mitglied in the Jahresbericht. This is intentional and documented in the glossary.
