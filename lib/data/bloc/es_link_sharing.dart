import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';

class EsDynamicLinkSharing {
  AndroidParameters _androidParameters = AndroidParameters(
    packageName: 'com.esamudaay.customer',
    minimumVersion: 16,
  );
  IosParameters _iosParameters = IosParameters(
    bundleId: 'com.esamudaay.consumer',
    appStoreId: '1532727652',
    minimumVersion: "1.0.9",
  );
  String _uriPrefix = 'https://esamudaay.page.link';
  String _link = 'https://esamudaay.com';

  DynamicLinkParameters createShopLink({@required String businessId}) {
    debugPrint('bId => $businessId');

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: _uriPrefix,
      link: Uri.parse('$_link?businessId=$businessId'),
      androidParameters: _androidParameters,
      iosParameters: _iosParameters,
    );
    return parameters;
  }

  DynamicLinkParameters createVideoLink({@required String videoId}) {
    debugPrint('vId => $videoId');

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: _uriPrefix,
      link: Uri.parse('$_link?videoId=$videoId'),
      androidParameters: _androidParameters,
      iosParameters: _iosParameters,
    );

    return parameters;
  }

  shareLink(DynamicLinkParameters parameters, String text) async {
    final Uri dynamicUrl = await parameters.buildUrl();
    Share.text(
      text ?? '',
      dynamicUrl.toString(),
      'text/plain',
    );
  }
}
