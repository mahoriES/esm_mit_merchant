import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foore/app_translations.dart';
import 'package:foore/data/bloc/es_link_sharing.dart';
import 'package:foore/services/sizeconfig.dart';

class EsShareLink extends StatefulWidget {
  @override
  _EsShareLinkState createState() => _EsShareLinkState();
}

class _EsShareLinkState extends State<EsShareLink> {
  EsDynamicLinkSharing esDynamicLinkSharing;
  DynamicLinkParameters linkParameters;
  String linkUrl;
  bool isLoading;

  @override
  void initState() {
    isLoading = true;
    esDynamicLinkSharing = EsDynamicLinkSharing(context);
    linkParameters = esDynamicLinkSharing.createShopLink();
    linkParameters.buildUrl().then((Uri link) {
      linkUrl = link.toString();
      isLoading = false;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Container()
        : Container(
            padding: EdgeInsets.symmetric(horizontal: 20.toWidth),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Text(
                        AppTranslations.of(context).text('Store Link'),
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: Icon(Icons.share),
                          onPressed: () {
                            esDynamicLinkSharing.shareLink(
                              linkParameters,
                              AppTranslations.of(context)
                                  .text('Share Your Store Link'),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.toHeight),
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Text(
                        AppTranslations.of(context).text(
                            'Let your customers checkout your store directly through this link.'),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                  ],
                ),
                SizedBox(height: 8.toHeight),
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Text(
                        linkUrl ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            .copyWith(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: Icon(Icons.content_copy),
                          onPressed: () {
                            ClipboardManager.copyToClipBoard(
                              linkUrl ?? '',
                            ).then((result) {
                              Fluttertoast.showToast(
                                msg: AppTranslations.of(context)
                                    .text('Copied to Clipboard'),
                              );
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.toHeight),
              ],
            ),
          );
  }
}
