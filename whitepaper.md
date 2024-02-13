# julog Konzept

Hier wird das Konzept hinter julog erläutert.

## Zielsetzung

julog soll die Möglichkeit bieten, ein Dienstbuch der Jugendfeuerwehr digital zu führen.
Dazu gehört die Aggregierung gewisser Daten, die Erstellung des Jahresberichts für die
Deutsche Jugendfeuerwehr (XML-Datei zum Upload) und die sichere Nachvollziehbarkeit der
Dokumente.

Bei Dokumenten in einem Dienstbuch handelt es sich um schützenswerte Informationen.
Schützenswert im Sinne Schutz vor Fälschung, da sie mitunter als Nachweise dienen müssen.
Um dieser Anforderung gerecht zu werden, muss Signatur-Technologie benutzt werden.

## Datenstrukturen

julog speichert alle öffentlichen Daten eines Dienstbuches in einer sqlite3-Datei ab
(\*.jfdb). Dazu zählen die Einträge selbst nebst Signaturen, die Eintragskategorien,
die Betreuer, die Jugendlichen, die öffentlichen Signatur-Schlüssel und verschiedene
andere Metadaten.

Lediglich die privaten Schlüssel werden außerhalb von julog gespeichert.

## Absicherung & Kryptographie

Damit ein Eintrag fälschungssicher signiert werden kann geschieht folgendes:

Der Eintrag wird erstmal in die Datenbank geschrieben. Dann wird eine spezielle versionierte
SQL-Query ausgeführt, welche ein [Json-Dokument](example-eintrag.json) als Ergebnis
zurückliefert. Dieses Json-Dokument wird nun mit einem privaten Schlüssel, welcher dafür
von einem Passwort entsperrt werden muss, signiert. Diese Signatur ist später nur mit dem
öffentlichen Schlüssel zu überprüfen. D.h., man kann die Korrektheit einer Signatur überprüfen,
ohne das Passwort des jeweiligen Unterzeichners zu kennen.
