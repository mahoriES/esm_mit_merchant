import 'dart:convert';
import 'package:foore/data/constants/es_api_path.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/es_business.dart';
import 'package:rxdart/rxdart.dart';

class EsBusinessesBloc {
  EsBusinessesState _esBusinessesState = new EsBusinessesState();
  final HttpService _httpService;

  BehaviorSubject<EsBusinessesState> _subjectEsBusinessesState;

  EsBusinessesBloc(this._httpService) {
    this._subjectEsBusinessesState =
        new BehaviorSubject<EsBusinessesState>.seeded(_esBusinessesState);
  }

  Observable<EsBusinessesState> get esBusinessesStateObservable =>
      _subjectEsBusinessesState.stream;

  getData() {
    print('getData');
      this.getBusinesses();
    // if (this._esBusinessesState.businesses.length == 0) {
    // }
  }

  getBusinesses() {
    this._esBusinessesState.isLoading = true;
    this._esBusinessesState.isLoadingFailed = false;
    this._esBusinessesState.businesses = [];
    this._updateState();
    _httpService.esGet(EsApiPaths.getBusinesses).then((httpResponse) {
      if (httpResponse.statusCode == 200) {
        this._esBusinessesState.isLoading = false;
        this._esBusinessesState.isLoadingFailed = false;
        this._esBusinessesState.setBusinessesResponse(
            EsGetBusinessesResponse.fromJson(json.decode(httpResponse.body)));
      } else {
        this._esBusinessesState.isLoadingFailed = true;
        this._esBusinessesState.isLoading = false;
      }
      this._updateState();
    }).catchError((onError) {
      this._esBusinessesState.isLoadingFailed = true;
      this._esBusinessesState.isLoading = false;
      this._updateState();
    });
  }

  setSelectedBusiness(EsBusinessInfo businessInfo) {
    print('setSelectedBusiness');
    this._esBusinessesState.selectedBusiness = businessInfo;
    this._updateState();
  }

  updateSelectedBusiness(EsBusinessInfo businessInfo) {
    print('setSelectedBusiness');
    this._esBusinessesState.selectedBusiness = businessInfo;
    this._updateState();
  }

  getSelectedBusinessId() {
    // print('get selected business id');
    // print(this._esBusinessesState.selectedBusiness.toJson().toString());
    return this._esBusinessesState.selectedBusinessId;
  }

  _updateState() {
    if (!this._subjectEsBusinessesState.isClosed) {
      this._subjectEsBusinessesState.sink.add(this._esBusinessesState);
    }
  }

  dispose() {
    this._subjectEsBusinessesState.close();
  }
}

class EsBusinessesState {
  bool isLoading;
  bool isLoadingFailed;

  get isShowBusinesses => !isLoading && businesses.length > 0;

  get isCreateBusinessRequired => !isLoading && businesses.length == 0;

  EsBusinessInfo selectedBusiness;

  get selectedBusinessId =>
      selectedBusiness != null ? selectedBusiness.businessId : null;

  EsGetBusinessesResponse businessesResponse;

  List<EsBusinessInfo> businesses;

  EsBusinessesState() {
    this.isLoading = false;
    this.isLoadingFailed = false;
    this.businesses = new List<EsBusinessInfo>();
  }

  setBusinessesResponse(EsGetBusinessesResponse response) {
    this.businessesResponse = response;
    this.businesses = response.results;
    if (this.businesses.length > 0) {
      selectedBusiness = this.businesses[0];
      print(selectedBusiness.businessId);
    }
  }
}
