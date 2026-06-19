# ADR-0006: Logging uses dart:logging with a custom file handler

**Status**: Accepted

## Context

The app needed structured error logging so that end users can send diagnostic information to the developer. Several third-party packages exist (flutter_logs, omni_logger, etc.) but carry low download counts and inconsistent quality. Dart ships an official `logging` package (publisher: dart.dev, 6.9M downloads) that provides the standard Logger/Level/LogRecord API used across the Dart ecosystem — the same conceptual model as `java.util.logging` and Python's `logging` module. It intentionally ships without file output; consumers attach their own handlers via `Logger.root.onRecord`.

## Decision

We use `logging` (dart.dev) as the logging API throughout the app and write a thin `LogFileHandler` (~50 lines) that listens to `Logger.root.onRecord` and maintains a rolling buffer of 100 entries in a plain-text file under `getApplicationSupportDirectory()`. No third-party file-logging package is added.

## Consequences

- Any part of the app can use `Logger('component-name')` without depending on our own infrastructure — only the `LogFileHandler` wiring in main needs to know about the file.
- The rolling buffer keeps the log file small enough to email; older entries are silently dropped.
- A future developer must not mistake "no third-party logging package" for an oversight — the custom handler was a deliberate choice to avoid low-quality dependencies.
- Switching the output format or storage strategy only requires changing `LogFileHandler`, not call sites.
