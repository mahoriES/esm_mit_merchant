import 'package:flutter/cupertino.dart';
import 'package:sentry/sentry.dart';

class SentryHandler {
  bool get isInProdMode {
    /// Assuming in production mode.
    bool isInProdMode = true;

    ///This code only sets [isInProdMode] to false in a development environment.
    // assert(isInProdMode = false);

    return isInProdMode;
  }

  final String prodDsnKey =
      'https://ea965031c8364641a7d5163d69f9acb0@o403346.ingest.sentry.io/5425662';

  Future<void> reportError(dynamic error, dynamic stackTrace) async {
    debugPrint('Report error invoked');
    final SentryClient _sentryClient = SentryClient(dsn: prodDsnKey);
    // Print the exception to the console.
    print('Caught error: $error');
    if (!isInProdMode) {
      /// Print the full stacktrace in debug mode as well.
      print(stackTrace);
      _sentryClient.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
    } else {
      /// Send the Exception and Stacktrace to Sentry in Production mode.
      _sentryClient.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
    }
  }
}
