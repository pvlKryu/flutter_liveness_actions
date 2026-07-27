# API stability (1.0.0)

`1.0.0` marks the **stable** public API listed in [API.md](API.md).

## SemVer policy

| Change type | Version bump |
| --- | --- |
| Bug fixes / docs / tests | Patch (`1.0.x`) |
| Additive APIs (optional params with defaults, new exports) | Minor (`1.x.0`) |
| Breaking renames / removals / required new params | Major (`2.0.0`) |
| Heuristic threshold tuning that preserves documented contracts | Patch or minor + CHANGELOG note |

## Guarantees

1. `LivenessActionSession` is the preferred integration facade.
2. Audit events stay privacy-safe: no raw images; `identityDecision` / `creditDecision` remain non-decisioning placeholders unless redesigned in a major version.
3. Stable guidance `messageKey` values in `GuidanceCatalog` are not renamed without a major bump.
4. Android/iOS only — web/desktop support would be a separate, explicitly versioned effort.

## Non-goals

- Identity verification, KYC, AML, fraud prevention, or credit decisioning
- Identical ML Kit timings across all devices
- Freezing internal detector heuristics byte-for-byte

## Ongoing validation

Maintainers should continue exercising the checklist in [DEVICE_TESTING.md](DEVICE_TESTING.md) when upgrading ML Kit, camera plugins, or Flutter major versions. See [PUBLISHING.md](PUBLISHING.md) for release steps.
