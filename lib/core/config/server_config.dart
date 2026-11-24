
enum Environment {
  dev,
  qa,
  staging,
  prod,
}

class ServerConfig {
  ServerConfig._();

  // Change environment here
  static const Environment environment = Environment.dev;

  // Firebase Firestore Collections
  static String get usersCollection => '${environment.name}_users';

  // Classes (lessons live inside each class: .../{classId}/lessons)
  static String get classesCollection => '${environment.name}_classes';
}
