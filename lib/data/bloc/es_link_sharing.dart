import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_businesses.dart';
import 'package:provider/provider.dart';

class EsDynamicLinkSharing {
  BuildContext context;
  EsBusinessesBloc _esBusinessesBloc;
  AndroidParameters _androidParameters = AndroidParameters(
    packageName: 'com.esamudaay.customer',
    minimumVersion: 16,
  );
  IosParameters _iosParameters = IosParameters(
    bundleId: 'com.esamudaay.customer',
    minimumVersion: '1.0.1',
    appStoreId: '123456789',
  );
  String _uriPrefix = 'https://esamudaay.page.link';
  String _link = 'https://esamudaay.com';

  EsDynamicLinkSharing(this.context) {
    _esBusinessesBloc = Provider.of<EsBusinessesBloc>(context, listen: false);
  }

  DynamicLinkParameters createShopLink() {
    String _businessId = _esBusinessesBloc.getSelectedBusinessId();
    String _clusterId = _esBusinessesBloc.getSelectedBusinessClusterId();

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: _uriPrefix,
      link: Uri.parse('$_link?businessId=$_businessId&&clusterId=$_clusterId'),
      androidParameters: _androidParameters,
      iosParameters: _iosParameters,
    );
    return parameters;
  }

  // shareProductLink(int productID) async {
  //   String _businessId = _esBusinessesBloc.getSelectedBusinessId();
  //   String _clusterId = _esBusinessesBloc.getSelectedBusinessClusterId();

  //   final DynamicLinkParameters parameters = DynamicLinkParameters(
  //     uriPrefix: _uriPrefix,
  //     link: Uri.parse(
  //         '$_link?businessId=$_businessId&&clusterId=$_clusterId&&productId=$productID'),
  //     androidParameters: _androidParameters,
  //     iosParameters: _iosParameters,
  //   );

  //   await _shareLink(parameters, 'Share link for this product');
  // }

  DynamicLinkParameters createVideoLink(String videoId) {
    String _clusterId = _esBusinessesBloc.getSelectedBusinessClusterId();
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: _uriPrefix,
      link: Uri.parse('$_link?clusterId=$_clusterId&&videoId=$videoId'),
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
