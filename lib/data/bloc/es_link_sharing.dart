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
    // We will need to update the version number as per release status.
    // For now I have set it to 1.0.9 considerimg this feature would be included in next release.
    minimumVersion: "1.0.9",
  );
  String _uriPrefix = 'https://esamudaay.page.link';
  String _link = 'https://esamudaay.com/links';

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
      // socialMetaTagParameters: SocialMetaTagParameters(
      //   title:
      //       'Hello! You can now order online from $storeName using this link.',
      //   description:
      //       'You can pay online using GooglePay, PayTM, PhonePe, UPI apps or Cash on delivery.',
      //   imageUrl: Uri.parse(
      //     'https://lh3.googleusercontent.com/b5-o56HDsZhnCfYavGxGcfZHmZp51AzbzXQXllZ19FlVyIwhMI9i0fFuTu_9oe1MYlQ=s180',
      //   ),
      // ),
    );

    return parameters;
  }

  shareLink({
    @required DynamicLinkParameters parameters,
    @required String text,
    @required String storeName,
  }) async {
    Uri dynamicUrl;
    try {
      dynamicUrl = (await parameters.buildShortLink()).shortUrl;
    } catch (e) {
      dynamicUrl = await parameters.buildUrl();
    }
    final String sharingString =
        'Hello! You can now order online from $storeName using this link.' +
            '\n\n' +
            '${dynamicUrl.toString()}' +
            '\n\n' +
            'You can pay online using GooglePay, PayTM, PhonePe, UPI apps or Cash on delivery.';
    Share.text(
      text ?? '',
      sharingString,
      'text/plain',
    );
  }
}
