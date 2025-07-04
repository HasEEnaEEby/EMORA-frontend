import 'package:flutter_test/flutter_test.dart';
import 'package:emora_mobile_app/core/constants/backend_mapping.dart';

void main() {
  group('BackendValues', () {
    test('should map frontend age groups to backend values correctly', () {
      expect(BackendValues.getBackendAgeGroup('less than 20s'), equals('Under 18'));
      expect(BackendValues.getBackendAgeGroup('20s'), equals('18-24'));
      expect(BackendValues.getBackendAgeGroup('30s'), equals('25-34'));
      expect(BackendValues.getBackendAgeGroup('40s'), equals('35-44'));
      expect(BackendValues.getBackendAgeGroup('50s and above'), equals('45-54'));
      expect(BackendValues.getBackendAgeGroup(null), equals('18-24'));
      expect(BackendValues.getBackendAgeGroup('invalid'), equals('18-24'));
    });

    test('should map frontend pronouns to backend values correctly', () {
      expect(BackendValues.getBackendPronouns('She / Her'), equals('She/Her'));
      expect(BackendValues.getBackendPronouns('He / Him'), equals('He/Him'));
      expect(BackendValues.getBackendPronouns('They / Them'), equals('They/Them'));
      expect(BackendValues.getBackendPronouns('Other'), equals('Other'));
      expect(BackendValues.getBackendPronouns(null), equals('They/Them'));
      expect(BackendValues.getBackendPronouns('invalid'), equals('They/Them'));
    });

    test('should map frontend avatars to backend values correctly', () {
      expect(BackendValues.getBackendAvatar('panda'), equals('panda'));
      expect(BackendValues.getBackendAvatar('elephant'), equals('panda'));
      expect(BackendValues.getBackendAvatar('horse'), equals('cat'));
      expect(BackendValues.getBackendAvatar('rabbit'), equals('rabbit'));
      expect(BackendValues.getBackendAvatar('fox'), equals('fox'));
      expect(BackendValues.getBackendAvatar('bear'), equals('bear'));
      expect(BackendValues.getBackendAvatar(null), equals('panda'));
      expect(BackendValues.getBackendAvatar('invalid'), equals('panda'));
    });

    test('should map backend values back to frontend values correctly', () {
      expect(BackendValues.getFrontendAgeGroup('Under 18'), equals('less than 20s'));
      expect(BackendValues.getFrontendAgeGroup('18-24'), equals('20s'));
      expect(BackendValues.getFrontendAgeGroup('25-34'), equals('30s'));
      expect(BackendValues.getFrontendAgeGroup('35-44'), equals('40s'));
      expect(BackendValues.getFrontendAgeGroup('45-54'), equals('50s and above'));
      expect(BackendValues.getFrontendAgeGroup(null), equals('20s'));
      expect(BackendValues.getFrontendAgeGroup('invalid'), equals('20s'));
    });
  });
} 