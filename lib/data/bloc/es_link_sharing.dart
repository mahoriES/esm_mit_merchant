import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_businesses.dart';
import 'package:provider/provider.dart';

class EsDynamicLinkSharing {
  final BuildContext context;
  String businessId;
  String clusterId;
  EsDynamicLinkSharing(this.context) {
    EsBusinessesBloc esBusinessesBloc =
        Provider.of<EsBusinessesBloc>(this.context);
    businessId = esBusinessesBloc.getSelectedBusinessId();
    clusterId = esBusinessesBloc.getSelectedBusinessClusterId();
  }

  shareShopLink() async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://esamudaay.page.link',
      link: Uri.parse(
          'https://esamudaay.com?business=$businessId&&clusterId=$clusterId'),
      androidParameters: AndroidParameters(
        packageName: 'com.esamudaay.customer',
        minimumVersion: 16,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.esamudaay.customer',
        minimumVersion: '1.0.1',
        appStoreId: '123456789',
      ),
      // googleAnalyticsParameters: GoogleAnalyticsParameters(
      //   campaign: 'Clicked on dynamic link for business sharing of $businessId',
      //   medium: Platform.operatingSystem,
      //   source: 'merchant app',
      // ),
      // itunesConnectAnalyticsParameters: ItunesConnectAnalyticsParameters(
      //   providerToken: '123456',
      //   campaignToken: 'example-promo',
      // ),
      // socialMetaTagParameters: SocialMetaTagParameters(
      //   title: 'Example of a Dynamic Link',
      //   description: 'This link works whether app is installed or not!',
      // ),
    );

    final Uri dynamicUrl = await parameters.buildUrl();
    Share.text(
      'Share link for your shop',
      dynamicUrl.toString(),
      'text/plain',
    );
  }

  shareProductLink(int productID) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://esamudaay.page.link',
      link: Uri.parse('https://esamudaay.com?product=$productID'),
      androidParameters: AndroidParameters(
        packageName: 'com.esamudaay.customer',
        minimumVersion: 16,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.esamudaay.customer',
        minimumVersion: '1.0.1',
        appStoreId: '123456789',
      ),
      // googleAnalyticsParameters: GoogleAnalyticsParameters(
      //   campaign: 'Clicked on dynamic link for business sharing of $businessId',
      //   medium: Platform.operatingSystem,
      //   source: 'merchant app',
      // ),
    );

    final Uri dynamicUrl = await parameters.buildUrl();
    Share.text(
      'Share link for this product',
      dynamicUrl.toString(),
      'text/plain',
    );
  }
}
