// lib/core/constants/backend_values.dart
// These are the EXACT values your backend expects

class BackendValues {
  // EXACT age groups from your backend error: ["Under 18","18-24","25-34","35-44","45-54","55-64","65+"]
  static const Map<String, String> ageGroupMapping = {
    'less than 20s': 'Under 18',
    '20s': '18-24',
    '30s': '25-34',
    '40s': '35-44',
    '50s and above': '45-54',
  };

  // EXACT avatars from your backend error: ["panda","cat","dog","rabbit","fox","bear","owl","penguin"]
  static const Map<String, String> avatarMapping = {
    'panda': 'panda',
    'elephant': 'panda', // Map to closest valid option
    'horse': 'cat',
    'rabbit': 'rabbit',
    'fox': 'fox',
    'zebra': 'cat',
    'bear': 'bear',
    'pig': 'cat',
    'raccoon': 'cat',
  };

  // Fix pronouns format (remove spaces)
  static const Map<String, String> pronounMapping = {
    'She / Her': 'She/Her',
    'He / Him': 'He/Him',
    'They / Them': 'They/Them',
    'Other': 'Other',
  };

  // Convert methods
  static String getBackendAgeGroup(String? frontendAgeGroup) {
    if (frontendAgeGroup == null) return '18-24';
    return ageGroupMapping[frontendAgeGroup] ?? '18-24';
  }

  static String getBackendAvatar(String? frontendAvatar) {
    if (frontendAvatar == null) return 'panda';
    return avatarMapping[frontendAvatar] ?? 'panda';
  }

  static String getBackendPronouns(String? frontendPronouns) {
    if (frontendPronouns == null) return 'They/Them';
    return pronounMapping[frontendPronouns] ?? 'They/Them';
  }
}
