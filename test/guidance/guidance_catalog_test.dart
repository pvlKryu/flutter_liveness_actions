import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

void main() {
  group('GuidanceCatalog', () {
    test('provides stable message keys for all guidance codes', () {
      for (final message in GuidanceCatalog.allMessages()) {
        expect(message.messageKey.startsWith('guidance.'), isTrue);
        expect(message.defaultEnglishText, isNotEmpty);
      }
      expect(GuidanceCatalog.allMessages().length, GuidanceCode.values.length);
    });

    test('resolveText uses localize callback when provided', () {
      final message = GuidanceCatalog.messageFor(GuidanceCode.moveCloser);
      final resolved = message.resolveText(
        (key) => key == 'guidance.move_closer' ? 'Подойдите ближе' : key,
      );
      expect(resolved, 'Подойдите ближе');
    });

    test('includes accessibility metadata', () {
      final message = GuidanceCatalog.messageFor(GuidanceCode.centerFace);
      expect(message.semanticLabel, isNotNull);
      expect(message.highContrastLabel, isNotNull);
    });
  });
}
