# Foore

A new Flutter project.

> key.properties file is not version controlled.
/android/key.properties
storePassword=`password`
keyPassword=`password`
keyAlias=key
storeFile=`location of the key store file, such as /Users/<user name>/key.jks`

## Release for production

flutter build appbundle --release

Updated pubspec.yaml version code (After +)
Override app build.gradle 'flutterVersionName' if required.
Updated data->http_service.dart to change API paths
