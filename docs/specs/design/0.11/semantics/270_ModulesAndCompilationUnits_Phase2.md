# 270. ModulesAndCompilationUnits - Phase 2

## 270.1. ori.mod

- Required fields:
  - `module <name>`
  - `ori x.y.z`
  - `require (<module-path> <revision>)`
- `<revision>` = SemVer or Git commit prefix
- Only one version per module allowed in `ori.mod`
- Importable modules MUST appear in `ori.mod`
- Transitive modules must NOT appear in `ori.mod`

## 270.2. `.vendor` Directory

The `.vendor` directory is always stored into the developer repository.

- Location: `.vendor/<module-path>/<revision>/`
- Revision = SemVer or commit
- Contains only:
  - `*.ori`
  - `ori.mod`
  - legal files: *LICENSE*, COPYING*, *NOTICE* (case-insensitive)
- Everything else stripped
- Symlinks forbidden → download error

## 270.3. Import Resolution

- Import path example:
  `import "github.com/foo/bar/util"`
- Resolve to:
  `.vendor/github.com/foo/bar/<revision>/util/`
- No version in import path
- Only modules listed in `ori.mod` can be imported

## 270.4. Sanitization

Kept:
- `.ori`
- `ori.mod`
- files matching LICENSE / COPYING / NOTICE (case incensitive)
Removed:
- Hidden files
- Assets
- Configs
- Scripts
- Build files
- Everything else

## 270.5. Hashing in ori.sum

- Hash only `.ori` and `ori.mod`
- Manifest generated from sorted paths:
  `<path>\n<size>\n<sha256(content)>\n`
- Final hash = sha256(manifest), base64-encoded:  `sha256:<hash>`
- Each module entry: `<module-path> <revision> sha256:<hash>`

## 270.6. Transitive Dependencies

- Transitives resolved recursively from each dependency’s `ori.mod`
- Added to `.vendor` and `ori.sum`
- Multi-version transitives allowed
- Conflict only if user imports the module

## 270.7. Forbidden

- Nested ori.mod
- Multiple versions of same direct module
- Missing ori.mod in dependency
- Hidden imports not listed in root ori.mod

## 270.8. Security

- HTTPS-only
- Strict TLS
- No scripts, no codegen
- No symlinks
- Deterministic builds
