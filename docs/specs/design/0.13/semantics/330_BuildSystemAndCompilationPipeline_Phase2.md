# 330 BuildSystemAndCompilationPipeline - Phase 2

## 1. ori mod download

- Fetch dependencies using:
  `git clone --depth=1 --branch <tag> <https-url>`
- For commits:
  `git clone --depth=1 --revision <sha> <https-url>`
- HTTPS-only, strict TLS
- Timeout: 10s, Retries: 3
- Remove `.git/`
- Sanitize according to spec
- Hash `.ori` + `ori.mod`
- Update `ori.sum` atomically

Git command is used instead of fetching tarballs because not all repository providers provides fetching tarballs.  
It's then save to use only `git clone` command

## 2. Build rules

- `ori build` NEVER downloads
- `ori build` verifies:
  - `.vendor` exists
  - Hash matches `ori.sum`
  - No unexpected vendor files
- Build fails on mismatch

## 3. Output

Same as Phase 1:
- `build/<arch>/<os>/<opt>/<module>/bin/`
- No changes

## 4. Transitive Expansion

- Dependencies’ ori.mod processed recursively
- Transitive versions may conflict only if directly imported
- All transitives must appear in `.vendor` and `ori.sum`

## 5. Hash Verification

- At build time:
  - Recompute hashes
  - Compare to `ori.sum`
  - Fail on mismatch, missing, or extra folders

## 6. Security

- No execution of dependency scripts
- No dynamic behavior
- No fallbacks
- Fully deterministic, offline builds

## 7. Error Cases

- Missing ori.mod
- ori-specified version > compiler version
- Missing vendor folder
- Checksum mismatch
- Symlink found in dependency
