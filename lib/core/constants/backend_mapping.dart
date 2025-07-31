
class BackendValues {
  static const Map<String, String> _frontendToBackendAgeMapping = {
    'less than 20s': 'Under 18',
    '20s': '18-24',
    '30s': '25-34',
    '40s': '35-44',
    '50s and above': '45-54',

    'Under 18': 'Under 18',
    '18-24': '18-24',
    '25-34': '25-34',
    '35-44': '35-44',
    '45-54': '45-54',
    '55-64': '55-64',
    '65+': '65+',

    'Under 25': '18-24',
'55+': '55-64', 
  };

  static const Map<String, String> _backendToFrontendAgeMapping = {
    'Under 18': 'less than 20s',
    '18-24': '20s',
    '25-34': '30s',
    '35-44': '40s',
    '45-54': '50s and above',
'55-64': '50s and above', 
'65+': '50s and above', 
  };

  static const Map<String, String> _pronounMapping = {
    'She / Her': 'She / Her',
    'He / Him': 'He / Him', 
    'They / Them': 'They / Them',
    'Other': 'Other',
    'she/her': 'She / Her',
    'he/him': 'He / Him',
    'they/them': 'They / Them',
    'other': 'Other',
  };

  static const Map<String, String> _avatarMapping = {
    'panda': 'panda',
'elephant': 'elephant', 
'horse': 'horse', 
    'rabbit': 'rabbit',
    'fox': 'fox',
'zebra': 'zebra', 
    'bear': 'bear',
'pig': 'pig', 
'raccoon': 'raccoon', 
    'cat': 'cat',
    'dog': 'dog',
    'owl': 'owl',
    'penguin': 'penguin',
  };

  static String getBackendAgeGroup(String? frontendAgeGroup) {
    if (frontendAgeGroup == null || frontendAgeGroup.isEmpty) {
return '18-24'; 
    }
    return _frontendToBackendAgeMapping[frontendAgeGroup] ?? '18-24';
  }

  static String getFrontendAgeGroup(String? backendAgeGroup) {
    if (backendAgeGroup == null || backendAgeGroup.isEmpty) {
return '20s'; 
    }
    return _backendToFrontendAgeMapping[backendAgeGroup] ?? '20s';
  }

  static String getBackendPronouns(String? frontendPronouns) {
    if (frontendPronouns == null || frontendPronouns.isEmpty) {
return 'They / Them'; 
    }
    return _pronounMapping[frontendPronouns] ?? 'They / Them';
  }

  static String getFrontendPronouns(String? backendPronouns) {
    if (backendPronouns == null || backendPronouns.isEmpty) {
return 'They / Them'; 
    }
    return _pronounMapping[backendPronouns] ?? 'They / Them';
  }

  static String getBackendAvatar(String? frontendAvatar) {
    if (frontendAvatar == null || frontendAvatar.isEmpty) {
return 'panda'; 
    }
    return _avatarMapping[frontendAvatar] ?? 'panda';
  }

  static String getFrontendAvatar(String? backendAvatar) {
    if (backendAvatar == null || backendAvatar.isEmpty) {
return 'panda'; 
    }
    return _avatarMapping[backendAvatar] ?? 'panda';
  }

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

  static List<String> get validBackendAgeGroups =>
      _backendToFrontendAgeMapping.keys.toList();

  static List<String> get validFrontendAgeGroups =>
      _frontendToBackendAgeMapping.keys.toList();

  static List<String> get validPronouns => _pronounMapping.keys.toList();

  static List<String> get validAvatars => _avatarMapping.keys.toList();

  static String normalizeAgeGroupFromApi(String? apiValue) {
    if (apiValue == null) return '18-24';

    if (_backendToFrontendAgeMapping.containsKey(apiValue)) {
      return apiValue;
    }

    if (_frontendToBackendAgeMapping.containsKey(apiValue)) {
      return _frontendToBackendAgeMapping[apiValue]!;
    }

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
return '18-24'; 
    }
  }

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
