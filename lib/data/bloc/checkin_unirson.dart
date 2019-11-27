import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foore/contacts_page/contacts_page.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/checkin.dart';
import 'package:foore/data/model/locations.dart';
import 'package:foore/data/model/sequence.dart';
import 'package:rxdart/rxdart.dart';

class CheckinUnirsonBloc {
  bool isFetched = false;
  CheckinUnirsonState _checkinUnirsonState = new CheckinUnirsonState();
  final nameEditController = TextEditingController();
  final phoneNumberEditController = TextEditingController();
  final HttpService _httpService;

  BehaviorSubject<CheckinUnirsonState> _subjectCheckinUnirsonState;

  CheckinUnirsonBloc(this._httpService) {
    this._subjectCheckinUnirsonState =
        new BehaviorSubject<CheckinUnirsonState>.seeded(_checkinUnirsonState);
  }

  Observable<CheckinUnirsonState> get checkinStateObservable =>
      _subjectCheckinUnirsonState.stream;

  getData() {
    this.getUiHelperData();
    this.getSequenceData();
  }

  getUiHelperData() {
    this._checkinUnirsonState.isLoadingUiHelper = true;
    this._checkinUnirsonState.uiHelperResponse = null;
    this._updateState();
    _httpService.foGet('ui/helper/account/?locations').then((httpResponse) {
      if (httpResponse.statusCode == 200) {
        this._checkinUnirsonState.isLoadingFailedUiHelper = false;
        this._checkinUnirsonState.isLoadingUiHelper = false;
        this._checkinUnirsonState.uiHelperResponse =
            UiHelperResponse.fromJson(json.decode(httpResponse.body));
        this._checkinUnirsonState.locations =
            this._checkinUnirsonState.uiHelperResponse.locations;
        this._checkinUnirsonState.selectedLocation =
            this._checkinUnirsonState.uiHelperResponse.locations.length > 0
                ? this._checkinUnirsonState.uiHelperResponse.locations[0]
                : null;
      } else {
        this._checkinUnirsonState.isLoadingFailedUiHelper = true;
        this._checkinUnirsonState.isLoadingUiHelper = false;
      }
      this._updateState();
    }).catchError((onError) {
      this._checkinUnirsonState.isLoadingFailedUiHelper = true;
      this._checkinUnirsonState.isLoadingUiHelper = false;
      this._updateState();
    });
  }

  getSequenceData() {
    this._checkinUnirsonState.isLoadingSequence = true;
    this._checkinUnirsonState.sequenceResponse = null;
    this._updateState();
    _httpService.foGet('sequence/all/').then((httpResponse) {
      if (httpResponse.statusCode == 200) {
        this._checkinUnirsonState.isLoadingSequence = false;
        this._checkinUnirsonState.isLoadingFailedSequence = false;
        this._checkinUnirsonState.sequenceResponse =
            SequenceResponse.fromJson(json.decode(httpResponse.body));
        this._checkinUnirsonState.sequences =
            this._checkinUnirsonState.sequenceResponse.results;
      } else {
        this._checkinUnirsonState.isLoadingFailedSequence = true;
        this._checkinUnirsonState.isLoadingSequence = false;
      }
      this._updateState();
    }).catchError((onError) {
      this._checkinUnirsonState.isLoadingFailedSequence = true;
      this._checkinUnirsonState.isLoadingSequence = false;
      this._updateState();
    });
  }

  checkin(String unirsonId, Function onCheckInSuccess) {
    this._checkinUnirsonState.isSubmitting = true;
    this._checkinUnirsonState.isSubmitFailed = false;
    this._checkinUnirsonState.isSubmitSuccess = false;
    this._updateState();
    var payload = new CheckInPayload(
      unirsonId: unirsonId,
      locationId: this._checkinUnirsonState.selectedLocation.fbLocationId,
      reviewSeq: this._checkinUnirsonState.isGmbReviewSelected ? 1 : 0,
      seqIds: this._checkinUnirsonState.sequences.takeWhile((sequence) {
        return sequence.isSelectedUi != null ? sequence.isSelectedUi : false;
      }).map((sequence) {
        return sequence.sequenceId;
      }).toList(),
    );
    var payloadString = json.encode(payload.toJson());
    print(payloadString);
    this
        ._httpService
        .foPost('instore/checkin/add/', payloadString)
        .then((httpResponse) {
      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 202) {
        this._checkinUnirsonState.isSubmitting = false;
        this._checkinUnirsonState.isSubmitFailed = false;
        this._checkinUnirsonState.isSubmitSuccess = true;
        if (onCheckInSuccess != null) {
          onCheckInSuccess();
        }
      } else {
        this._checkinUnirsonState.isSubmitting = false;
        this._checkinUnirsonState.isSubmitFailed = true;
        this._checkinUnirsonState.isSubmitSuccess = false;
      }
      this._updateState();
    }).catchError((onError) {
      this._checkinUnirsonState.isSubmitting = false;
      this._checkinUnirsonState.isSubmitFailed = true;
      this._checkinUnirsonState.isSubmitSuccess = false;
      this._updateState();
    });
  }

  checkinWithPhoneNumber(Function onCheckInSuccess) {
    this._checkinUnirsonState.isSubmitting = true;
    this._checkinUnirsonState.isSubmitFailed = false;
    this._checkinUnirsonState.isSubmitSuccess = false;
    this._updateState();
    var payload = new CheckInPayload(
      phoneTo: this.phoneNumberEditController.text,
      fullName: this.nameEditController.text,
      locationId: this._checkinUnirsonState.selectedLocation.fbLocationId,
      reviewSeq: this._checkinUnirsonState.isGmbReviewSelected ? 1 : 0,
      seqIds: this._checkinUnirsonState.sequences.takeWhile((sequence) {
        return sequence.isSelectedUi != null ? sequence.isSelectedUi : false;
      }).map((sequence) {
        return sequence.sequenceId;
      }).toList(),
    );
    var payloadString = json.encode(payload.toJson());
    this
        ._httpService
        .foPost('instore/checkin/add/', payloadString)
        .then((httpResponse) {
      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 202) {
        this._checkinUnirsonState.isSubmitting = false;
        this._checkinUnirsonState.isSubmitFailed = false;
        this._checkinUnirsonState.isSubmitSuccess = true;
        if (onCheckInSuccess != null) {
          onCheckInSuccess();
        }
      } else {
        this._checkinUnirsonState.isSubmitting = false;
        this._checkinUnirsonState.isSubmitFailed = true;
        this._checkinUnirsonState.isSubmitSuccess = false;
      }
      this._updateState();
    }).catchError((onError) {
      this._checkinUnirsonState.isSubmitting = false;
      this._checkinUnirsonState.isSubmitFailed = true;
      this._checkinUnirsonState.isSubmitSuccess = false;
      this._updateState();
    });
  }

  checkinWithMultipleContacts(Function onCheckInSuccess) {
    this._checkinUnirsonState.isSubmitting = true;
    this._checkinUnirsonState.isSubmitFailed = false;
    this._checkinUnirsonState.isSubmitSuccess = false;
    this._updateState();
    var payload = new CheckInPayload(
      phoneTo: this.phoneNumberEditController.text,
      fullName: this.nameEditController.text,
      locationId: this._checkinUnirsonState.selectedLocation.fbLocationId,
      reviewSeq: this._checkinUnirsonState.isGmbReviewSelected ? 1 : 0,
      seqIds: this._checkinUnirsonState.sequences.takeWhile((sequence) {
        return sequence.isSelectedUi != null ? sequence.isSelectedUi : false;
      }).map((sequence) {
        return sequence.sequenceId;
      }).toList(),
    );
    var payloadString = json.encode(payload.toJson());
    this
        ._httpService
        .foPost('instore/checkin/add/', payloadString)
        .then((httpResponse) {
      if (httpResponse.statusCode == 200 || httpResponse.statusCode == 202) {
        this._checkinUnirsonState.isSubmitting = false;
        this._checkinUnirsonState.isSubmitFailed = false;
        this._checkinUnirsonState.isSubmitSuccess = true;
        if (onCheckInSuccess != null) {
          onCheckInSuccess();
        }
      } else {
        this._checkinUnirsonState.isSubmitting = false;
        this._checkinUnirsonState.isSubmitFailed = true;
        this._checkinUnirsonState.isSubmitSuccess = false;
      }
      this._updateState();
    }).catchError((onError) {
      this._checkinUnirsonState.isSubmitting = false;
      this._checkinUnirsonState.isSubmitFailed = true;
      this._checkinUnirsonState.isSubmitSuccess = false;
      this._updateState();
    });
  }

  setSelectedLocation(LocationItem locationItem) {
    this._checkinUnirsonState.selectedLocation = locationItem;
    this._updateState();
  }

  setIsSubmitting(bool isSubmitting) {
    this._checkinUnirsonState.isSubmitting = isSubmitting;
    this._updateState();
  }

  setIsGmbReviewSelected(bool isGmbReviewSelected) {
    this._checkinUnirsonState.isGmbReviewSelected = isGmbReviewSelected;
    this._updateState();
  }

  setSequenceSelected(SequenceItem sequenceItem, bool isSelected) {
    sequenceItem.isSelectedUi = isSelected;
    this._updateState();
  }

  setNameAndPhoneNumber(String name, String phoneNumber) {
    this.nameEditController.text = name;
    this.phoneNumberEditController.text = phoneNumber;
    this._updateState();
  }

  _updateState() {
    if (!this._subjectCheckinUnirsonState.isClosed) {
      this._subjectCheckinUnirsonState.sink.add(this._checkinUnirsonState);
    }
  }

  dispose() {
    this._subjectCheckinUnirsonState.close();
  }

  setMultipleContacts(List<FoContact> contacts) {
    this._checkinUnirsonState.multipleContacts = contacts;
    this._updateState();
  }

  removeMultipleContacts() {
    this._checkinUnirsonState.multipleContacts = List<FoContact>();
    this._updateState();
  }
}

class CheckinUnirsonState {
  bool isLoadingUiHelper;
  bool isLoadingFailedUiHelper;

  bool isLoadingSequence;
  bool isLoadingFailedSequence;

  UiHelperResponse uiHelperResponse;
  SequenceResponse sequenceResponse;

  List<LocationItem> locations;
  List<SequenceItem> sequences;
  LocationItem selectedLocation;
  bool isSubmitting;
  bool isSubmitSuccess;
  bool isSubmitFailed;
  bool isGmbReviewSelected;
  List<FoContact> multipleContacts= List<FoContact>();
  bool get isMultipleContactsSelected => multipleContacts.length > 0;

  bool get isLoading => this.isLoadingUiHelper || this.isLoadingSequence;
  bool get isLoadingFailed =>
      this.isLoadingFailedUiHelper || this.isLoadingFailedSequence;

  CheckinUnirsonState() {
    this.isLoadingUiHelper = false;
    this.isLoadingFailedUiHelper = false;
    this.isSubmitting = false;
    this.isSubmitFailed = false;
    this.isSubmitSuccess = false;
    this.isGmbReviewSelected = true;
    this.locations = new List<LocationItem>();
  }
}

class UiHelperResponse {
  List<LocationItem> locations;

  UiHelperResponse({this.locations});

  UiHelperResponse.fromJson(Map<String, dynamic> json) {
    if (json['locations'] != null) {
      locations = new List<LocationItem>();
      json['locations'].forEach((v) {
        locations.add(new LocationItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.locations != null) {
      data['locations'] = this.locations.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
