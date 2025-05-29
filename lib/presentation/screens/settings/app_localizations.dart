class AppLocalizations {
  final String locale;
  AppLocalizations(this.locale);

  static Map<String, Map<String, String>> _localizedValues = {
    'vi': {
      'settings': 'Cài đặt',
      'logout': 'Đăng xuất',
      'theme': 'Chủ đề',
      'language': 'Ngôn ngữ',
      'home': 'Trang chủ',
      'discovery': 'Khám phá',
      'account': 'Tài khoản',
      'search_hint': 'Tìm kiếm bài hát hoặc tác giả...',
      'not_found': 'Không tìm thấy bài hát nào',
    },
    'en': {
      'settings': 'Settings',
      'logout': 'Logout',
      'theme': 'Theme',
      'language': 'Language',
      'home': 'Home',
      'discovery': 'Discovery',
      'account': 'Account',
      'search_hint': 'Search for songs or artists...',
      'not_found': 'No songs found',
    },
  };

  String get(String key) {
    return _localizedValues[locale]?[key] ?? key;
  }
}
