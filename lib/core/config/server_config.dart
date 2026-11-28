enum Environment {
  dev,
  qa,
  staging,
  prod,
}

class ServerConfig {
  ServerConfig._();

  static const Environment environment = Environment.dev;

  static String get usersCollection => '${environment.name}_users';

  static String get classesCollection => '${environment.name}_classes';

  static String get eventsCollection => '${environment.name}_events';

  static String get eventRegistrationsCollection =>
      '${environment.name}_event_registrations';

  // Community feature
  static String get communitiesCollection =>
      '${environment.name}_communities';

  static String get communityStorageRoot =>
      '${environment.name}_communities';
   static String get supportMessagesCollection => '${environment.name}_support_messages';
}