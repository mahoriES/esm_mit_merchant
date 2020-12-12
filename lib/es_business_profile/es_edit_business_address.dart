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
          title: Text('Submit failed'),
          content: const Text('Please try again.'),
          actions: <Widget>[
            FlatButton(
              child: const Text('Dismiss'),
              onPressed: () {
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

    submit(bool isLocationValid, EsAddressPayload addressPayload) {
      if (isLocationValid) {
        widget.esBusinessProfileBloc.addAddress(
          addressPayload,
          onSuccess,
          onFail,
        );
      } else {
        Fluttertoast.showToast(msg: "Invalid Address");
      }
    }

    navigateToMap() async {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddNewAddressView(),
        ),
      );
    }

    return StreamBuilder<EsAddressState>(
      stream: esAddressBloc.esAddressStateObservable,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        addressTextController.text =
            snapshot.data.selectedAddressRequest?.prettyAddress ??
                widget.esBusinessProfileBloc.addressEditController.text;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              AppTranslations.of(context)
                  .text('profile_page_update_business_address'),
            ),
          ),
          body: Scrollbar(
            child: ListView(
              children: <Widget>[
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 24.0,
                    left: 20,
                    right: 20,
                  ),
                  child: GestureDetector(
                    onTap: () => navigateToMap(),
                    child: TextFormField(
                      controller: addressTextController,
                      decoration: InputDecoration(
                        enabled: false,
                        border: OutlineInputBorder(),
                        labelText: AppTranslations.of(context)
                            .text('profile_page_address'),
                      ),
                      maxLines: 5,
                      minLines: 1,
                      enabled: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FoSubmitButton(
            text: AppTranslations.of(context).text('generic_save'),
            onPressed: () => submit(
              !snapshot.data.isLocationNull,
              snapshot.data.selectedAddressRequest,
            ),
            isLoading: snapshot.data.addressStatus == LaodingStatus.LOADING,
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }
}
