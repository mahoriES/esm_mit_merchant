import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static const SELECTED_BUSINESS_ID = 'selectedBusinessId';

  static Future<void> setSelectedBusinessId(String businessId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(SELECTED_BUSINESS_ID, businessId);
  }

  static Future<String> getSelectedBusinessId() async {
    String businessId;
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      businessId = sharedPreferences.getString(SELECTED_BUSINESS_ID) ?? false;
    } catch (exception) {}
    return businessId;
  }
}
