import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foore/data/constants/es_api_path.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/es_business.dart';
import 'package:rxdart/rxdart.dart';

import 'es_businesses.dart';

class EsBusinessProfileBloc {
  EsBusinessProfileState _esBusinessProfileState = new EsBusinessProfileState();
  final nameEditController = TextEditingController();
  final descriptionEditController = TextEditingController();
  final addressEditController = TextEditingController();
  final cityEditController = TextEditingController();
  final pinCodeEditController = TextEditingController();
  final phoneNumberEditingControllers = TextEditingController();

  final HttpService httpService;
  final EsBusinessesBloc esBusinessesBloc;

  BehaviorSubject<EsBusinessProfileState> _subjectEsBusinessProfileState;

  EsBusinessProfileBloc(this.httpService, this.esBusinessesBloc) {
    this._subjectEsBusinessProfileState =
        new BehaviorSubject<EsBusinessProfileState>.seeded(
            _esBusinessProfileState);
    this.esBusinessesBloc.esBusinessesStateObservable.listen((state) {
      this._esBusinessProfileState.selectedBusinessInfo =
          state.selectedBusiness;
      this._esBusinessProfileState.hasDelivery =
          state.selectedBusiness.hasDelivery;
      this._esBusinessProfileState.isOpen = state.selectedBusiness.isOpen;
      this.nameEditController.text = state.selectedBusiness.dBusinessName;

      this.cityEditController.text = state.selectedBusiness.dBusinessCity;
      this.pinCodeEditController.text = state.selectedBusiness.dBusinessPincode;
      this.addressEditController.text =
          state.selectedBusiness.dBusinessPrettyAddress;
      this._updateState();
    });
  }

  Observable<EsBusinessProfileState> get createBusinessObservable =>
      _subjectEsBusinessProfileState.stream;

  updateBusiness(EsUpdateBusinessPayload payload,
      Function onUpdateBusinessSuccess, Function onUpdateError) async {
    this._esBusinessProfileState.isSubmitting = true;
    this._esBusinessProfileState.isSubmitFailed = false;
    this._esBusinessProfileState.isSubmitSuccess = false;
    this._updateState();
    try {
      var payloadString = json.encode(payload.toJson());
      var httpResponse = await this.httpService.esPatch(
          EsApiPaths.patchUpdateBusinessInfo(
              this._esBusinessProfileState.selectedBusinessInfo.businessId),
          payloadString);
      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) {
        this._esBusinessProfileState.isSubmitting = false;
        this._esBusinessProfileState.isSubmitFailed = false;
        this._esBusinessProfileState.isSubmitSuccess = true;
        var updatedBusinessInfo =
            EsBusinessInfo.fromJson(json.decode(httpResponse.body));
        this.esBusinessesBloc.updateSelectedBusiness(updatedBusinessInfo);
        if (onUpdateBusinessSuccess != null) {
          onUpdateBusinessSuccess();
        }
      } else {
        if (onUpdateError != null) {
          onUpdateError();
        }
        this._esBusinessProfileState.isSubmitting = false;
        this._esBusinessProfileState.isSubmitFailed = true;
        this._esBusinessProfileState.isSubmitSuccess = false;
      }
      this._updateState();
    } catch (onError) {
      if (onUpdateError != null) {
        onUpdateError();
      }
      this._esBusinessProfileState.isSubmitting = false;
      this._esBusinessProfileState.isSubmitFailed = true;
      this._esBusinessProfileState.isSubmitSuccess = false;
      this._updateState();
    }
  }

  markBusinessOpen(
      Function onUpdateBusinessSuccess, Function onUpdateError) async {
    this._esBusinessProfileState.isSubmitting = true;
    this._esBusinessProfileState.isSubmitFailed = false;
    this._esBusinessProfileState.isSubmitSuccess = false;
    this._updateState();
    try {
      var httpResponse = await this.httpService.esPost(
          EsApiPaths.postMarkBusinessOpen(
              this._esBusinessProfileState.selectedBusinessInfo.businessId),
          '{}');
      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) {
        this._esBusinessProfileState.isSubmitting = false;
        this._esBusinessProfileState.isSubmitFailed = false;
        this._esBusinessProfileState.isSubmitSuccess = true;
        var updatedBusinessInfo =
            EsBusinessInfo.fromJson(json.decode(httpResponse.body));
        this.esBusinessesBloc.updateSelectedBusiness(updatedBusinessInfo);
        if (onUpdateBusinessSuccess != null) {
          onUpdateBusinessSuccess(updatedBusinessInfo);
        }
      } else {
        if (onUpdateError != null) {
          onUpdateError();
        }
        this._esBusinessProfileState.isSubmitting = false;
        this._esBusinessProfileState.isSubmitFailed = true;
        this._esBusinessProfileState.isSubmitSuccess = false;
      }
      this._updateState();
    } catch (onError) {
      if (onUpdateError != null) {
        onUpdateError();
      }
      this._esBusinessProfileState.isSubmitting = false;
      this._esBusinessProfileState.isSubmitFailed = true;
      this._esBusinessProfileState.isSubmitSuccess = false;
      this._updateState();
    }
  }

  markBusinessClosed(
      Function onUpdateBusinessSuccess, Function onUpdateError) async {
    this._esBusinessProfileState.isSubmitting = true;
    this._esBusinessProfileState.isSubmitFailed = false;
    this._esBusinessProfileState.isSubmitSuccess = false;
    this._updateState();
    try {
      var httpResponse = await this.httpService.esDel(
          EsApiPaths.delMarkBusinessClosed(
              this._esBusinessProfileState.selectedBusinessInfo.businessId));
      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) {
        this._esBusinessProfileState.isSubmitting = false;
        this._esBusinessProfileState.isSubmitFailed = false;
        this._esBusinessProfileState.isSubmitSuccess = true;
        var updatedBusinessInfo =
            EsBusinessInfo.fromJson(json.decode(httpResponse.body));
        this.esBusinessesBloc.updateSelectedBusiness(updatedBusinessInfo);
        if (onUpdateBusinessSuccess != null) {
          onUpdateBusinessSuccess(updatedBusinessInfo);
        }
      } else {
        if (onUpdateError != null) {
          onUpdateError();
        }
        this._esBusinessProfileState.isSubmitting = false;
        this._esBusinessProfileState.isSubmitFailed = true;
        this._esBusinessProfileState.isSubmitSuccess = false;
      }
      this._updateState();
    } catch (onError) {
      if (onUpdateError != null) {
        onUpdateError();
      }
      this._esBusinessProfileState.isSubmitting = false;
      this._esBusinessProfileState.isSubmitFailed = true;
      this._esBusinessProfileState.isSubmitSuccess = false;
      this._updateState();
    }
  }

  addAddress(
      payload, Function onUpdateBusinessSuccess, Function onUpdateError) async {
    this._esBusinessProfileState.isSubmitting = true;
    this._esBusinessProfileState.isSubmitFailed = false;
    this._esBusinessProfileState.isSubmitSuccess = false;
    this._updateState();
    try {
      var httpResponse = await this.httpService.esPut(
          EsApiPaths.putUpdateBusinessAddress(
              this._esBusinessProfileState.selectedBusinessInfo.businessId),
          payload);
      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) {
        this._esBusinessProfileState.isSubmitting = false;
        this._esBusinessProfileState.isSubmitFailed = false;
        this._esBusinessProfileState.isSubmitSuccess = true;
        var updatedAddInfo = EsAddress.fromJson(json.decode(httpResponse.body));
        _esBusinessProfileState.selectedBusinessInfo.address = updatedAddInfo;
        this.esBusinessesBloc.updateSelectedBusiness(
            _esBusinessProfileState.selectedBusinessInfo);
        if (onUpdateBusinessSuccess != null) {
          onUpdateBusinessSuccess();
        }
      } else {
        if (onUpdateError != null) {
          onUpdateError();
        }
        this._esBusinessProfileState.isSubmitting = false;
        this._esBusinessProfileState.isSubmitFailed = true;
        this._esBusinessProfileState.isSubmitSuccess = false;
      }
      this._updateState();
    } catch (onError) {
      if (onUpdateError != null) {
        onUpdateError();
      }
      this._esBusinessProfileState.isSubmitting = false;
      this._esBusinessProfileState.isSubmitFailed = true;
      this._esBusinessProfileState.isSubmitSuccess = false;
      this._updateState();
    }
  }

  setIsSubmitting(bool isSubmitting) {
    this._esBusinessProfileState.isSubmitting = isSubmitting;
    this._updateState();
  }

  _updateState() {
    if (!this._subjectEsBusinessProfileState.isClosed) {
      this
          ._subjectEsBusinessProfileState
          .sink
          .add(this._esBusinessProfileState);
    }
  }

  setDelivery(bool value) async {
    this._esBusinessProfileState.hasDelivery = value;
    var payload = EsUpdateBusinessPayload(hasDelivery: value);
    this._updateState();
    this.updateBusiness(payload, null, () {
      this._esBusinessProfileState.hasDelivery =
          _esBusinessProfileState.hasDelivery;
      this._updateState();
    });
  }

  setOpen(bool value) async {
    if (value) {
      this._esBusinessProfileState.isOpen = value;
      this._updateState();
      this.markBusinessOpen(null, () {
        this._esBusinessProfileState.isOpen = _esBusinessProfileState.isOpen;
        this._updateState();
      });
    } else {
      this._esBusinessProfileState.isOpen = value;
      this._updateState();
      this.markBusinessClosed(null, () {
        this._esBusinessProfileState.isOpen = _esBusinessProfileState.isOpen;
        this._updateState();
      });
    }
  }

  updateName(onSuccess, onFail) {
    var payload =
        EsUpdateBusinessPayload(businessName: this.nameEditController.text);
    this.updateBusiness(payload, onSuccess, onFail);
  }

  updateDescription(onSuccess, onFail) {
    var payload = EsUpdateBusinessPayload(
        description: this.descriptionEditController.text);
    this.updateBusiness(payload, onSuccess, onFail);
  }

  updateAddress(onSuccess, onFail) {
    var address = EsAddressPayload(
      addressName: '',
      geoAddr: EsGeoAddr(
        city: cityEditController.text,
        pincode: pinCodeEditController.text,
      ),
      lat: 0,
      lon: 0,
      prettyAddress: addressEditController.text,
    );
    this.addAddress(address, onSuccess, onFail);
  }

  addPhone(onSuccess, onFail) {
    var phones = List<String>();
    phones.addAll(_esBusinessProfileState.selectedBusinessInfo.dPhones);
    phones.add(this.phoneNumberEditingControllers.text);
    var payload = EsUpdateBusinessPayload(phones: phones);
    this.updateBusiness(payload, onSuccess, onFail);
  }

  deletePhoneWithNumber(number) {
    var phones = List<String>();
    phones.addAll(_esBusinessProfileState.selectedBusinessInfo.dPhones);
    phones.removeAt(phones.indexOf(number));
    var payload = EsUpdateBusinessPayload(phones: phones);
    this.updateBusiness(payload, null, null);
  }

  dispose() {
    this._subjectEsBusinessProfileState.close();
  }
}

class EsBusinessProfileState {
  bool isSubmitting;
  bool isSubmitSuccess;
  bool isSubmitFailed;
  bool hasDelivery = false;
  bool isOpen = false;
  EsBusinessInfo selectedBusinessInfo;

  EsBusinessProfileState() {
    this.isSubmitting = false;
    this.isSubmitFailed = false;
    this.isSubmitSuccess = false;
  }
}
