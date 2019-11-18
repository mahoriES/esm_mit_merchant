class Environment {
  static get apiUrl =>
      isProd ? EnvironmentProd._apiUrl : EnvironmentPreprod._apiUrl;

  static get intercomAppId => isProd
      ? EnvironmentProd._intercom_app_id
      : EnvironmentPreprod._intercom_app_id;

  static get intercomAndroidApiKey => isProd
      ? EnvironmentProd._intercom_android_api_key
      : EnvironmentPreprod._intercom_android_api_key;

  static get intercomIosApiKey => isProd
      ? EnvironmentProd._intercom_ios_api_key
      : EnvironmentPreprod._intercom_ios_api_key;

  static get isProd => bool.fromEnvironment('dart.vm.product');
}

class EnvironmentPreprod {
  static const _apiUrl = 'https://www.api.test.foore.io/api/v1/';

  static const _intercom_app_id = 'qwul6hvd';

  static const _intercom_android_api_key =
      'android_sdk-de027a749a8e3ee29cf5ea1fde0391c512823bbf';

  static const _intercom_ios_api_key =
      'ios_sdk-0e7d3f1f7eb3cbd8a33ae596b231fbdbb2bd33f1';
}

class EnvironmentProd {
  static const _apiUrl = 'https://www.api.test.foore.io/api/v1/';

  static const _intercom_app_id = 'p6exnkrf';

  static const _intercom_android_api_key =
      'android_sdk-88669b53e224cff26d0b79b1d149ae883380dba2';

  static const _intercom_ios_api_key =
      'ios_sdk-e542f37515715a94010a40d0de6de9ef09400b2a';
}
