# julog

Digitales Dienstbuch für Jugendfeuerwehr-Gruppen. julog ermöglicht die strukturierte Erfassung von Diensten (Einträgen), die Verwaltung von Jugendlichen und Betreuern sowie die kryptografisch gesicherte Dokumentation — lokal, ohne Cloud-Abhängigkeit.

Aktuelle Version: **3.1.0** · Lizenz: **GPL-3.0**

---

## Features

### Einträge (Dienstbuch)
- Erfassung von Gruppendiensten mit Datum, Uhrzeit, Kategorie, Thema, Ort und Notizen
- Anwesenheitsliste: jeder Jugendliche und Betreuer erhält den Status `anwesend`, `entschuldigt` oder `undefiniert`
- PDF-Export eines Eintrags inkl. kryptografischer Signatur zur revisionssicheren Dokumentation

### Jugendliche & Betreuer
- Verwaltung von Jugendlichen mit Name, Geschlecht, Geburtsdatum und Eintrittsdatum
- Unterstützung von Namensänderungen über ein Ersetzungsprinzip (alter Datensatz bleibt erhalten, neuer übernimmt)
- Austritt mit Datum und Grund (z. B. Übernahme in aktive Wehr, Wohnortwechsel, kein Interesse)
- Ausgetretene Jugendliche bleiben in historischen Einträgen erhalten, sind aber in neuen Formularen nicht mehr auswählbar

### Kategorien
- Frei konfigurierbare Kategorien zur Klassifikation von Einträgen

### Kryptografische Absicherung
- Signierung von Einträgen mit RSA-Schlüsselpaaren — privater Schlüssel bleibt außerhalb der App beim Unterzeichner
- Signaturen können ohne Passwort des Unterzeichners mit dem öffentlichen Schlüssel verifiziert werden
- Jede Signatur basiert auf einem deterministischen JSON-Dokument des Eintrags (versionierte SQL-Query), sodass nachträgliche Manipulation erkennbar ist

### Datenschutz & Datenhaltung
- Alle Daten werden lokal in einer SQLite-Datei (`.jfdb`) gespeichert — kein Server, keine Cloud
- Private Schlüssel werden außerhalb der App verwaltet (z. B. im Betriebssystem-Schlüsselbund)
- Logs enthalten keine Klarnamen, sondern ausschließlich UUIDs (ADR-0007)

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
| Kryptografie | pointycastle |
| PDF-Export | pdf + printing |
| Lokalisierung | flutter_localizations / intl |

### Architektur-Muster

Die App folgt einer geschichteten Architektur:

- **UI** (`lib/ui/`) — Screens und Widgets, kein Geschäftslogik
- **ViewModel** (`lib/view_model/`) — Zustandstransformationen für die UI
- **Provider** (`lib/provider/`) — Riverpod-Provider als Kompositionsschicht
- **Repository** (`lib/repository/`) — Zugriff auf `jldb` und `jlcrypto`
- **Service** (`lib/service/`) — Querschnittsdienste (z. B. Logging, PDF-Generierung)

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

---

## Entwicklung

### Voraussetzungen

- Flutter SDK ≥ 3.10
- Dart SDK ≥ 3.10
- Für Linux: `libsqlite3-dev` (oder äquivalent)

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

```bash
dart run build_runner build
```

---

## Versionierung

julog folgt [Semantic Versioning](https://semver.org/lang/de/). Ein Breaking Change (Major-Version) bedeutet, dass bestehende `.jfdb`-Dateien nicht mehr kompatibel sind. Minor-Versionen können Daten schreiben, die ältere Minor-Versionen nicht lesen können — daher immer die neueste Minor-Version verwenden.

---

## Lizenz

GPL-3.0 — siehe [LICENSE](LICENSE).
