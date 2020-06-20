import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_business_profile.dart';
import 'package:foore/data/bloc/es_businesses.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/es_business.dart';
import 'package:foore/es_business_profile/es_edit_business_description.dart';
import 'package:foore/es_create_business/es_create_business.dart';
import 'package:foore/menu_page/add_menu_item_page.dart';
import 'package:foore/widgets/es_select_business.dart';
import 'package:provider/provider.dart';

import 'es_edit_business_address.dart';
import 'es_edit_business_name.dart';
import 'es_edit_business_phone.dart';

class EsBusinessProfile extends StatefulWidget {
  static const routeName = '/es_business_profile';

  EsBusinessProfile({Key key}) : super(key: key);

  _EsBusinessProfileState createState() => _EsBusinessProfileState();
}

class _EsBusinessProfileState extends State<EsBusinessProfile> {
  EsBusinessProfileBloc esBusinessProfileBloc;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    final httpService = Provider.of<HttpService>(context);
    final businessBloc = Provider.of<EsBusinessesBloc>(context);
    if (this.esBusinessProfileBloc == null) {
      this.esBusinessProfileBloc =
          EsBusinessProfileBloc(httpService, businessBloc);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    editName() async {
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              EsEditBusinessNamePage(this.esBusinessProfileBloc)));
    }

    addPhone() async {
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              EsEditBusinessPhonesPage(this.esBusinessProfileBloc)));
    }

    addAddress() async {
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              EsEditBusinessAddressPage(this.esBusinessProfileBloc)));
    }

    addDescription() async {
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              EsEditBusinessDescriptionPage(this.esBusinessProfileBloc)));
    }

    // deleteItem(EsProduct product) async {}

    return Scaffold(
      appBar: EsSelectBusiness(() {}),
      body: SafeArea(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          child: SingleChildScrollView(
            child: StreamBuilder<EsBusinessProfileState>(
                stream: this.esBusinessProfileBloc.createBusinessObservable,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }
                  EsBusinessInfo businessInfo =
                      snapshot.data.selectedBusinessInfo;
                  return Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Wrap(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 0, top: 13, bottom: 13),
                                    child: Text(
                                      "Delivery",
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Switch(
                                      value: snapshot.data.hasDelivery,
                                      onChanged: (value) {
                                        this
                                            .esBusinessProfileBloc
                                            .setDelivery(value);
                                      }),
                                ],
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: Wrap(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 0, top: 13, bottom: 13),
                                    child: Text(
                                      "Open",
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Switch(
                                      value: snapshot.data.isOpen,
                                      onChanged: (value) {
                                        this
                                            .esBusinessProfileBloc
                                            .setOpen(value);
                                      }),
                                ],
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: Chip(
                                label: Text(
                                  businessInfo.dBusinessClusterCode,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(
                          top: 24.0,
                          left: 20,
                          right: 20,
                          // bottom: 8.0,
                        ),
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          'Name',
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
                      ),
                      Container(
                        child: businessInfo.dBusinessName == ''
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  FlatButton(
                                    onPressed: editName,
                                    child: Text(
                                      "+ Add business name",
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              )
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        businessInfo.dBusinessName,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: editName,
                                      icon: Icon(
                                        Icons.edit,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(
                          top: 24.0,
                          left: 20,
                          right: 20,
                          // bottom: 8.0,
                        ),
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          'Phone',
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
                      ),
                      Container(
                        child: businessInfo.dPhones.length == 0
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  FlatButton(
                                    onPressed: addPhone,
                                    child: Text(
                                      "+ Add phone",
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      child: Wrap(
                                        children: businessInfo.dPhones
                                            .map((phone) => Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 8.0),
                                                  child: Chip(
                                                    label: Text(
                                                      phone,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    onDeleted: () {
                                                      this
                                                          .esBusinessProfileBloc
                                                          .deletePhoneWithNumber(
                                                              phone);
                                                    },
                                                  ),
                                                ))
                                            .toList(),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: addPhone,
                                      icon: Icon(
                                        Icons.add,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(
                          top: 24.0,
                          left: 20,
                          right: 20,
                        ),
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          'Address',
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
                      ),
                      Container(
                        child: businessInfo.dBusinessPrettyAddress == ''
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  FlatButton(
                                    onPressed: addAddress,
                                    child: Text(
                                      "+ Add address",
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              )
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        businessInfo.dBusinessPrettyAddress,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: addAddress,
                                      icon: Icon(
                                        Icons.edit,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(
                          top: 24.0,
                          left: 20,
                          right: 20,
                        ),
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          'Description',
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
                      ),
                      Container(
                        child: businessInfo.dBusinessDescription == ''
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  FlatButton(
                                    onPressed: addDescription,
                                    child: Text(
                                      "+ Add description",
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              )
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        businessInfo.dBusinessDescription,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: addDescription,
                                      icon: Icon(
                                        Icons.edit,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(
                          top: 24.0,
                          left: 20,
                          right: 20,
                        ),
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          'Photos',
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: <Widget>[
                            Material(
                              elevation: 1.0,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4.0),
                                child: Container(
                                  height: 120,
                                  width: 120,
                                  child: Container(
                                    child: Image.network(
                                        'https://picsum.photos/200'),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 12.0,
                            ),
                            Material(
                              elevation: 1.0,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4.0),
                                child: Container(
                                  height: 120,
                                  width: 120,
                                  child: Container(
                                    child: Image.network(
                                        'https://picsum.photos/200'),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 12.0,
                            ),
                            Container(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4.0),
                                child: Container(
                                  height: 120,
                                  width: 120,
                                  color: Colors.grey[100],
                                  child: Center(
                                    child: Icon(
                                      Icons.add_a_photo,
                                      // size: 40,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 120),
                    ],
                  );
                }),
          ),
        ),
      ),
      floatingActionButton: Transform.translate(
        offset: Offset(0, -15),
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          padding: EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 25,
          ),
          onPressed: () async {
            Navigator.of(context).pushNamed(EsCreateBusinessPage.routeName);
          },
          child: Container(
            child: Text(
              'Add business',
              style: Theme.of(context).textTheme.subhead.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
