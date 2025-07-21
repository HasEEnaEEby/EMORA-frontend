// lib/core/constants/backend_mapping.dart
// FIXED: Aligned with backend model schema

class BackendValues {
  // FIXED: Backend expects these exact age group values (from user.model.js)
  static const Map<String, String> _frontendToBackendAgeMapping = {
    // Frontend display values -> Backend database values
    'less than 20s': 'Under 18',
    '20s': '18-24',
    '30s': '25-34',
    '40s': '35-44',
    '50s and above': '45-54',

    // Additional mappings for edge cases
    'Under 18': 'Under 18',
    '18-24': '18-24',
    '25-34': '25-34',
    '35-44': '35-44',
    '45-54': '45-54',
    '55-64': '55-64',
    '65+': '65+',

    // Legacy mappings (if any old data exists)
    'Under 25': '18-24',
    '55+': '55-64', // Map old 55+ to 55-64
  };

  // Reverse mapping for displaying backend values
  static const Map<String, String> _backendToFrontendAgeMapping = {
    'Under 18': 'less than 20s',
    '18-24': '20s',
    '25-34': '30s',
    '35-44': '40s',
    '45-54': '50s and above',
    '55-64': '50s and above', // Group both 45-54 and 55-64 as "50s and above"
    '65+': '50s and above', // Group 65+ also as "50s and above"
  };

  // . FIXED: Backend expects pronouns with spaces (from user.model.js)
  static const Map<String, String> _pronounMapping = {
    'She / Her': 'She / Her',
    'He / Him': 'He / Him', 
    'They / Them': 'They / Them',
    'Other': 'Other',
    // Legacy mappings for migration (old format -> new format)
    'she/her': 'She / Her',
    'he/him': 'He / Him',
    'they/them': 'They / Them',
    'other': 'Other',
  };

  // FIXED: All valid avatars from backend model
  static const Map<String, String> _avatarMapping = {
    'panda': 'panda',
    'elephant': 'elephant', // Keep as-is since it's valid in backend
    'horse': 'horse', // Keep as-is since it's valid in backend
    'rabbit': 'rabbit',
    'fox': 'fox',
    'zebra': 'zebra', // Keep as-is since it's valid in backend
    'bear': 'bear',
    'pig': 'pig', // Keep as-is since it's valid in backend
    'raccoon': 'raccoon', // Keep as-is since it's valid in backend
    'cat': 'cat',
    'dog': 'dog',
    'owl': 'owl',
    'penguin': 'penguin',
  };

  // Public methods for age group conversion
  static String getBackendAgeGroup(String? frontendAgeGroup) {
    if (frontendAgeGroup == null || frontendAgeGroup.isEmpty) {
      return '18-24'; // Default fallback
    }
    return _frontendToBackendAgeMapping[frontendAgeGroup] ?? '18-24';
  }

  static String getFrontendAgeGroup(String? backendAgeGroup) {
    if (backendAgeGroup == null || backendAgeGroup.isEmpty) {
      return '20s'; // Default fallback
    }
    return _backendToFrontendAgeMapping[backendAgeGroup] ?? '20s';
  }

  // Public methods for pronoun conversion
  static String getBackendPronouns(String? frontendPronouns) {
    if (frontendPronouns == null || frontendPronouns.isEmpty) {
      return 'They / Them'; // Default fallback
    }
    return _pronounMapping[frontendPronouns] ?? 'They / Them';
  }

  static String getFrontendPronouns(String? backendPronouns) {
    if (backendPronouns == null || backendPronouns.isEmpty) {
      return 'They / Them'; // Default fallback
    }
    // Pronouns are the same for both frontend and backend
    return _pronounMapping[backendPronouns] ?? 'They / Them';
  }

  // Public methods for avatar conversion
  static String getBackendAvatar(String? frontendAvatar) {
    if (frontendAvatar == null || frontendAvatar.isEmpty) {
      return 'panda'; // Default fallback
    }
    return _avatarMapping[frontendAvatar] ?? 'panda';
  }

  static String getFrontendAvatar(String? backendAvatar) {
    if (backendAvatar == null || backendAvatar.isEmpty) {
      return 'panda'; // Default fallback
    }
    // Avatars are the same for both frontend and backend
    return _avatarMapping[backendAvatar] ?? 'panda';
  }

  // Validation methods
  static bool isValidBackendAgeGroup(String? ageGroup) {
    if (ageGroup == null) return false;
    return _backendToFrontendAgeMapping.containsKey(ageGroup);
  }

  static bool isValidFrontendAgeGroup(String? ageGroup) {
    if (ageGroup == null) return false;
    return _frontendToBackendAgeMapping.containsKey(ageGroup);
  }

  static bool isValidPronouns(String? pronouns) {
    if (pronouns == null) return false;
    return _pronounMapping.containsKey(pronouns);
  }

  static bool isValidAvatar(String? avatar) {
    if (avatar == null) return false;
    return _avatarMapping.containsKey(avatar);
  }

  // Get all valid values
  static List<String> get validBackendAgeGroups =>
      _backendToFrontendAgeMapping.keys.toList();

  static List<String> get validFrontendAgeGroups =>
      _frontendToBackendAgeMapping.keys.toList();

  static List<String> get validPronouns => _pronounMapping.keys.toList();

  static List<String> get validAvatars => _avatarMapping.keys.toList();

  // Helper method to validate and convert age group from API response
  static String normalizeAgeGroupFromApi(String? apiValue) {
    if (apiValue == null) return '18-24';

    // If it's already a valid backend value, return it
    if (_backendToFrontendAgeMapping.containsKey(apiValue)) {
      return apiValue;
    }

    // If it's a frontend value, convert to backend
    if (_frontendToBackendAgeMapping.containsKey(apiValue)) {
      return _frontendToBackendAgeMapping[apiValue]!;
    }

    // Handle common variations
    switch (apiValue.toLowerCase().replaceAll(' ', '').replaceAll('-', '')) {
      case 'under18':
      case 'lessthan20s':
        return 'Under 18';
      case '1824':
      case '20s':
        return '18-24';
      case '2534':
      case '30s':
        return '25-34';
      case '3544':
      case '40s':
        return '35-44';
      case '4554':
      case '50sandabove':
        return '45-54';
      case '5564':
        return '55-64';
      case '65+':
      case '65plus':
        return '65+';
      default:
        return '18-24'; // Safe default
    }
  }

  // Debug helper methods
  static void printAllMappings() {
    print('. Frontend to Backend Age Mappings:');
    _frontendToBackendAgeMapping.forEach((key, value) {
      print('  "$key" -> "$value"');
    });

    print('\n. Backend to Frontend Age Mappings:');
    _backendToFrontendAgeMapping.forEach((key, value) {
      print('  "$key" -> "$value"');
    });

    print('\n. Pronoun Mappings:');
    _pronounMapping.forEach((key, value) {
      print('  "$key" -> "$value"');
    });

    print('\n. Avatar Mappings:');
    _avatarMapping.forEach((key, value) {
      print('  "$key" -> "$value"');
    });
  }
}
