/// Test credentials for development and testing
class TestCredentials {
  // Default test login credentials
  static const String testEmail = 'manager.burger@example.com';
  static const String testPassword = 'password123';

  // Additional test users (for future use)
  static const Map<String, String> testUsers = {
    'manager.burger@example.com': 'password123',
    'admin@example.com': 'admin123',
    'staff@example.com': 'staff123',
  };

  /// Get test credentials for quick login during development
  static Map<String, String> getDefaultCredentials() {
    return {'email': testEmail, 'password': testPassword};
  }
}
