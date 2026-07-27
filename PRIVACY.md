# Privacy

## Principles

- **Derived signals only** — core APIs expose interaction signals, not raw camera bytes.
- **No raw image storage** — the package does not store face images by default.
- **No raw image upload** — no network upload is performed by the package.
- **No backend required** — all processing can run on-device.
- **Audit-friendly events** — `OnboardingAuditEvent` includes privacy flags such as `rawImagesStored: false`.

## Example app

The bundled example processes signals locally and is intended for developer demos.

## Developer responsibility

You are responsible for your app-level privacy policy, consent flows, data retention, and compliance with applicable laws. If you store or transmit images outside this package, that is your responsibility.

See also [SECURITY.md](SECURITY.md) and [DISCLAIMER.md](DISCLAIMER.md).
