// lib/core/constants/backend_values.dart
// These are the EXACT values your backend expects

class BackendValues {
  // FIXED: Backend expects these exact age group values
  static const Map<String, String> ageGroupMapping = {
    'less than 20s': 'Under 18',
    '20s': '18-24',
    '30s': '25-34',
    '40s': '35-44',
    '50s and above': '45-54',
    // Add direct mappings for backend values
    'Under 18': 'Under 18',
    '18-24': '18-24',
    '25-34': '25-34',
    '35-44': '35-44',
    '45-54': '45-54',
    '55-64': '55-64',
    '65+': '65+',
  };

  // FIXED: Backend expects these exact avatar values
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
    // Add direct mappings for backend values
    'cat': 'cat',
    'dog': 'dog',
    'owl': 'owl',
    'penguin': 'penguin',
  };

  // FIXED: Backend expects pronouns with spaces, not without
  static const Map<String, String> pronounMapping = {
    'She / Her': 'She / Her',
    'He / Him': 'He / Him',
    'They / Them': 'They / Them',
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
    if (frontendPronouns == null) return 'They / Them';
    return pronounMapping[frontendPronouns] ?? 'They / Them';
  }

  // Reverse mapping for display
  static String getFrontendAgeGroup(String? backendAgeGroup) {
    if (backendAgeGroup == null) return '20s';
    
    // Reverse lookup
    for (final entry in ageGroupMapping.entries) {
      if (entry.value == backendAgeGroup) {
        return entry.key;
      }
    }
    return '20s'; // Default fallback
  }

  static String getFrontendAvatar(String? backendAvatar) {
    if (backendAvatar == null) return 'panda';
    
    // Reverse lookup
    for (final entry in avatarMapping.entries) {
      if (entry.value == backendAvatar) {
        return entry.key;
      }
    }
    return 'panda'; // Default fallback
  }

  static String getFrontendPronouns(String? backendPronouns) {
    if (backendPronouns == null) return 'They / Them';
    
    // Reverse lookup
    for (final entry in pronounMapping.entries) {
      if (entry.value == backendPronouns) {
        return entry.key;
      }
    }
    return 'They / Them'; // Default fallback
  }
}
