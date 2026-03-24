/// Runtime environment configuration via --dart-define flags.
///
/// Usage:
/// ```bash
/// # Development (default)
/// flutter run
///
/// # Production
/// flutter run --dart-define=API_BASE_URL=https://your-app.onrender.com/api/v1
///
/// # Release build
/// flutter build apk --dart-define=API_BASE_URL=https://your-app.onrender.com/api/v1
/// flutter build ios --dart-define=API_BASE_URL=https://your-app.onrender.com/api/v1
/// ```
class EnvConfig {
  const EnvConfig._();

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api/v1',
  );
}
