# Ori v0.11 Roadmap

## 1. 370_FileSystemAndIO.md

Define Ori's filesystem and IO semantics:
- File operations (Open, Read, Write, Seek, Stat)
- Directory operations (Mkdir, Remove, Walk)
- Path abstractions
- Deterministic destruction for IO handles
- Error model integration
- Concurrency safety rules

## 2. 380_LoggingFramework.md

Define a structured logging system:
- Explicit loggers
- Log levels (Debug, Info, Warn, Error, Fatal)
- Structured key-value logging
- Deterministic destruction (Close writer)
- No global hidden state

## 3. 390_UTF8AndTextModel.md

Define UTF-8 handling and text model:
- UTF-8 as the only source encoding
- Rune semantics
- Indexing rules (bytes only)
- Safe iteration helpers
- No implicit normalization
- FFI interaction

## 4. 400_ExecutorAndTasks_Phase2.md

Finalize concurrency model:
- Task scheduling semantics
- Task cancellation
- Deadline propagation
- Graceful shutdown
- Integration with blocking IO

## 5. ecosystem/010_CorePackagesCatalog.md

Catalog of all core ecosystem packages:
- Overview of packages for v1.0
- Dependencies between subsystems
- Core, Data, FFI, Testing, etc.
