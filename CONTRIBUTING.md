# Contributing

Thanks for your interest in contributing to `flutter_liveness_actions`.

## Scope

This package targets **Android and iOS** mobile Flutter apps. Please avoid adding web/desktop support in v0.1.x unless discussed in an issue first.

## Guidelines

- Keep the core logic pure Dart and testable without a device.
- Do not add raw image storage or upload to core APIs.
- Avoid identity verification, KYC, AML, or fraud-prevention claims in code and docs.
- Add unit tests for behavioral changes.
- Run `dart format .`, `flutter analyze`, and `flutter test` before opening a PR.

## Pull requests

1. Open an issue for large changes when possible.
2. Keep PRs focused and reviewable.
3. Update `CHANGELOG.md` for user-visible changes.

See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).
