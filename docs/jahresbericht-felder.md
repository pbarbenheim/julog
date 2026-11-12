# Jahresbericht der Jugendfeuerwehr: Felder des Import-Formats

Referenz für den XML-Export an das Jahresberichtstool der Deutschen Jugendfeuerwehr. Quelle: die XLSX-Vorlage des Portals (Spalten *Feld*, *Wert*, *Beschreibung*), ergänzt um eine Beispiel-XML.

## XML-Format

```xml
<?xml version="1.0"?>
<xml><field key="Betreuer_Anz_M">17</field><field key="..."/>...</xml>
```

- Flach: ein `<field key="…">Wert</field>` je Feld unter dem Wurzelelement `<xml>`.
- Alle Werte sind ganze Zahlen. Ausnahme: `Organisationen`, im Beispiel leer; Julog schreibt dort immer 1.
- Schlüssel enthalten Umlaute (`Grund_SO_Übernahme`, `Alter_Anz_über_18_*`).
- Suffixe `_M`, `_W`, `_D` stehen für männlich, weiblich, divers (entspricht `Gender`).
- Die Beispiel-XML enthält in `Frage_08_MML_JA` den Wert 14. Das ist ein Fehler in der Beispiel-XML; die XLSX-Vorlage kennt das nicht. Alle Fragen sind reine Ja/Nein-Angaben.

## Felder

| Feld | Beschreibung |
|---|---|
| `Organisationen` | Anzahl Organisationen (Vorlage: 1) |
| `Betreuer_Anz_{M,W,D}` | Anzahl Betreuer |
| `Mitglieder_Anz_{M,W,D}` | Anzahl Mitglieder |
| `Zugang_Anz_Neu_{M,W,D}` | Zugang neu |
| `Zugang_Anz_AO_{M,W,D}` | Zugang aus anderer Organisation |
| `Zugang_Anz_KF_{M,W,D}` | Zugang aus der Kinderfeuerwehr |
| `Abgang_Anz_EA_{M,W,D}` | Abgang in die Einsatzabteilung |
| `Abgang_Anz_SO_{M,W,D}` | Abgang sonstige |
| `Grund_SO_Wohnort` | davon Grund: Wohnortwechsel |
| `Grund_SO_Interesse` | davon Grund: Interesse an JF/KF verloren |
| `Grund_SO_Schule` | davon Grund: Belastung durch Schule |
| `Grund_SO_Beruf` | davon Grund: Berufsausbildung |
| `Grund_SO_Verweis` | davon Grund: Verweis bzw. Ausschluss aus der JF/KF |
| `Grund_SO_Übernahme` | davon Grund: möchte keine Übernahme in JF/EA |
| `Alter_Anz_unter_5_{M,W,D}` | Anzahl mit Alter unter 5 Jahre |
| `Alter_Anz_05_…_18_{M,W,D}` | Anzahl je Alter 5 bis 18 Jahre, zweistellig (`05`, `06`, …, `18`) |
| `Alter_Anz_über_18_{M,W,D}` | Anzahl mit Alter über 18 Jahre |
| `Alter_Anz_EA_bis_27_{M,W,D}` | Anzahl der unter 27-Jährigen in der Einsatzabteilung |

### Fragen (Ja/Nein)

Je Frage zwei Felder: `Frage_NN_MML_JA` und `Frage_NN_MML_NEIN`. Die Vorlage belegt immer genau eines mit 1.

| Nr. | Beschreibung |
|---|---|
| 01 | Teilnahme am Gemeinschaftsleben |
| 02 | Teilnahme an externen Bildungsveranstaltungen |
| 03 | Teilnahme an internen Bildungsveranstaltungen der JF/KF |
| 04 | Aktivitäten: internationale Jugendarbeit |
| 05 | Aktivitäten: Natur / Umweltschutz |
| 06 | Aktivitäten: aktive Mitgliederwerbung |
| 07 | Aktivitäten: an der Schule/Kindergärten |
| 08 | Wettbewerbe: Jugendflamme |
| 09 | Wettbewerbe: Bundeswettbewerb |
| 10 | Wettbewerbe: Leistungsspange |
| 11 | Wettbewerbe: CTIF |
| 12 | Wettbewerbe: landesspezifischer Wettbewerb |
| 13 | Sonstiges: JF/KF hat mehr Interessierte, als sie aufnehmen kann |
| 14 | Sonstiges: JF/KF hat Nachwuchssorgen |
| 15 | Sonstiges: JF/KF hat zu wenig Betreuer |
| 16 | Sonstiges: JF/KF hat einen eigenen Sprecher |

### Arbeitswerte

| Feld | Beschreibung |
|---|---|
| `Arbeit_Wert_01` | Anzahl Gruppenabende pro Jahr / feuerwehrtechnische Ausbildung |
| `Arbeit_Wert_02` | Anzahl Gruppenabende pro Jahr / Wettbewerbstraining |
| `Arbeit_Wert_03` | Anzahl Gruppenabende pro Jahr / Spiele und Kreatives |
| `Arbeit_Wert_04` | Anzahl Gruppenabende pro Jahr / mit anderem Verein oder Gruppe |
| `Arbeit_Wert_05` | Anzahl Gruppenabende pro Jahr / Sport |
| `Arbeit_Wert_06` | Anzahl Gruppenabende pro Jahr / Erste Hilfe und Prävention |
| `Arbeit_Wert_07` | Anzahl Gruppenabende pro Jahr / Sonstiges |
| `Arbeit_Wert_10` | durchschn. Dauer je Gruppenabend in Minuten |
| `Arbeit_Wert_11` | durchschn. Dauer Vorbereitung/Nachbereitung je Gruppenabend in Minuten |
| `Arbeit_Wert_12` | durchschn. Anzahl der Betreuer je Gruppenabend |
| `Arbeit_Wert_13` | Anzahl Tagesveranstaltungen pro Jahr / Sonderveranstaltungen |
| `Arbeit_Wert_20` | Anzahl der Stunden für sonstige Arbeit auf dieser Ebene inkl. Betreuer bzw. Stellvertreter |

`Arbeit_Wert_08`, `_09` und `_14` bis `_19` kommen weder in der Vorlage noch im Beispiel vor.
