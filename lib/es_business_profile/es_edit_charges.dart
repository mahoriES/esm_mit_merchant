import 'package:esamudaay_themes/esamudaay_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foore/app_translations.dart';
import 'package:foore/buttons/fo_submit_button.dart';
import 'package:foore/data/bloc/es_order_charges_bloc.dart';
import 'package:foore/data/constants/state_constants.dart';
import 'package:foore/data/model/es_order_charges.dart';
import 'package:foore/utils/validators.dart';
import 'package:foore/widgets/something_went_wrong.dart';
import 'package:provider/provider.dart';

class EsEditOrderCharges extends StatelessWidget {
  static const String routeName = "order_charges_page";
  const EsEditOrderCharges({Key key}) : super(key: key);

  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    EsOrderChargesBloc _esOrderChargesBloc =
        Provider.of<EsOrderChargesBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            AppTranslations.of(context).text("profile_update_order_charges")),
      ),
      body: StreamBuilder<EsOrderChargesState>(
        stream: _esOrderChargesBloc.esOrdersStateObservable,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox.shrink();
          }

          if (snapshot.data.loadingState == LoadingState.IDLE) {
            _esOrderChargesBloc.getChargesList();
            return CircularProgressIndicator();
          }

          if (snapshot.data.loadingState == LoadingState.LOADING) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data.loadingState == LoadingState.ERROR) {
            return SomethingWentWrong(
              onRetry: () {
                _esOrderChargesBloc.getChargesList();
              },
            );
          }
          return Container(
            padding: EdgeInsets.all(24),
            width: double.infinity,
            child: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.always,
              child: ListView.separated(
                itemCount: snapshot.data.chargesMap.length,
                separatorBuilder: (context, index) => SizedBox(height: 20),
                itemBuilder: (context, index) {
                  final EsOrderChargesModel chargeData =
                      snapshot.data.chargesMap[
                          snapshot.data.chargesMap.keys.elementAt(index)];
                  return ChargeTile(
                    chargeData: chargeData,
                    textEditingController: _esOrderChargesBloc
                        .getControllerForChargeName(chargeData.chargeName),
                    onEditChargeType: (chargeType) =>
                        _esOrderChargesBloc.editChargeType(
                      chargeType: chargeType,
                      chargeName: chargeData.chargeName,
                    ),
                    onEditChargeValue: () =>
                        _esOrderChargesBloc.editChargeValue(
                      chargeName: chargeData.chargeName,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FoSubmitButton(
        text: AppTranslations.of(context).text("generic_update"),
        onPressed: () {
          if (formKey.currentState.validate()) {
            _esOrderChargesBloc.updateChargesList();
          } else {
            Fluttertoast.showToast(
                msg: AppTranslations.of(context).text("error_invalid_input"));
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class ChargeTile extends StatelessWidget {
  final EsOrderChargesModel chargeData;
  final TextEditingController textEditingController;
  final Function(String chargeType) onEditChargeType;
  final VoidCallback onEditChargeValue;

  const ChargeTile({
    @required this.chargeData,
    @required this.textEditingController,
    @required this.onEditChargeType,
    @required this.onEditChargeValue,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            chargeData.dChargeName,
            style: EsamudaayTheme.of(context)
                .textStyles
                .sectionHeading1
                .copyWith(color: EsamudaayTheme.of(context).colors.textColor),
          ),
        ),
        SizedBox(width: 20),
        Flexible(
          flex: 3,
          child: SizedBox(
            width: 150,
            child: TextFormField(
              keyboardType: TextInputType.number,
              controller: textEditingController,
              textAlign: TextAlign.right,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.deny(RegExp("[,]"))
              ],
              validator: (input) =>
                  chargeData.chargeType == ChargeTypeConstants.PERCENTAGE
                      ? Validators.percentageValue(input, context)
                      : Validators.nullValueCheck(input, context),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                suffixIcon: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    onChanged: onEditChargeType,
                    value: chargeData.chargeType,
                    items: [
                      DropdownMenuItem(
                        value: ChargeTypeConstants.FLAT,
                        child: Text("Rs."),
                      ),
                      DropdownMenuItem(
                        value: ChargeTypeConstants.PERCENTAGE,
                        child: Text("%"),
                      )
                    ],
                  ),
                ),
                contentPadding: const EdgeInsets.all(8),
              ),
              onChanged: (text) => onEditChargeValue(),
            ),
          ),
        ),
      ],
    );
  }
}
