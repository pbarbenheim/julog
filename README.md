# julog

Digitales Dienstbuch für Jugendfeuerwehr-Gruppen. julog ermöglicht die strukturierte Erfassung von Diensten (Einträgen), die Verwaltung von Jugendlichen und Betreuern sowie die kryptografisch gesicherte Dokumentation — lokal, ohne Cloud-Abhängigkeit.

Aktuelle Version: siehe [Releases](https://github.com/pbarbenheim/julog/releases/latest) · Lizenz: **GPL-3.0**

---

## Features

### Dashboard
- Übersicht über die Anzahl aktiver Jugendlicher, den letzten Eintrag, anstehende bzw. kürzliche Geburtstage und den Anwesenheitsverlauf als Diagramm

### Einträge (Dienstbuch)
- Erfassung von Gruppendiensten mit Datum, Uhrzeit, Kategorie, Thema, Ort und Notizen
- Anwesenheitsliste: jeder Jugendliche und Betreuer erhält den Status `anwesend`, `entschuldigt` oder `undefiniert`
- Entwurfsprinzip: Ein Eintrag ohne Signatur ist ein Entwurf und kann bearbeitet oder gelöscht werden. Sobald er eine Signatur trägt (auch eine ungültige), ist er final und unveränderlich (ADR-0008). Ein Eintrag trägt höchstens eine Signatur (ADR-0009)
- PDF-Export eines Eintrags inkl. kryptografischer Signatur zur revisionssicheren Dokumentation

### Jugendliche
- Verwaltung von Jugendlichen mit Name, Geschlecht, Geburtsdatum und Eintrittsdatum
- Unterstützung von Namensänderungen über ein Ersetzungsprinzip (alter Datensatz bleibt erhalten, neuer übernimmt); ersetzte Datensätze sind weder in der Liste noch in Formularen sichtbar
- Austritt mit Datum und Grund (Übernahme, Wohnortwechsel, Interesse verloren, Belastung durch Schule, Berufsausbildung, Verweis/Ausschluss, keine Übernahme in die Einsatzabteilung)
- Ein Jugendlicher gilt am Austrittsdatum noch als aktiv und ist erst danach nicht mehr in neuen Einträgen auswählbar. In historischen Einträgen bleibt er erhalten, in der Liste steht er am Ende
- PDF-Export der Jugendlichen-Liste mit wählbaren Feldern, für alle oder eine Auswahl der Jugendlichen

### Betreuer
- Verwaltung von Betreuern (Name, Geschlecht); Betreuer werden in Einträgen mit Anwesenheit erfasst

### Kategorien
- Frei konfigurierbare Kategorien zur Klassifikation von Einträgen

### Identitäten & kryptografische Absicherung
- Identitäten (Unterzeichner mit Name, Funktion und Mail) werden in der App verwaltet
- Signierung von Einträgen mit RSA-Schlüsselpaaren (SHA-512). Der private Schlüssel wird passwortgeschützt im Schlüsselbund des Betriebssystems abgelegt (`flutter_secure_storage`), nicht in der `.jfdb`-Datei; zum Signieren ist das Passwort der Identität nötig
- Signaturen können ohne Passwort des Unterzeichners mit dem öffentlichen Schlüssel verifiziert werden
- Jede Signatur basiert auf einem deterministischen JSON-Dokument des Eintrags (versionierte SQL-Query), sodass nachträgliche Manipulation erkennbar ist

### Datenschutz & Datenhaltung
- Alle Daten werden lokal in einer SQLite-Datei (`.jfdb`) gespeichert — kein Server, keine Cloud
- Logs enthalten keine Klarnamen, sondern ausschließlich UUIDs (ADR-0007)

### Komfort
- Hell-/Dunkelmodus
- Update-Hinweis: höchstens einmal täglich wird GitHub Releases auf eine neue Version geprüft. Unter Windows kann der Installer direkt heruntergeladen und gestartet werden, auf Linux und macOS verweist die App auf die Release-Seite

---

## Technische Struktur

julog ist als Flutter-Desktop-Applikation aufgebaut (Zielplattformen: Linux, macOS, Windows) und nutzt einen Dart-Workspace mit drei internen Paketen:

```
julog/               ← Flutter-App (UI, Routing, Provider)
packages/
  jldb/             ← SQLite-Persistenzschicht, Domänenmodelle
  jlcrypto/         ← RSA-Schlüsselverwaltung, Signierung, AES-Primitiven
  jlcore/           ← Gemeinsame Typhelfer (Result, Optional, Unit)
```

### Wichtige Technologien

| Bereich | Bibliothek |
|---|---|
| UI-Framework | Flutter / Material 3 |
| State Management | Riverpod (mit Code-Generierung) |
| Routing | go_router |
| Datenbank | sqlite3 (direkt, kein ORM) |
| Datenmodelle | freezed |
| Schlüsselablage | flutter_secure_storage |
| Update-Prüfung | http (GitHub Releases API) |
| Kryptografie | pointycastle |
| PDF-Export | pdf + printing |
| Lokalisierung | flutter_localizations / intl |

### Architektur-Muster

Die App folgt einer geschichteten Architektur:

- **UI** (`lib/ui/`) — Screens und Widgets, kein Geschäftslogik
- **ViewModel** (`lib/view_model/`) — Zustandstransformationen für die UI
- **Provider** (`lib/provider/`) — Riverpod-Provider als Kompositionsschicht
- **Repository** (`lib/repository/`) — Zugriff auf `jldb` und `jlcrypto`
- **Assembly** (`lib/assembly/`) — setzt Daten mehrerer Repositories zu zusammengesetzten Modellen zusammen (z. B. Eintrag mit Anwesenheit und Signatur)
- **Service** (`lib/service/`) — Querschnittsdienste (z. B. Logging, Signierung von Einträgen)
- **Update** (`lib/update/`) — Prüfung auf neue Versionen und Installer-Download

Architekturentscheidungen sind als ADRs unter `docs/adr/` dokumentiert:

| Nr. | Entscheidung |
|---|---|
| [ADR-0001](docs/adr/0001-austritt-selectable-on-exit-date.md) | Ausgetretener Jugendlicher ist am Austrittsdatum noch im Eintrag wählbar |
| [ADR-0002](docs/adr/0002-jugendlicher-name-change-triggers-replacement.md) | Namensänderung eines Jugendlichen erzeugt einen Ersetzungsdatensatz |
| [ADR-0003](docs/adr/0003-pdf-export-uses-ad-hoc-selection-no-veranstaltung.md) | PDF-Export nutzt Ad-hoc-Auswahl der Jugendlichen — keine persistente Veranstaltungs-Entität |
| [ADR-0004](docs/adr/0004-eintrag-pdf-includes-cryptographic-signature-for-audit.md) | Eintrag-PDF enthält kryptografische Signatur und Version zur Revisionssicherung |
| [ADR-0005](docs/adr/0005-selected-eintrag-exposes-undefiniert-jugendliche.md) | SelectedEintrag stellt Jugendliche mit undefinierter Anwesenheit als eigene Liste bereit |
| [ADR-0006](docs/adr/0006-logging-uses-dart-logging-with-custom-file-handler.md) | Logging nutzt dart:logging mit eigenem File-Handler |
| [ADR-0007](docs/adr/0007-log-entries-contain-uuids-only-no-plain-text-names.md) | Log-Einträge enthalten ausschließlich UUIDs, keine Klarnamen |
| [ADR-0008](docs/adr/0008-any-signature-locks-eintrag.md) | Jede Signatur, auch eine ungültige, macht einen Eintrag unveränderlich |
| [ADR-0009](docs/adr/0009-eintrag-carries-at-most-one-signature.md) | Ein Eintrag trägt höchstens eine Signatur |

---

## Entwicklung

### Voraussetzungen

- Flutter SDK mit Dart SDK ≥ 3.10.4
- Für Linux: `libsqlite3-dev` (SQLite) sowie die Bibliotheken für `flutter_secure_storage` (libsecret, `libsecret-1-dev`) (oder äquivalent)

### Starten

```bash
flutter pub get
flutter run -d linux    # oder macos / windows
```

### Tests

```bash
flutter test
cd packages/jldb && dart test
cd packages/jlcrypto && dart test
```

### Code-Generierung

Riverpod, freezed und go_router erzeugen Code. Nach Änderungen an annotierten Klassen:

```bash
dart run build_runner build
```

### Releases

Der Workflow `Flutter Release` baut bei einem Release ein Linux-Archiv (`.tar.gz`), einen Windows-Installer (`julog-windows-x64-setup.exe`) und ein macOS-Archiv (`.zip`). `Flutter analyze` prüft den Code in der CI.

---

## Versionierung

julog folgt [Semantic Versioning](https://semver.org/lang/de/). Ein Breaking Change (Major-Version) bedeutet, dass bestehende `.jfdb`-Dateien nicht mehr kompatibel sind. Minor-Versionen können Daten schreiben, die ältere Minor-Versionen nicht lesen können — daher immer die neueste Minor-Version verwenden.

---

## Lizenz

GPL-3.0 — siehe [LICENSE](LICENSE).
