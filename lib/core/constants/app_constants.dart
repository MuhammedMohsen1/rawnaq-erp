class AppConstants {
  // App Information
  static const String appName = 'Been Edeek Portal';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = 'http://127.0.0.1:3000';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;

  // Storage Keys
  static const String tokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String languageKey = 'language';
  static const String themeKey = 'theme';
  static const String onboardingKey = 'onboarding_completed';
  static const String fcmTokenKey = 'fcm_device_token';
  static const String fcmTokenRefreshTimeKey = 'fcm_token_refresh_time';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;

  // Image Configuration
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];

  // Cache Duration
  static const Duration cacheExpiration = Duration(hours: 24);
  static const Duration refreshCacheExpiration = Duration(days: 7);

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Debounce Duration
  static const Duration searchDebounce = Duration(milliseconds: 500);

  // Order Status
  static const String orderPending = 'pending';
  static const String orderPreparing = 'preparing';
  static const String orderReady = 'ready';
  static const String orderPickedUp = 'picked_up';
  static const String orderDelivered = 'delivered';
  static const String orderCancelled = 'cancelled';

  // Food Item Availability
  static const String available = 'available';
  static const String unavailable = 'unavailable';
  static const String soldOut = 'sold_out';

  // User Roles
  static const String adminRole = 'admin';
  static const String managerRole = 'manager';
  static const String seniorEngineerRole = 'senior_engineer';
  static const String juniorEngineerRole = 'junior_engineer';
  static const String siteEngineerRole = 'site_engineer';
  static const String staffRole = 'staff';

  // Admin Sub-Roles
  static const String systemAdminSubRole = 'system_admin';
  static const String projectAdminSubRole = 'project_admin';
  static const String financialAdminSubRole = 'financial_admin';
  static const String technicalAdminSubRole = 'technical_admin';

  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'h:mm a';
  static const String dateTimeFormat = 'dd/MM/yyyy h:mm a';
  static const String apiDateFormat = 'yyyy-MM-ddTHH:mm:ss.SSSZ';

  // Validation Patterns
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^\+?[1-9]\d{1,14}$';
  static const String passwordPattern =
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$';

  // رسائل الأخطاء
  static const String networkError =
      'فشل الاتصال بالشبكة. يرجى التحقق من اتصال الإنترنت.';
  static const String serverError = 'حدث خطأ في الخادم. يرجى المحاولة لاحقًا.';
  static const String unknownError =
      'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
  static const String timeoutError =
      'انتهت مهلة الطلب. يرجى المحاولة مرة أخرى.';
  static const String unauthorizedError =
      'دخول غير مصرح به. يرجى تسجيل الدخول مرة أخرى.';

  // رسائل النجاح
  static const String loginSuccess = 'تم تسجيل الدخول بنجاح';
  static const String logoutSuccess = 'تم تسجيل الخروج بنجاح';
  static const String updateSuccess = 'تم التحديث بنجاح';
  static const String deleteSuccess = 'تم الحذف بنجاح';
  static const String createSuccess = 'تم الإنشاء بنجاح';
}
