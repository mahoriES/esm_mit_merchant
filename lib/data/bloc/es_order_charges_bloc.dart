import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_businesses.dart';
import 'package:foore/data/constants/es_api_path.dart';
import 'package:foore/data/constants/state_constants.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/es_order_charges.dart';
import 'package:foore/utils/utils.dart';
import 'package:http/http.dart';
import 'package:rxdart/rxdart.dart';

class EsOrderChargesBloc {
  final EsOrderChargesState _esOrderChargesState = new EsOrderChargesState();
  final HttpService httpService;
  final EsBusinessesBloc esBusinessesBloc;

  TextEditingController deliveryChargeController =
      new TextEditingController(text: "0");
  TextEditingController serviceChargeController =
      new TextEditingController(text: "0");
  TextEditingController packingChargeController =
      new TextEditingController(text: "0");
  TextEditingController otherChargeController =
      new TextEditingController(text: "0");

  BehaviorSubject<EsOrderChargesState> _subjectEsOrderChargesState;

  EsOrderChargesBloc(this.httpService, this.esBusinessesBloc) {
    this._subjectEsOrderChargesState =
        new BehaviorSubject<EsOrderChargesState>.seeded(_esOrderChargesState);
  }

  Observable<EsOrderChargesState> get esOrdersStateObservable =>
      _subjectEsOrderChargesState.stream;

  getChargesList() async {
    try {
      _esOrderChargesState.loadingState = LoadingState.LOADING;
      _updateState();

      Response response = await httpService.esGet(
        EsApiPaths.getBusinessCharges(esBusinessesBloc.getSelectedBusinessId()),
      );

      if (response.statusCode == 200) {
        dynamic data = jsonDecode(response.body);

        _parseChargesFromList(data);

        _esOrderChargesState.loadingState = LoadingState.SUCCESS;
        _updateState();
      } else {
        _esOrderChargesState.loadingState = LoadingState.ERROR;
        _updateState();
      }
    } catch (e) {
      _esOrderChargesState.loadingState = LoadingState.ERROR;
      _updateState();
    }
  }

  editChargeType({
    @required String chargeType,
    @required String chargeName,
  }) {
    _esOrderChargesState.chargesMap[chargeName].chargeType = chargeType;
    _updateState();
  }

  editChargeValue({@required String chargeName}) {
    if (_esOrderChargesState.chargesMap[chargeName].chargeType ==
        ChargeTypeConstants.FLAT) {
      _esOrderChargesState.chargesMap[chargeName].chargeValue =
          Utils.getPriceInPaisa(getControllerForChargeName(chargeName).text);
    } else {
      _esOrderChargesState.chargesMap[chargeName].chargeValue =
          Utils.getPriceInPercent(getControllerForChargeName(chargeName).text);
    }
  }

  updateChargesList() async {
    try {
      _esOrderChargesState.loadingState = LoadingState.LOADING;
      _updateState();

      List<EsOrderChargesModel> _chargesList =
          List.from(_esOrderChargesState.chargesMap.values);

      Response response = await httpService.esPut(
        EsApiPaths.getBusinessCharges(esBusinessesBloc.getSelectedBusinessId()),
        jsonEncode(_chargesList.map((v) => v.toJson()).toList()),
      );

      if (response.statusCode == 200) {
        dynamic data = jsonDecode(response.body);

        _parseChargesFromList(data);

        _esOrderChargesState.loadingState = LoadingState.SUCCESS;
        _updateState();
      } else {
        _esOrderChargesState.loadingState = LoadingState.ERROR;
        _updateState();
      }
    } catch (e) {
      _esOrderChargesState.loadingState = LoadingState.ERROR;
      _updateState();
    }
  }

  _parseChargesFromList(responseData) {
    _esOrderChargesState.chargesMap = {};

    responseData.forEach(
      (chargeData) {
        EsOrderChargesModel _chargeData =
            EsOrderChargesModel.fromJson(chargeData);

        switch (_chargeData.chargeName) {
          case ChargeNameConstants.DELIVERY:
            _esOrderChargesState.chargesMap[ChargeNameConstants.DELIVERY] =
                _chargeData;
            deliveryChargeController.text = _chargeData.dChargeValue;
            break;
          case ChargeNameConstants.TAX:
            _esOrderChargesState.chargesMap[ChargeNameConstants.TAX] =
                _chargeData;
            serviceChargeController.text = _chargeData.dChargeValue;
            break;
          case ChargeNameConstants.PACKING:
            _esOrderChargesState.chargesMap[ChargeNameConstants.PACKING] =
                _chargeData;
            packingChargeController.text = _chargeData.dChargeValue;
            break;
          case ChargeNameConstants.EXTRA:
            _esOrderChargesState.chargesMap[ChargeNameConstants.EXTRA] =
                _chargeData;
            otherChargeController.text = _chargeData.dChargeValue;
            break;
          default:
        }
      },
    );

    if (!_esOrderChargesState.chargesMap
        .containsKey(ChargeNameConstants.DELIVERY)) {
      _esOrderChargesState.chargesMap[ChargeNameConstants.DELIVERY] =
          EsOrderChargesModel(
        chargeName: ChargeNameConstants.DELIVERY,
        chargeType: ChargeTypeConstants.FLAT,
        chargeValue: 0,
      );
    }

    if (!_esOrderChargesState.chargesMap.containsKey(ChargeNameConstants.TAX)) {
      _esOrderChargesState.chargesMap[ChargeNameConstants.TAX] =
          EsOrderChargesModel(
        chargeName: ChargeNameConstants.TAX,
        chargeType: ChargeTypeConstants.FLAT,
        chargeValue: 0,
      );
    }
    if (!_esOrderChargesState.chargesMap
        .containsKey(ChargeNameConstants.PACKING)) {
      _esOrderChargesState.chargesMap[ChargeNameConstants.PACKING] =
          EsOrderChargesModel(
        chargeName: ChargeNameConstants.PACKING,
        chargeType: ChargeTypeConstants.FLAT,
        chargeValue: 0,
      );
    }
    if (!_esOrderChargesState.chargesMap
        .containsKey(ChargeNameConstants.EXTRA)) {
      _esOrderChargesState.chargesMap[ChargeNameConstants.EXTRA] =
          EsOrderChargesModel(
        chargeName: ChargeNameConstants.EXTRA,
        chargeType: ChargeTypeConstants.FLAT,
        chargeValue: 0,
      );
    }
  }

  TextEditingController getControllerForChargeName(String chargeName) {
    switch (chargeName) {
      case ChargeNameConstants.DELIVERY:
        return deliveryChargeController;
      case ChargeNameConstants.TAX:
        return serviceChargeController;
      case ChargeNameConstants.PACKING:
        return packingChargeController;
      case ChargeNameConstants.EXTRA:
        return otherChargeController;
      default:
        return null;
    }
  }

  _updateState() {
    if (!_subjectEsOrderChargesState.isClosed) {
      _subjectEsOrderChargesState.sink.add(_esOrderChargesState);
    }
  }

  dispose() {
    _subjectEsOrderChargesState.close();
  }
}

class EsOrderChargesState {
  Map<String, EsOrderChargesModel> chargesMap;
  LoadingState loadingState;

  EsOrderChargesState({
    this.loadingState = LoadingState.IDLE,
  });
}
