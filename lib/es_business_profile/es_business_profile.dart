import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_business_profile.dart';
import 'package:foore/data/bloc/es_businesses.dart';

import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/es_business.dart';
import 'package:foore/es_business_profile/es_business_image_list.dart';

import 'package:foore/es_business_profile/es_edit_text_generic.dart';
import 'package:foore/widgets/es_select_business.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'es_edit_business_address.dart';

class EsBusinessProfile extends StatefulWidget {
  static const routeName = '/es_business_profile';

  EsBusinessProfile({Key key}) : super(key: key);

  _EsBusinessProfileState createState() => _EsBusinessProfileState();
}

class _EsBusinessProfileState extends State<EsBusinessProfile> {
  EsBusinessProfileBloc esBusinessProfileBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    this.esBusinessProfileBloc = null;
    super.dispose();
  }

  editName() async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => EsEditBaseTextPage(
              this.esBusinessProfileBloc,
              'Update business name',
              'Business name',
              this.esBusinessProfileBloc.nameEditController,
              this.esBusinessProfileBloc.updateName,
            )));
  }

  addNotificationPhone() async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => new EsEditBaseTextPage(
              this.esBusinessProfileBloc,
              'Add Notification Phone',
              'Phone number',
              this.esBusinessProfileBloc.notificationPhoneEditingControllers,
              this.esBusinessProfileBloc.addNotificationPhone,
            )));
  }

  addNotificationEmail() async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => new EsEditBaseTextPage(
              this.esBusinessProfileBloc,
              'Add Notification Email',
              'Email ID',
              this.esBusinessProfileBloc.notificationEmailEditingControllers,
              this.esBusinessProfileBloc.addNotificationEmail,
            )));
  }

  editUpiAddress() async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => EsEditBaseTextPage(
              this.esBusinessProfileBloc,
              'Update UPI ID',
              'UPI ID',
              this.esBusinessProfileBloc.upiAddressEditController,
              this.esBusinessProfileBloc.updateUpiAddress,
            )));
  }

  addPhone() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EsEditBaseTextPage(
          this.esBusinessProfileBloc,
          'Add phone number',
          'Phone number',
          this.esBusinessProfileBloc.phoneNumberEditingControllers,
          this.esBusinessProfileBloc.addPhone,
        ),
      ),
    );
  }

  addAddress() async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            EsEditBusinessAddressPage(this.esBusinessProfileBloc)));
  }

  addDescription() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EsEditBaseTextPage(
          this.esBusinessProfileBloc,
          'Update business description',
          'Business description',
          this.esBusinessProfileBloc.descriptionEditController,
          this.esBusinessProfileBloc.updateDescription,
        ),
      ),
    );
  }

  Widget getBaseHeaderWidget(String headerName) {
    return Container(
      padding: const EdgeInsets.only(
        top: 12.0,
        left: 20,
        right: 20,
        // bottom: 8.0,
      ),
      alignment: Alignment.bottomLeft,
      child: Text(
        headerName,
        style: Theme.of(context).textTheme.subtitle2,
      ),
    );
  }

  List<Widget> getTextChips(List<String> inputTextList, Function onDelete) {
    List<Widget> widgets = List<Widget>();
    for (String inputText in inputTextList) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Chip(
            label: Text(
              inputText,
              overflow: TextOverflow.ellipsis,
            ),
            onDeleted: () {
              onDelete(inputText);
            },
          ),
        ),
      );
    }
    return widgets;
  }

  Widget getChipTextListWidget(
      String label, List<String> textList, Function onDelete, Function onAdd) {
    return Container(
      child: textList.length == 0
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FlatButton(
                  onPressed: onAdd,
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Wrap(
                      children: getTextChips(textList, onDelete),
                    ),
                  ),
                  IconButton(
                    onPressed: onAdd,
                    icon: Icon(
                      Icons.add,
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Widget getPhoneWidget(EsBusinessInfo businessInfo) {
    return getChipTextListWidget("+ Add phone", businessInfo.dPhones,
        this.esBusinessProfileBloc.deletePhoneWithNumber, addPhone);
  }

  Widget getHeaderWithSwitchWidget(
      String label, bool switchValue, Function onUpdate) {
    return Container(
      padding: const EdgeInsets.only(
        //top: 24.0,
        left: 20,
        right: 20,
        // bottom: 8.0,
      ),
      alignment: Alignment.bottomLeft,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ),
          Switch(
              value: switchValue,
              onChanged: (value) {
                onUpdate(value, null, null);
              }),
        ],
      ),
    );
  }

  Widget getUpiWidget(EsBusinessInfo businessInfo) {
    return Container(
      child: businessInfo.dBusinessPaymentUpiAddress == ''
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FlatButton(
                  onPressed: editUpiAddress,
                  child: Text(
                    "+ Add UPI ID",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      businessInfo.dBusinessPaymentUpiAddress,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ),
                  IconButton(
                    onPressed: editUpiAddress,
                    icon: Icon(
                      Icons.edit,
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Widget getBusinessNameWidget(EsBusinessInfo businessInfo) {
    return Container(
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      businessInfo.dBusinessName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.subtitle1,
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
    );
  }

  Widget getAddressWidget(businessInfo) {
    return Container(
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      businessInfo.dBusinessPrettyAddress,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.subtitle1,
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
    );
  }

  Widget getDescriptionWidget(businessInfo) {
    return Container(
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      businessInfo.dBusinessDescription,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.subtitle1,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final httpService = Provider.of<HttpService>(context);
    final businessBloc = Provider.of<EsBusinessesBloc>(context);
    if (this.esBusinessProfileBloc == null) {
      this.esBusinessProfileBloc =
          EsBusinessProfileBloc(httpService, businessBloc);
    }

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
                          horizontal: 20, vertical: 0),
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
                                    "Store Open",
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Switch(
                                    value: snapshot.data.isOpen,
                                    onChanged: (value) {
                                      this.esBusinessProfileBloc.setOpen(value);
                                    }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(thickness: 2),
                    getBaseHeaderWidget('Logo'),
                    SizedBox(height: 20),
                    EsBusinessProfileImageList(esBusinessProfileBloc, allowMany: false),
                    SizedBox(height: 8),
                    getBaseHeaderWidget('Name'),
                    getBusinessNameWidget(businessInfo),
                    getBaseHeaderWidget('Description'),
                    getDescriptionWidget(businessInfo),
                    getBaseHeaderWidget('Address'),
                    getAddressWidget(businessInfo),
                    Divider(thickness: 2),
                    getHeaderWithSwitchWidget(
                        'UPI Payment',
                        businessInfo.dBusinessPaymentStatus,
                        this.esBusinessProfileBloc.updateUpiStatus),
                    getUpiWidget(businessInfo),
                    getBaseHeaderWidget('Support Phone'),
                    getChipTextListWidget(
                        "+ Add phone",
                        businessInfo.dPhones,
                        this.esBusinessProfileBloc.deletePhoneWithNumber,
                        addPhone),
                    Divider(thickness: 2),

                    getHeaderWithSwitchWidget(
                        'Email Notifications',
                        businessInfo.notificationEmailStatus,
                        this
                            .esBusinessProfileBloc
                            .updateNotificationEmailStatus),
                    getChipTextListWidget(
                        "+ Add Email",
                        businessInfo.notificationEmails,
                        this.esBusinessProfileBloc.deleteNotificationEmail,
                        addNotificationEmail),
                    getHeaderWithSwitchWidget(
                        'SMS Notifications',
                        businessInfo.notificationPhoneStatus,
                        this
                            .esBusinessProfileBloc
                            .updateNotificationPhoneStatus),
                    getChipTextListWidget(
                        "+ Add Phone",
                        businessInfo.notificationPhones,
                        this
                            .esBusinessProfileBloc
                            .deleteNotificationPhoneWithNumber,
                        addNotificationPhone),
                    //SizedBox(height: 120),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
