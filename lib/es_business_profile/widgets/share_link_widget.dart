import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foore/app_translations.dart';
import 'package:foore/data/bloc/es_business_profile.dart';
import 'package:foore/data/bloc/es_link_sharing.dart';
import 'package:foore/services/sizeconfig.dart';

class EsShareLink extends StatelessWidget {
  final EsBusinessProfileBloc bloc;
  EsShareLink(this.bloc);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<EsBusinessProfileState>(
      stream: bloc.createBusinessObservable,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Container();
        if (snapshot.data.isCreatingLink) return CircularProgressIndicator();
        if (snapshot.data.linkParameters == null ||
            snapshot.data.linkUrl == null) return Container();
        return Card(
          elevation: 2,
          color: Colors.grey[300],
          child: Container(
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
                            EsDynamicLinkSharing().shareLink(
                              parameters: snapshot.data.linkParameters,
                              text: AppTranslations.of(context)
                                  .text('Share Your Store Link'),
                              storeName: snapshot
                                  .data.selectedBusinessInfo.businessName,
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
                        snapshot.data.linkUrl ?? '',
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
                            Clipboard.setData(
                              ClipboardData(text: snapshot.data.linkUrl ?? ''),
                            ).then(
                              (result) {
                                Fluttertoast.showToast(
                                  msg: AppTranslations.of(context)
                                      .text('Copied to Clipboard'),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.toHeight),
              ],
            ),
          ),
        );
      },
    );
  }
}
