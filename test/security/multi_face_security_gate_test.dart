import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

import '../test_helpers.dart';

void main() {
  group('MultiFaceSecurityGate', () {
    const gate = MultiFaceSecurityGate();

    test('does not violate for zero or one face', () {
      expect(gate.evaluate(faceCount: 0).violated, isFalse);
      expect(gate.evaluate(faceCount: 1).violated, isFalse);
    });

    test('violates when faceCount > 1', () {
      final result = gate.evaluate(
        faceCount: 2,
        timestamp: DateTime(2026, 1, 1),
      );
      expect(result.violated, isTrue);
      expect(
        result.violationCode,
        SecurityViolationCode.multiFaceDetected,
      );
      expect(result.faceCount, 2);
    });

    test('evaluateFrame uses FaceActionFrame.faceCount', () {
      final result = gate.evaluateFrame(TestFrames.multipleFaces());
      expect(result.violated, isTrue);
    });

    test('locks challenge and records audit without retries', () async {
      final controller = ChallengeFlowController(
        config: const FaceChallengeConfig(maxRetriesPerStep: 3),
      );
      final builder = AuditEventBuilder(
        sessionId: 's1',
        sequenceId: controller.sequence.sequenceId,
        packageVersion: '1.2.0',
      );
      final events = <FaceChallengeEventType>[];
      controller.events.listen((e) => events.add(e.type));

      final result = gate.apply(
        faceCount: 2,
        controller: controller,
        auditBuilder: builder,
        timestamp: DateTime(2026, 1, 1, 12),
      );

      await Future<void>.delayed(Duration.zero);

      expect(result.violated, isTrue);
      expect(controller.isCompromised, isTrue);
      expect(controller.state.compromised, isTrue);
      expect(controller.state.failed, isTrue);
      expect(
        controller.state.failureReason,
        ChallengeFailureReason.securityCompromised,
      );
      expect(
        controller.state.securityViolation,
        SecurityViolationCode.multiFaceDetected,
      );
      expect(events, contains(FaceChallengeEventType.challengeCompromised));

      // Compromised challenges ignore further signals / retries.
      controller.processSignal(signalForStep(FaceActionType.centerFace));
      controller.retryCurrentStep();
      expect(controller.state.compromised, isTrue);

      final audit = builder.build(
        challengeState: controller.state,
        faceDetected: true,
        multipleFacesDetected: true,
        diagnostics: const LivenessDiagnostics(),
        performanceConfig: PerformanceConfig.balanced(),
      );
      expect(
        audit.securityViolation,
        SecurityViolationCode.multiFaceDetected,
      );
      expect(
        audit.events.any((e) => e['type'] == 'securityViolation'),
        isTrue,
      );

      controller.dispose();
    });

    test('can be disabled via failOnMultipleFaces: false', () {
      const soft = MultiFaceSecurityGate(failOnMultipleFaces: false);
      expect(soft.evaluate(faceCount: 3).violated, isFalse);
    });
  });
}
