# Publishing checklist (pub.dev)

Use before publishing `1.0.0` (and optionally to dry-run at `0.9.0`).

## Pre-flight

- [ ] `CHANGELOG.md` has the release section
- [ ] `pubspec.yaml` `version` matches `lib/src/version.dart` `packageVersion`
- [ ] README install snippet uses the release version
- [ ] [doc/API.md](API.md) / [STABILITY.md](STABILITY.md) reflect the freeze
- [ ] Disclaimer / privacy wording still accurate

## Local commands

```bash
flutter pub get
dart format --set-exit-if-changed .   # use Dart from the Flutter SDK
flutter analyze
flutter test
cd example && flutter analyze && cd ..
flutter pub publish --dry-run
```

## CI

GitHub Actions must be green on `main` (format, analyze, test, example analyze).

## Device

Complete at least P0 rows in [DEVICE_TESTING.md](DEVICE_TESTING.md) before `1.0.0`.

## Publish

```bash
flutter pub publish
```

Do not publish until the package owner explicitly requests it.
