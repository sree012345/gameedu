import 'package:shared_preferences/shared_preferences.dart';

class AppMaintenanceSharedpreference {
  final String? version;

  const AppMaintenanceSharedpreference({
    required this.version,
  });

  static Future<AppMaintenanceSharedpreference> get appDetail =>
      getAppMaintainenceDetail();

  // static Future<void> storeAppMaintainence(AppMaintanenceModel json) async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   // await prefs.setInt(
  //   //   'is_maintainence',
  //   //   (json.maintainenceMode == null
  //   //       ? 0
  //   //       : (json.maintainenceMode ?? false)
  //   //       ? 1
  //   //       : 0),
  //   // );

  //   // Save an String value to 'action' key.
  //   await prefs.setString('version', json.version ?? '');
  // }

  static Future<AppMaintenanceSharedpreference>
  getAppMaintainenceDetail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return AppMaintenanceSharedpreference(
      version: prefs.getString('version'),
    );
  }
}
