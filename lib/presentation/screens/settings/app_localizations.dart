class AppLocalizations {
  final String locale;
  AppLocalizations(this.locale);

  static Map<String, Map<String, String>> _localizedValues = {
    'vi': {
      'settings': 'Cài đặt',
      'logout': 'Đăng xuất',
      'theme': 'Chủ đề',
      'language': 'Ngôn ngữ',
    },
    'en': {
      'settings': 'Settings',
      'logout': 'Logout',
      'theme': 'Theme',
      'language': 'Language',
    },
  };

  String get(String key) {
    return _localizedValues[locale]?[key] ?? key;
  }
}
