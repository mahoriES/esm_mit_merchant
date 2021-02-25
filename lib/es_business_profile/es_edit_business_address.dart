import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foore/app_translations.dart';
import 'package:foore/buttons/fo_submit_button.dart';
import 'package:foore/data/bloc/es_address_bloc.dart';
import 'package:foore/data/bloc/es_business_profile.dart';
import 'package:foore/data/model/es_business.dart';
import 'package:foore/es_address_picker_view/add_new_address_view.dart/add_new_address_view.dart';
import 'package:provider/provider.dart';

class EsEditBusinessAddressPage extends StatefulWidget {
  static const routeName = '/create-business-page';

  final EsBusinessProfileBloc esBusinessProfileBloc;

  EsEditBusinessAddressPage(this.esBusinessProfileBloc);

  @override
  EsEditBusinessAddressPageState createState() =>
      EsEditBusinessAddressPageState();
}

class EsEditBusinessAddressPageState extends State<EsEditBusinessAddressPage> {
  EsAddressBloc esAddressBloc;
  TextEditingController addressTextController;

  _showFailedAlertDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: true, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text(AppTranslations.of(context).text('generic_submit_failed')),
          content: Text(AppTranslations.of(context)
              .text("generic_please_please_try_again")),
          actions: <Widget>[
            FlatButton(
              child:
                  Text(AppTranslations.of(context).text('video_page_dismiss')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  _showDiscardChangesAlert() async {
    await showDialog(
      context: context,
      barrierDismissible: true, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          content:
              Text(AppTranslations.of(context).text('address_discard_message')),
          actions: <Widget>[
            FlatButton(
              child: Text(AppTranslations.of(context).text('generic_cancel')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(AppTranslations.of(context).text('generic_discard')),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  @override
  void initState() {
    esAddressBloc = Provider.of<EsAddressBloc>(context, listen: false);
    addressTextController = new TextEditingController(
        text: widget.esBusinessProfileBloc.addressEditController.text);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    onSuccess() {
      Navigator.of(context).pop();
    }

    onFail() {
      this._showFailedAlertDialog();
    }

    submit(
      bool isUpdatedAddressValid,
      EsAddressPayload addressPayload,
    ) {
      if (isUpdatedAddressValid) {
        widget.esBusinessProfileBloc
            .addAddress(addressPayload, onSuccess, onFail, context);
      } else {
        Fluttertoast.showToast(
          msg: AppTranslations.of(context).text("address_page_invalid_address"),
        );
      }
    }

    navigateToMap() async {
      await Navigator.pushNamed(context, AddNewAddressView.routeName);
    }

    return StreamBuilder<EsAddressState>(
      stream: esAddressBloc.esAddressStateObservable,
      builder: (context, addressSnapshot) {
        if (!addressSnapshot.hasData) {
          return SizedBox.shrink();
        }

        addressTextController.text =
            addressSnapshot.data.selectedAddressRequest == null
                ? widget.esBusinessProfileBloc.getBusinessAdress
                : addressSnapshot.data.formattedAddressWithDeatails;

        return StreamBuilder<EsBusinessProfileState>(
          stream: widget.esBusinessProfileBloc.createBusinessObservable,
          builder: (context, businessSnapshot) {
            if (!businessSnapshot.hasData) {
              return SizedBox.shrink();
            }

            return WillPopScope(
              onWillPop: () async {
                if (addressSnapshot.data.isAddressUpdated) {
                  _showDiscardChangesAlert();
                  return Future.value(false);
                } else
                  return Future.value(true);
              },
              child: Scaffold(
                appBar: AppBar(
                  title: Text(
                    AppTranslations.of(context)
                        .text('profile_page_update_business_address'),
                  ),
                ),
                body: Padding(
                  padding: const EdgeInsets.only(
                    top: 24,
                    left: 20,
                    right: 20,
                  ),
                  child: GestureDetector(
                    onTap: () => businessSnapshot.data.isSubmitting
                        ? Fluttertoast.showToast(
                            msg: AppTranslations.of(context)
                                .text('address_updating_message'),
                          )
                        : navigateToMap(),
                    child: TextFormField(
                      controller: addressTextController,
                      decoration: InputDecoration(
                        enabled: false,
                        border: OutlineInputBorder(),
                        labelText: AppTranslations.of(context)
                            .text('profile_page_address'),
                        suffixIcon: Icon(
                          Icons.edit,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      maxLines: null,
                      minLines: 1,
                      enabled: false,
                    ),
                  ),
                ),
                floatingActionButton: FoSubmitButton(
                  text: AppTranslations.of(context).text('generic_save'),
                  isEnabled: addressSnapshot.data.isAddressUpdated,
                  onPressed: () => submit(
                    addressSnapshot.data.isSelectedAddressValid,
                    addressSnapshot.data.selectedAddressRequest,
                  ),
                  isLoading: businessSnapshot.data.isSubmitting,
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
              ),
            );
          },
        );
      },
    );
  }
}
