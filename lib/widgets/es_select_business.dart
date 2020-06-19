import 'dart:math';

import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_businesses.dart';
import 'package:provider/provider.dart';

class EsSelectBusiness extends PreferredSize {
  final onChangeBusiness;

  EsSelectBusiness(this.onChangeBusiness);

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
                  height: 600,
                  padding: EdgeInsets.all(20),
                  color: Colors.white,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Select business',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        Container(
                          height: 370,
                          child: Expanded(
                            child: ListView.builder(
                              itemCount: snapshot.data.businesses.length,
                              itemBuilder: (context, index) {
                                final businessInfo =
                                    snapshot.data.businesses[index];
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
                                  subtitle:
                                      Text(businessInfo.dBusinessPrettyAddress),
                                );
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              });
        },
      );
    }

    final esBusinessesBloc = Provider.of<EsBusinessesBloc>(context);
    return SafeArea(
      child: GestureDetector(
        onTap: showStoreSelector,
        child: Container(
          height: preferredSize.height,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          color: Colors.white,
          child: StreamBuilder<EsBusinessesState>(
              stream: esBusinessesBloc.esBusinessesStateObservable,
              builder: (context, snapshot) {
                return Row(
                  children: <Widget>[
                    Icon(
                      Icons.store,
                      color: Colors.black87,
                      size: 40,
                    ),
                    SafeArea(
                      child: Container(
                        width: (MediaQuery.of(context).size.width * 0.7 - 80),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
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
                    Transform.rotate(
                      angle: pi / 2,
                      child: Icon(
                        Icons.chevron_right,
                        color: Colors.black26,
                        size: 25,
                      ),
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }
}
