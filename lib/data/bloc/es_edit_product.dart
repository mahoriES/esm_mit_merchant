import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_businesses.dart';
import 'package:foore/data/constants/es_api_path.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/es_product.dart';
import 'package:rxdart/rxdart.dart';

class EsEditProductBloc {
  EsEditProductState _esEditProductState = new EsEditProductState();
  final nameEditController = TextEditingController();
  final shortDescriptionEditController = TextEditingController();
  final longDescriptionEditController = TextEditingController();
  final HttpService httpService;
  final EsBusinessesBloc esBusinessesBloc;

  BehaviorSubject<EsEditProductState> _subjectEsEditProductState;

  EsEditProductBloc(this.httpService, this.esBusinessesBloc) {
    this._subjectEsEditProductState =
        new BehaviorSubject<EsEditProductState>.seeded(_esEditProductState);
  }

  Observable<EsEditProductState> get esEditProductStateObservable =>
      _subjectEsEditProductState.stream;

  addProduct(Function onAddProductSuccess) {
    print('add Product');
    this._esEditProductState.isSubmitting = true;
    this._esEditProductState.isSubmitFailed = false;
    this._esEditProductState.isSubmitSuccess = false;
    this._updateState();
    var payload = new EsAddProductPayload(
        productName: this.nameEditController.text,
        productDescription: this.shortDescriptionEditController.text,
        longDescription: this.longDescriptionEditController.text,
        images: [],
        unitName: '',
        displayLine1: '');
    var payloadString = json.encode(payload.toJson());
    print(payloadString);
    this.httpService.esPost(
        EsApiPaths.postAddProductToBusiness(
            this.esBusinessesBloc.getSelectedBusinessId()),
        '''{
	"product_name":"Dettol-Extra2",
	"unit_name":"Ml",
	"product_description":"Herbal, works!",
	"images":[{"photo_id": "18d039fa-c478-4abc-852f-2e17d335d53c"}],
	"long_description":"This is supposed to be long descripton.",
	"display_line_1":"5+5 Gram free"
}''').then((httpResponse) {
      if (httpResponse.statusCode == 200 ||
          httpResponse.statusCode == 202 ||
          httpResponse.statusCode == 201) {
        this._esEditProductState.isSubmitting = false;
        this._esEditProductState.isSubmitFailed = false;
        this._esEditProductState.isSubmitSuccess = true;
        var addedProduct = EsProduct.fromJson(json.decode(httpResponse.body));
        if (onAddProductSuccess != null) {
          onAddProductSuccess(addedProduct);
        }
      } else {
        this._esEditProductState.isSubmitting = false;
        this._esEditProductState.isSubmitFailed = true;
        this._esEditProductState.isSubmitSuccess = false;
      }
      this._updateState();
    }).catchError((onError) {
      this._esEditProductState.isSubmitting = false;
      this._esEditProductState.isSubmitFailed = true;
      this._esEditProductState.isSubmitSuccess = false;
      this._updateState();
    });
  }

  updateProduct(Function onUpdateProductSuccess) {
    print('update Product');
    this._esEditProductState.isSubmitting = true;
    this._esEditProductState.isSubmitFailed = false;
    this._esEditProductState.isSubmitSuccess = false;
    this._updateState();
    var payload = new EsUpdateProductPayload(
      productName: this.nameEditController.text,
      productDescription: this.shortDescriptionEditController.text,
      longDescription: this.longDescriptionEditController.text,
    );
    var payloadString = json.encode(payload.toJson());
    print(payloadString);
    this
        .httpService
        .esPatch(
            EsApiPaths.patchUpdateProduct(
                this.esBusinessesBloc.getSelectedBusinessId(),
                this._esEditProductState.currentProductId),
            payloadString)
        .then((httpResponse) {
      if (httpResponse.statusCode == 200 ||
          httpResponse.statusCode == 202 ||
          httpResponse.statusCode == 201) {
        this._esEditProductState.isSubmitting = false;
        this._esEditProductState.isSubmitFailed = false;
        this._esEditProductState.isSubmitSuccess = true;
        var updatedProduct = EsProduct.fromJson(json.decode(httpResponse.body));
        if (onUpdateProductSuccess != null) {
          onUpdateProductSuccess(updatedProduct);
        }
      } else {
        this._esEditProductState.isSubmitting = false;
        this._esEditProductState.isSubmitFailed = true;
        this._esEditProductState.isSubmitSuccess = false;
      }
      this._updateState();
    }).catchError((onError) {
      this._esEditProductState.isSubmitting = false;
      this._esEditProductState.isSubmitFailed = true;
      this._esEditProductState.isSubmitSuccess = false;
      this._updateState();
    });
  }

  setCurrentProduct(EsProduct product) {
    this._esEditProductState.currentProduct = product;
    // this._esEditProductState.isProductInStock = product.inStock;
    this._updateState();
  }

  setIsSubmitting(bool isSubmitting) {
    this._esEditProductState.isSubmitting = isSubmitting;
    this._updateState();
  }

  _updateState() {
    if (!this._subjectEsEditProductState.isClosed) {
      this._subjectEsEditProductState.sink.add(this._esEditProductState);
    }
  }

  dispose() {
    this._subjectEsEditProductState.close();
  }
}

class EsEditProductState {
  bool isSubmitting = false;
  bool isSubmitSuccess = false;
  bool isSubmitFailed = false;

  EsProduct currentProduct;

  get currentProductId => currentProduct.productId;

  // bool isProductInStock = false;

  get isNewProduct => currentProduct == null;

  EsEditProductState();
}
