/// Utility class to translate API response codes to localized messages
class ResponseCodeTranslator {
  static const Map<String, Map<String, String>> _translations = {
    // Success codes
    'SUCCESS': {
      'en': 'Operation completed successfully',
      'ar': 'تمت العملية بنجاح',
    },
    'LOGIN_SUCCESS': {'en': 'Login successful', 'ar': 'تم تسجيل الدخول بنجاح'},
    'LOGOUT_SUCCESS': {
      'en': 'Logout successful',
      'ar': 'تم تسجيل الخروج بنجاح',
    },
    'LOGOUT_ALL_SUCCESS': {
      'en': 'Logged out from all devices',
      'ar': 'تم تسجيل الخروج من جميع الأجهزة',
    },
    'TOKEN_REFRESHED': {
      'en': 'Token refreshed successfully',
      'ar': 'تم تحديث الرمز بنجاح',
    },
    'PASSWORD_RESET_SENT': {
      'en': 'If the email exists, a reset link has been sent',
      'ar': 'إذا كان البريد الإلكتروني موجوداً، تم إرسال رابط إعادة التعيين',
    },
    'USER_PROFILE_RETRIEVED': {
      'en': 'User profile retrieved successfully',
      'ar': 'تم جلب بيانات المستخدم بنجاح',
    },
    'USER_SESSIONS_RETRIEVED': {
      'en': 'User sessions retrieved successfully',
      'ar': 'تم جلب جلسات المستخدم بنجاح',
    },
    'ORDER_CREATED': {
      'en': 'Order created successfully',
      'ar': 'تم إنشاء الطلب بنجاح',
    },

    // Error codes
    'INVALID_CREDENTIALS': {
      'en': 'Invalid email or password',
      'ar': 'البريد الإلكتروني أو كلمة المرور غير صحيحة',
    },
    'UNAUTHORIZED': {'en': 'Unauthorized access', 'ar': 'غير مصرح بالوصول'},
    'NOT_FOUND': {'en': 'Resource not found', 'ar': 'المورد غير موجود'},
    'BAD_REQUEST': {'en': 'Bad request', 'ar': 'طلب غير صالح'},
    'FORBIDDEN': {'en': 'Access forbidden', 'ar': 'الدخول مرفوض'},
    'INTERNAL_SERVER_ERROR': {
      'en': 'Internal server error',
      'ar': 'خطأ في الخادم',
    },
    'ERROR': {'en': 'An error occurred', 'ar': 'حدث خطأ'},
    'VALIDATION_ERROR': {
      'en': 'Validation error',
      'ar': 'خطأ في التحقق من البيانات',
    },
    'NETWORK_ERROR': {'en': 'Network error', 'ar': 'خطأ في الاتصال بالشبكة'},
    'TIMEOUT': {'en': 'Request timeout', 'ar': 'انتهت مهلة الطلب'},
  };

  /// Translate a response code to a localized message
  ///
  /// [code] - The response code (e.g., 'LOGIN_SUCCESS', 'UNAUTHORIZED')
  /// [locale] - The locale code ('en' or 'ar'), defaults to 'ar'
  ///
  /// Returns the translated message or the code itself if translation not found
  static String translate(String code, {String locale = 'ar'}) {
    final translation = _translations[code];
    if (translation == null) {
      // If code not found, return the code itself
      return code;
    }
    return translation[locale] ?? translation['ar'] ?? code;
  }

  /// Get all available codes
  static List<String> getAvailableCodes() {
    return _translations.keys.toList();
  }
}
