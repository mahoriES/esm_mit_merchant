import 'package:package_info/package_info.dart';

class Environment {
  //Set False for Staging build

  static get apiUrl =>
      isProd ? EnvironmentProd._apiUrl : EnvironmentPreprod._apiUrl;

  static get esApiUrl =>
      isProd ? EnvironmentProd._esApiUrl : EnvironmentPreprod._esApiUrl;

  static get esTPID => '5d730376-72ed-478c-8d5e-1a3a6aee9815';

  static get intercomAppId => isProd
      ? EnvironmentProd._intercom_app_id
      : EnvironmentPreprod._intercom_app_id;

  static get intercomAndroidApiKey => isProd
      ? EnvironmentProd._intercom_android_api_key
      : EnvironmentPreprod._intercom_android_api_key;

  static get intercomIosApiKey => isProd
      ? EnvironmentProd._intercom_ios_api_key
      : EnvironmentPreprod._intercom_ios_api_key;

  static get isProd => true;
  // static get isProd => const bool.fromEnvironment('dart.vm.product');

  static Future<String> get version async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }
}

class EnvironmentPreprod {
  //static const _apiUrl = 'https://www.api.test.foore.io/api/v1/';
  //We have moved to same URL for staging as well. As Foore doesn't have a staging backend server anymore
  static const _apiUrl = 'https://www.api.foore.io/api/v1/';

  static const _esApiUrl = 'https://api.test.esamudaay.com/api/v1/';

  static const _intercom_app_id = 'qwul6hvd';

  static const _intercom_android_api_key =
      'android_sdk-de027a749a8e3ee29cf5ea1fde0391c512823bbf';

  static const _intercom_ios_api_key =
      'ios_sdk-0e7d3f1f7eb3cbd8a33ae596b231fbdbb2bd33f1';
}

class EnvironmentProd {
  static const _apiUrl = 'https://www.api.foore.io/api/v1/';

  static const _esApiUrl = 'https://api.esamudaay.com/api/v1/';

  static const _intercom_app_id = 'p6exnkrf';

  static const _intercom_android_api_key =
      'android_sdk-88669b53e224cff26d0b79b1d149ae883380dba2';

  static const _intercom_ios_api_key =
      'ios_sdk-e542f37515715a94010a40d0de6de9ef09400b2a';
}
