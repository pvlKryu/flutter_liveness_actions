# API stability (0.9.0 RC)

`0.9.0` is a **release candidate**. The public API listed in [API.md](API.md) is considered freeze-candidate for `1.0.0`.

## Compatibility policy

| Change type | Allowed in 0.9.x | Requires |
| --- | --- | --- |
| Bug fixes / docs / tests | Yes | Patch or minor within 0.9.x |
| Additive APIs (new optional params with defaults, new exports) | Yes | Prefer minor |
| Behavior fixes that preserve documented contracts | Yes | Document in CHANGELOG |
| Breaking renames / removals / required new params | No after 0.9.0 | `1.0.0` or later major |
| Heuristic tuning (thresholds) | Yes, with CHANGELOG note | May affect challenge timing |

## Guarantees

1. `LivenessActionSession` remains the preferred integration facade.
2. Audit events stay privacy-safe: no raw images; `identityDecision` / `creditDecision` remain non-decisioning placeholders unless explicitly redesigned in a major version.
3. Stable guidance `messageKey` values in `GuidanceCatalog` are not renamed without a major bump.
4. Android/iOS only — web/desktop support would be a separate effort, not a silent addition.

## Non-goals until 1.0.0

- Claiming identity verification / KYC fitness
- Guaranteeing identical ML Kit timings across all devices
- Freezing internal detector heuristics byte-for-byte

## Path to 1.0.0

1. Complete device matrix runs in [DEVICE_TESTING.md](DEVICE_TESTING.md)
2. External API / privacy review
3. Confirm CI green on Flutter stable
4. Tag `1.0.0` and publish to pub.dev
