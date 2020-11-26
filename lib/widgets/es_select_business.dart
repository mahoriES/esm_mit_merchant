import 'dart:math';
import 'package:foore/app_translations.dart';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_businesses.dart';
import 'package:foore/es_create_business/es_create_business.dart';
import 'package:foore/services/sizeconfig.dart';
import 'package:provider/provider.dart';

class EsSelectBusiness extends PreferredSize {
  final onChangeBusiness;
  final bool allowChange;

  EsSelectBusiness(this.onChangeBusiness, {this.allowChange = true});

  @override
  Size get preferredSize => Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    showStoreSelector() {
      showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          final esBusinessesBloc = Provider.of<EsBusinessesBloc>(context);
          return StreamBuilder<EsBusinessesState>(
            stream: esBusinessesBloc.esBusinessesStateObservable,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              return Container(
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.toWidth,
                        vertical: 20.toHeight,
                      ),
                      child: Row(
                        children: <Widget>[
                          Text(
                             AppTranslations.of(context).text("business_select"),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: Theme.of(context).textTheme.headline5,
                          ),
                          Expanded(
                              child: Container(
                            height: 1,
                          )),
                          FlatButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pushNamed(
                                EsCreateBusinessPage.routeName);
                            },
                            icon: Icon(Icons.add),
                            // label: Text('Add business'),
                            label: Text( AppTranslations.of(context).text("business_select_add_business")),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: snapshot.data.businesses.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final businessInfo = snapshot.data.businesses[index];
                          return ListTile(
                            onTap: () {
                              esBusinessesBloc
                                  .setSelectedBusiness(businessInfo);
                              Navigator.pop(context);
                              if (onChangeBusiness != null) {
                                onChangeBusiness();
                              }
                            },
                            title: Text(businessInfo.dBusinessName),
                            subtitle: businessInfo.dBusinessNotApproved
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(businessInfo
                                      .dBusinessPrettyAddress),
                                      Text(
                                        AppTranslations.of(context).text("business_select_not_approved"),
                                        style: TextStyle(
                                          color: Colors.redAccent),
                                      ),
                                    ],
                                  )
                                : Text(businessInfo.dBusinessPrettyAddress),
                            leading: Icon(Icons.store),
                            isThreeLine: businessInfo.dBusinessNotApproved,
                            trailing: Chip(
                              label: Text(businessInfo.cluster.clusterName),
                              backgroundColor: Colors.white10,
                              labelStyle: Theme.of(context)
                                  .textTheme
                                  .caption
                                  .copyWith(fontSize: 12.toFont),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20.toHeight)
                  ],
                ),
              );
            },
          );
        },
      );
    }

    final esBusinessesBloc = Provider.of<EsBusinessesBloc>(context);
    return SafeArea(
      child: GestureDetector(
        onTap: allowChange ? showStoreSelector : null,
        child: Container(
          height: preferredSize.height,
          padding: EdgeInsets.symmetric(
            horizontal: 20.toWidth,
            vertical: 8.toHeight,
          ),
          color: Colors.white,
          child: StreamBuilder<EsBusinessesState>(
              stream: esBusinessesBloc.esBusinessesStateObservable,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SafeArea(
                      child: Container(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.toWidth),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: Text(
                                    snapshot
                                        .data.selectedBusiness.dBusinessName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                    style:
                                        Theme.of(context).textTheme.subtitle1),
                              ),
                              Container(
                                child: Text(
                                    snapshot.data.selectedBusiness
                                        .dBusinessPrettyAddress,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        .copyWith(
                                          color: Theme.of(context)
                                              .textTheme
                                              .caption
                                              .color,
                                        )),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    allowChange
                        ? Transform.rotate(
                            angle: pi / 2,
                            child: Icon(
                              Icons.chevron_right,
                              color: Colors.black26,
                              //size: 25,
                            ),
                          )
                        : SizedBox.shrink(),
                  ],
                );
              }),
        ),
      ),
    );
  }
}
