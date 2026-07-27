# Publishing checklist (pub.dev)

Use before publishing stable releases (`1.0.0` and later).

## Pre-flight

- [ ] `CHANGELOG.md` has the release section
- [ ] `pubspec.yaml` `version` matches `lib/src/version.dart` `packageVersion`
- [ ] README install snippet uses the release version
- [ ] [API.md](API.md) / [STABILITY.md](STABILITY.md) reflect the freeze
- [ ] Disclaimer / privacy wording still accurate
- [ ] Working tree is clean (`git status`)

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

GitHub Actions must be green on `main` (format, analyze, test, example analyze, publish dry-run).

## Device

Re-run P0 rows in [DEVICE_TESTING.md](DEVICE_TESTING.md) when camera / ML Kit / Flutter majors change.

## Publish

```bash
flutter pub publish
```

Only publish when the package owner explicitly requests it.
