import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

void main() {
  group('package version sync', () {
    late String pubspecVersion;

    setUpAll(() {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final match = RegExp(r'^version:\s*([^\s+#]+)', multiLine: true)
          .firstMatch(pubspec);
      expect(match, isNotNull, reason: 'pubspec.yaml must declare version');
      pubspecVersion = match!.group(1)!;
    });

    test('packageVersion matches pubspec.yaml', () {
      expect(packageVersion, pubspecVersion);
    });

    test('CHANGELOG.md mentions current version', () {
      final changelog = File('CHANGELOG.md').readAsStringSync();
      expect(
        changelog.contains('## $pubspecVersion'),
        isTrue,
        reason: 'CHANGELOG.md must include "## $pubspecVersion"',
      );
    });

    test('README install snippet uses current major.minor.patch floor', () {
      final readme = File('README.md').readAsStringSync();
      expect(
        readme.contains('flutter_liveness_actions: ^$pubspecVersion'),
        isTrue,
        reason: 'README install constraint should be ^$pubspecVersion',
      );
    });
  });
}
