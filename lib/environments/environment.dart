import 'package:foore/utils/environment_config.dart';
import 'package:package_info/package_info.dart';

class Environment {
  static get isProd => EnvironmentConfig.isProductionEnvironment;

  static get apiUrl =>
      isProd ? EnvironmentProd._apiUrl : EnvironmentPreprod._apiUrl;

  static get esApiUrl =>
      isProd ? EnvironmentProd._esApiUrl : EnvironmentPreprod._esApiUrl;

  static get esTPID => EnvironmentConfig.thirdPartyID;

  static get fooreSignUpUrl => "https://www.app.foore.in/signup/";

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
}

class EnvironmentProd {
  static const _apiUrl = 'https://www.api.foore.io/api/v1/';

  static const _esApiUrl = 'https://api.esamudaay.com/api/v1/';
}
