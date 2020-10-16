import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foore/data/constants/es_api_path.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/es_business.dart';
import 'package:foore/data/model/es_media.dart';

import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';

import 'es_businesses.dart';

class EsBusinessProfileBloc {
  static const FILENAME = 'es_business_profile.dart';
  static const CLASSNAME = 'EsBusinessProfileBloc';
  static void esdyPrint(String message) {
    debugPrint(FILENAME + " : " + CLASSNAME + " : " + message);
  }

  EsBusinessProfileState _esBusinessProfileState = new EsBusinessProfileState();
  final nameEditController = TextEditingController();
  final upiAddressEditController = TextEditingController();
  final descriptionEditController = TextEditingController();
  final addressEditController = TextEditingController();
  final cityEditController = TextEditingController();
  final pinCodeEditController = TextEditingController();
  final phoneNumberEditingControllers = TextEditingController();
  final notificationPhoneEditingControllers = TextEditingController();
  final notificationEmailEditingControllers = TextEditingController();
  final noticeEditController = TextEditingController();
  

  final HttpService httpService;
  final EsBusinessesBloc esBusinessesBloc;

  StreamSubscription subscription;

  BehaviorSubject<EsBusinessProfileState> _subjectEsBusinessProfileState;

  EsBusinessProfileBloc(this.httpService, this.esBusinessesBloc) {
    this._subjectEsBusinessProfileState =
        new BehaviorSubject<EsBusinessProfileState>.seeded(
            _esBusinessProfileState);
    this.subscription =
        this.esBusinessesBloc.esBusinessesStateObservable.listen((state) {
      this._esBusinessProfileState.selectedBusinessInfo =
          state.selectedBusiness;
      if (state.selectedBusiness != null) {
        this._esBusinessProfileState.hasDelivery =
            state.selectedBusiness.hasDelivery;
        this._esBusinessProfileState.isOpen = state.selectedBusiness.isOpen;
        this.nameEditController.text = state.selectedBusiness.dBusinessName;
        this.upiAddressEditController.text =
            state.selectedBusiness.dBusinessPaymentUpiAddress;

        this.cityEditController.text = state.selectedBusiness.dBusinessCity;
        this.pinCodeEditController.text =
            state.selectedBusiness.dBusinessPincode;
        this.addressEditController.text =
            state.selectedBusiness.dBusinessPrettyAddress;
        this.descriptionEditController.text =
            state.selectedBusiness.dBusinessDescription;
        this.noticeEditController.text = state.selectedBusiness.dBusinessNotice;
        this._esBusinessProfileState.currentLocationPoint =
            state.selectedBusiness.address != null
                ? state.selectedBusiness.address.locationPoint
                : null;
      }
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
    var payloadString = json.encode(payload.toJson());
    this._updateState();
    try {
      var httpResponse = await this.httpService.esPut(
          EsApiPaths.putUpdateBusinessAddress(
              this._esBusinessProfileState.selectedBusinessInfo.businessId),
          payloadString);
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

  updateNotice(onSuccess, onFail) {
    var payload =
        EsUpdateBusinessPayload(notice: this.noticeEditController.text);
    this.updateBusiness(payload, onSuccess, onFail);
  }

  updateUpiAddress(onSuccess, onFail) {
    var payload =
        EsUpdateBusinessPayload(upiAddress: this.upiAddressEditController.text);
    this.updateBusiness(payload, onSuccess, onFail);
  }

  updateUpiStatus(bool status, onSuccess, onFail) {
    var payload = EsUpdateBusinessPayload(upiStatus: status);
    this.updateBusiness(payload, onSuccess, onFail);
  }

  updateAddress(onSuccess, onFail) {
    var address = EsAddressPayload(
      addressName: '',
      geoAddr: EsGeoAddr(
        city: cityEditController.text,
        pincode: pinCodeEditController.text,
      ),
      lat: _esBusinessProfileState.currentLocationPoint != null
          ? _esBusinessProfileState.currentLocationPoint.lat
          : 0,
      lon: _esBusinessProfileState.currentLocationPoint != null
          ? _esBusinessProfileState.currentLocationPoint.lon
          : 0,
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

  addNotificationPhone(onSuccess, onFail) {
    var phones = List<String>();
    phones.addAll(
        _esBusinessProfileState.selectedBusinessInfo.notificationPhones);
    phones.add(this.notificationPhoneEditingControllers.text);
    var payload = EsUpdateBusinessPayload(notificationPhones: phones);
    this.updateBusiness(payload, onSuccess, onFail);
  }

  deleteNotificationPhoneWithNumber(number) {
    var phones = List<String>();
    phones.addAll(
        _esBusinessProfileState.selectedBusinessInfo.notificationPhones);
    phones.removeAt(phones.indexOf(number));
    var payload = EsUpdateBusinessPayload(notificationPhones: phones);
    this.updateBusiness(payload, null, null);
  }

  addNotificationEmail(onSuccess, onFail) {
    var emails = List<String>();
    emails.addAll(
        _esBusinessProfileState.selectedBusinessInfo.notificationEmails);
    emails.add(this.notificationEmailEditingControllers.text);
    var payload = EsUpdateBusinessPayload(notificationEmails: emails);
    this.updateBusiness(payload, onSuccess, onFail);
  }

  deleteNotificationEmail(number) {
    var emails = List<String>();
    emails.addAll(
        _esBusinessProfileState.selectedBusinessInfo.notificationEmails);
    emails.removeAt(emails.indexOf(number));
    var payload = EsUpdateBusinessPayload(notificationEmails: emails);
    this.updateBusiness(payload, null, null);
  }

  updateNotificationEmailStatus(bool status, onSuccess, onFail) {
    var payload = EsUpdateBusinessPayload(notifyViaEmail: status);
    this.updateBusiness(payload, onSuccess, onFail);
  }

  updateNotificationPhoneStatus(bool status, onSuccess, onFail) {
    var payload = EsUpdateBusinessPayload(notifyViaPhone: status);
    this.updateBusiness(payload, onSuccess, onFail);
  }

  dispose() {
    this._subjectEsBusinessProfileState.close();
    if (this.subscription != null) {
      this.subscription.cancel();
    }
  }

  Future<File> _pickImageFromGallery() async {
    final pickedFile =
        await ImagePicker.platform.pickImage(source: ImageSource.gallery);
    var file = new File(pickedFile.path);
    return file;
  }

  removeImage(EsImages image) {
    var existingImages = List<EsImages>();
    if (_esBusinessProfileState.selectedBusinessInfo.images != null) {
      _esBusinessProfileState.selectedBusinessInfo.images.forEach((element) {
        if (image.photoId != element.photoId) {
          existingImages.add(EsImages(photoId: element.photoId));
        }
      });
    }
    var updateBusinessPayload = EsUpdateBusinessPayload(
      images: existingImages,
    );
    this.updateBusiness(updateBusinessPayload, () {}, () {});
  }

  removeUploadableImage(EsUploadableFile image) {
    var index = this
        ._esBusinessProfileState
        .uploadingImages
        .indexWhere((element) => element.id == image.id);
    this._esBusinessProfileState.uploadingImages.removeAt(index);
    this._updateState();
  }

  selectAndUploadImage() async {
    try {
      var file = await _pickImageFromGallery();
      if (file != null) {
        final uploadableFile = EsUploadableFile(file);
        this
            ._esBusinessProfileState
            .uploadingImages
            .add(EsUploadableFile(file));
        this._updateState();
        try {
          var respnose =
              await this.httpService.esUpload(EsApiPaths.uploadPhoto, file);
          var uploadImageResponse =
              EsUploadImageResponse.fromJson(json.decode(respnose));

          var existingImages = List<EsImages>();
          if (_esBusinessProfileState.selectedBusinessInfo.images != null) {
            _esBusinessProfileState.selectedBusinessInfo.images
                .forEach((element) {
              existingImages.add(EsImages(photoId: element.photoId));
            });
          }
          existingImages.add(EsImages(photoId: uploadImageResponse.photoId));
          var updateBusinessPayload = EsUpdateBusinessPayload(
            images: existingImages,
          );

          this.updateBusiness(updateBusinessPayload, () {
            esdyPrint("sucess");
            var index = this
                ._esBusinessProfileState
                .uploadingImages
                .indexWhere((element) => element.id == uploadableFile.id);
            this._esBusinessProfileState.uploadingImages.removeAt(index);
            this._updateState();
          }, () {
            esdyPrint('failed');
            var index = this
                ._esBusinessProfileState
                .uploadingImages
                .indexWhere((element) => element.id == uploadableFile.id);
            this
                ._esBusinessProfileState
                .uploadingImages[index]
                .setUploadFailed();
            this._updateState();
          });
        } catch (err) {
          esdyPrint('failed');
          var index = this
              ._esBusinessProfileState
              .uploadingImages
              .indexWhere((element) => element.id == uploadableFile.id);
          this._esBusinessProfileState.uploadingImages[index].setUploadFailed();
          this._updateState();
        }
      }
    } catch (err) {}
  }

  setCurrentLocationPoint(lat, lng) {
    esdyPrint(lat + lng);
    this._esBusinessProfileState.currentLocationPoint =
        EsLocationPoint(lat: lat, lon: lng);
    this._updateState();
  }
}

class EsBusinessProfileState {
  bool isSubmitting;
  bool isSubmitSuccess;
  bool isSubmitFailed;
  bool hasDelivery = false;
  bool isOpen = false;
  EsBusinessInfo selectedBusinessInfo;
  List<EsUploadableFile> uploadingImages = List<EsUploadableFile>();
  EsLocationPoint currentLocationPoint;

  EsBusinessProfileState() {
    this.isSubmitting = false;
    this.isSubmitFailed = false;
    this.isSubmitSuccess = false;
  }
}
