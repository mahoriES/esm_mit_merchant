import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foore/data/bloc/es_address_bloc.dart';
import 'package:foore/data/bloc/es_business_profile.dart';
import 'package:foore/data/bloc/es_businesses.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/es_business.dart';
import 'package:foore/es_business_categories/es_business_categories_view.dart';
import 'package:foore/es_business_profile/es_business_image_list.dart';
import 'package:foore/es_business_profile/es_edit_text_generic.dart';
import 'package:provider/provider.dart';
import 'es_edit_business_address.dart';
import 'widgets/share_link_widget.dart';
import 'package:foore/app_translations.dart';

class EsBusinessProfile extends StatefulWidget {
  static const routeName = '/es_business_profile';

  EsBusinessProfile({Key key}) : super(key: key);

  _EsBusinessProfileState createState() => _EsBusinessProfileState();
}

class _EsBusinessProfileState extends State<EsBusinessProfile> with ChipsWidgetMixin{
  EsBusinessProfileBloc esBusinessProfileBloc;

  @override
  void dispose() {
    this.esBusinessProfileBloc = null;
    super.dispose();
  }

  editName() async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            EsEditBaseTextPage(
                this.esBusinessProfileBloc,
                AppTranslations.of(context)
                    .text("profile_page_update_business_name"),
                AppTranslations.of(context).text("profile_page_business_name"),
                this.esBusinessProfileBloc.nameEditController,
                this.esBusinessProfileBloc.updateName,
                64)));
  }

  addNotificationPhone() async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
        new EsEditBaseTextPage(
            this.esBusinessProfileBloc,
            AppTranslations.of(context)
                .text("profile_page_add_notification_phone"),
            AppTranslations.of(context)
                .text("profile_page_10_digit_Mobile_number"),
            this.esBusinessProfileBloc.notificationPhoneEditingControllers,
            this.esBusinessProfileBloc.addNotificationPhone,
            10)));
  }

  addNotificationEmail() async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
        new EsEditBaseTextPage(
            this.esBusinessProfileBloc,
            AppTranslations.of(context)
                .text("profile_page_add_notification_email"),
            AppTranslations.of(context).text("profile_page_email_id"),
            this.esBusinessProfileBloc.notificationEmailEditingControllers,
            this.esBusinessProfileBloc.addNotificationEmail,
            127)));
  }

  editUpiAddress() async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            EsEditBaseTextPage(
                this.esBusinessProfileBloc,
                AppTranslations.of(context).text("profile_page_update_upi_id"),
                AppTranslations.of(context).text("profile_page_upi_id"),
                this.esBusinessProfileBloc.upiAddressEditController,
                this.esBusinessProfileBloc.updateUpiAddress,
                127)));
  }

  addPhone() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            EsEditBaseTextPage(
                this.esBusinessProfileBloc,
                AppTranslations.of(context).text(
                    "profile_page_add_mobile_number"),
                AppTranslations.of(context)
                    .text("profile_page_10_digit_Mobile_number"),
                this.esBusinessProfileBloc.phoneNumberEditingControllers,
                this.esBusinessProfileBloc.addPhone,
                10),
      ),
    );
  }

  addAddress() async {
    await Navigator.of(context)
        .push(MaterialPageRoute(
        builder: (context) =>
            EsEditBusinessAddressPage(this.esBusinessProfileBloc)))
        .then(
          (value) => Provider.of<EsAddressBloc>(context).reset(),
    );
  }

  addDescription() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            EsEditBaseTextPage(
                this.esBusinessProfileBloc,
                AppTranslations.of(context)
                    .text("profile_page_update_business_description"),
                AppTranslations.of(context)
                    .text("profile_page_business_description"),
                this.esBusinessProfileBloc.descriptionEditController,
                this.esBusinessProfileBloc.updateDescription,
                512),
      ),
    );
  }

  addOrEditBusinessCategories() async {
    debugPrint('Over here to add/edit categories');
    final categories = await Navigator.of(context).pushNamed(
        BusinessCategoriesPickerView.routeName,
        arguments: List<EsBusinessCategory>.from(this.esBusinessProfileBloc
            .selectedBusinessCategories));
    if (categories == null) return;
    this.esBusinessProfileBloc.updateBusinessCategories(
        (categories as List<EsBusinessCategory>).map((e) => e.bcat).toList(),
        (){Fluttertoast.showToast(msg: AppTranslations
            .of(context).text("categories_updated_success"),);},
            (){Fluttertoast.showToast(
                msg: AppTranslations
                    .of(context).text("categories_updation_failed"),);});
  }

  addNotice() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            EsEditBaseTextPage(
                this.esBusinessProfileBloc,
                AppTranslations.of(context)
                    .text("profile_page_update_business_notice"),
                AppTranslations.of(context)
                    .text('profile_page_update_business_notice_label'),
                this.esBusinessProfileBloc.noticeEditController,
                this.esBusinessProfileBloc.updateNotice,
                127),
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
        style: Theme
            .of(context)
            .textTheme
            .subtitle2,
      ),
    );
  }

  Widget getPhoneWidget(EsBusinessInfo businessInfo) {
    return getChipTextListWidget(
        "+ " + AppTranslations.of(context).text("profile_page_add_phone"),
        businessInfo.dPhones,
        this.esBusinessProfileBloc.deletePhoneWithNumber,
        addPhone,
        Icons.add);
  }

  Widget getBusinessCategoriesWidget(EsBusinessInfo businessInfo) {
    return getChipTextListWidget(
        "+ " + AppTranslations.of(context).text("profile_page_add_bcats"),
        businessInfo.businessCategoriesNamesList,
        null, addOrEditBusinessCategories,
        Icons.edit);
  }

  Widget getHeaderWithSwitchWidget(String label, bool switchValue,
      Function onUpdate) {
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
              style: Theme
                  .of(context)
                  .textTheme
                  .subtitle2,
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
              "+ " +
                  AppTranslations.of(context)
                      .text("profile_page_add_upi_id"),
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
                style: Theme
                    .of(context)
                    .textTheme
                    .subtitle1,
              ),
            ),
            IconButton(
              onPressed: editUpiAddress,
              icon: Icon(
                Icons.edit,
                color: Theme
                    .of(context)
                    .primaryColor,
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
              AppTranslations.of(context)
                  .text('profile_page_button_add_business_name'),
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
                style: Theme
                    .of(context)
                    .textTheme
                    .subtitle1,
              ),
            ),
            IconButton(
              onPressed: editName,
              icon: Icon(
                Icons.edit,
                color: Theme
                    .of(context)
                    .primaryColor,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget getAddressWidget(EsBusinessInfo businessInfo) {
    return Container(
      child: businessInfo.dBusinessPrettyAddress == ''
          ? Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FlatButton(
            onPressed: addAddress,
            child: Text(
              "+ " +
                  AppTranslations.of(context)
                      .text("profile_page_add_address"),
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
                style: Theme
                    .of(context)
                    .textTheme
                    .subtitle1,
              ),
            ),
            IconButton(
              onPressed: addAddress,
              icon: Icon(
                Icons.edit,
                color: Theme
                    .of(context)
                    .primaryColor,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget getDescriptionWidget(EsBusinessInfo businessInfo) {
    return Container(
      child: businessInfo.dBusinessDescription == ''
          ? Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FlatButton(
            onPressed: addDescription,
            child: Text(
              "+ " +
                  AppTranslations.of(context)
                      .text("profile_page_add_description"),
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
                style: Theme
                    .of(context)
                    .textTheme
                    .subtitle1,
              ),
            ),
            IconButton(
              onPressed: addDescription,
              icon: Icon(
                Icons.edit,
                color: Theme
                    .of(context)
                    .primaryColor,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget getNoticeWidget(EsBusinessInfo businessInfo) {
    return Container(
      child: businessInfo.dBusinessNotice == ''
          ? Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FlatButton(
            onPressed: addNotice,
            child: Text(
              "+ " +
                  AppTranslations.of(context)
                      .text("profile_page_add_notice"),
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
                businessInfo.dBusinessNotice,
                overflow: TextOverflow.ellipsis,
                style: Theme
                    .of(context)
                    .textTheme
                    .subtitle1,
              ),
            ),
            IconButton(
              onPressed: addNotice,
              icon: Icon(
                Icons.edit,
                color: Theme
                    .of(context)
                    .primaryColor,
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
                                    AppTranslations.of(context)
                                        .text("profile_page_delivery"),
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
                                    AppTranslations.of(context)
                                        .text("profile_page_store_open"),
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
                    getBaseHeaderWidget(
                        AppTranslations.of(context).text("profile_page_logo")),
                    SizedBox(height: 20),
                    EsBusinessProfileImageList(esBusinessProfileBloc,
                        allowMany: false),
                    SizedBox(height: 8),
                    getBaseHeaderWidget(
                        AppTranslations.of(context).text("profile_page_name")),
                    getBusinessNameWidget(businessInfo),
                    getBaseHeaderWidget(AppTranslations.of(context)
                        .text("profile_page_description")),
                    getDescriptionWidget(businessInfo),
                    getBaseHeaderWidget(
                        AppTranslations.of(context).text("profile_page_bcats")),
                    getBusinessCategoriesWidget(businessInfo),
                    getBaseHeaderWidget(AppTranslations.of(context)
                        .text("profile_page_address")),
                    getAddressWidget(businessInfo),
                    getBaseHeaderWidget(AppTranslations.of(context)
                        .text("profile_page_notice")),
                    getNoticeWidget(businessInfo),
                    EsShareLink(esBusinessProfileBloc),
                    // getHeaderWithSwitchWidget(
                    //     AppTranslations.of(context).text("profile_page_upi_payment"),
                    //     businessInfo.dBusinessPaymentStatus,
                    //     this.esBusinessProfileBloc.updateUpiStatus),
                    // getUpiWidget(businessInfo),
                    getBaseHeaderWidget(AppTranslations.of(context)
                        .text("profile_page_support_phone")),
                    getChipTextListWidget(
                        "+ " +
                            AppTranslations.of(context)
                                .text("profile_page_add_phone"),
                        businessInfo.dPhones,
                        this.esBusinessProfileBloc.deletePhoneWithNumber,
                        addPhone,
                        Icons.add),
                    Divider(thickness: 2),
                    getHeaderWithSwitchWidget(
                        AppTranslations.of(context)
                            .text("profile_page_email_notifications"),
                        businessInfo.notificationEmailStatus,
                        this
                            .esBusinessProfileBloc
                            .updateNotificationEmailStatus),
                    getChipTextListWidget(
                        "+ " +
                            AppTranslations.of(context)
                                .text("profile_page_add_email"),
                        businessInfo.notificationEmails,
                        this.esBusinessProfileBloc.deleteNotificationEmail,
                        addNotificationEmail,
                        Icons.add),
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

mixin ChipsWidgetMixin<T extends StatefulWidget> on State<T> {

  Widget getChipTextListWidget(String label, List<String> textList,
      Function onDelete, Function onAdd, IconData icon) {
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
                icon,
                color: Theme.of(context).primaryColor,
              ),
            )
          ],
        ),
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
            onDeleted: onDelete == null
                ? null
                : () {
              onDelete(inputText);
            },
          ),
        ),
      );
    }
    return widgets;
  }
}