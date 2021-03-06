import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_businesses.dart';
import 'package:foore/data/constants/es_api_path.dart';
import 'package:foore/data/constants/state_constants.dart';
import 'package:foore/data/constants/string_constants.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/es_categories.dart';
import 'package:foore/data/model/es_media.dart';
import 'package:foore/data/model/es_product.dart';
import 'package:foore/data/model/full_product_payload.dart';
import 'package:foore/utils/utils.dart';
import 'package:foore/widgets/image_cropper.dart';
import 'package:foore/widgets/image_picker_dialog.dart';
import 'package:rxdart/rxdart.dart';

class EsEditProductBloc {
  EsEditProductState _esEditProductState = new EsEditProductState();
  final nameEditController = TextEditingController();
  final shortDescriptionEditController = TextEditingController();
  final HttpService httpService;
  final EsBusinessesBloc esBusinessesBloc;

  BehaviorSubject<EsEditProductState> _subjectEsEditProductState;

  EsEditProductBloc(this.httpService, this.esBusinessesBloc) {
    this._subjectEsEditProductState =
        new BehaviorSubject<EsEditProductState>.seeded(_esEditProductState);
  }

  Observable<EsEditProductState> get esEditProductStateObservable =>
      _subjectEsEditProductState.stream;

  updateControllers(EsProduct product) {
    nameEditController.text = product?.dProductName;
    this._esEditProductState.preSelectedSKUs = product.skus.map((sku) {
      return EsProductSKUTamplate(
        skuCode: sku.skuCode,
        skuId: sku.skuId,
        inStock: sku.inStock,
        isActive: sku.isActive,
        price: sku.basePrice,
        quantity: sku.properties?.quant?.val,
        unit: sku.properties?.quant?.unit,
      );
    }).toList();
    this._esEditProductState.uploadedImages = product.images;
    this._esEditProductState.spotlight = product.spotlight ?? false;
    _updateState();
  }

  addProductFull(
      Function onAddProductSuccess, Function onAddProductFailed) async {
    this._esEditProductState.submitState = LoadingState.LOADING;
    this._updateState();
    final fullProductPayload = FullProductPayload(
        productInfo: EsAddProductPayload(
          productName: this.nameEditController.text,
          productDescription: this.shortDescriptionEditController.text,
          spotlight: this._esEditProductState.spotlight,
          inStock: this._esEditProductState.inStock,
          images: _esEditProductState.uploadedImages
              .map(
                (e) => EsImage(
                  photoId: e.photoId,
                  photoUrl: e.photoUrl,
                  contentType: e.contentType,
                ),
              )
              .toList(),
          // masterId: _esEditProductState.productMasterId,
        ),
        skuInfo: this._esEditProductState.preSelectedSKUs.map((element) {
          return AddSkuPayload(
            skuId: element.skuId,
            basePrice: Utils.getPriceInPaisa(element.price),
            properties: SKUProperties(
                quant: SKUQuant(
              unit: element.unit,
              val: element.quantity,
            )),
            inStock: element.inStock,
            isActive: element.isActive,
            // masterId: element.masterId,
          );
        }).toList(),
        // CategoriesInfo
        categoriesInfo:
            this._esEditProductState.preSelectedCategories.length > 0
                ? this
                    ._esEditProductState
                    .preSelectedCategories
                    .map((e) => CategoriesInfoForFullProduct(
                          categoryId: e.categoryId,
                        ))
                    .toList()[0]
                : null);
    final payloadString = json.encode(fullProductPayload.toJson());
    final httpResponse = await this.httpService.esPost(
        EsApiPaths.postAddFullProduct(
          this.esBusinessesBloc.getSelectedBusinessId(),
        ),
        payloadString);
    if (httpResponse.statusCode == 200) {
      this._esEditProductState.submitState = LoadingState.SUCCESS;
      final addedProduct = EsProduct.fromJson(json.decode(httpResponse.body));
      if (onAddProductSuccess != null) {
        onAddProductSuccess(addedProduct);
      }
    } else {
      this._esEditProductState.submitState = LoadingState.ERROR;
      if (onAddProductFailed != null) {
        onAddProductFailed();
      }
    }
    this._updateState();
  }

  updateProductFull(
      Function onUpdateProductSuccess, Function onUpdateProductFailed) async {
    this._esEditProductState.submitState = LoadingState.LOADING;
    this._updateState();
    final fullProductPayload = FullProductPayload(
        productInfo: EsAddProductPayload(
          productId: this._esEditProductState.currentProduct.productId,
          productName: this.nameEditController.text,
          productDescription: this.shortDescriptionEditController.text,
          spotlight: this._esEditProductState.spotlight,
          inStock: this._esEditProductState.inStock,
          images: _esEditProductState.uploadedImages
              .map(
                (e) => EsImage(
                  photoId: e.photoId,
                  photoUrl: e.photoUrl,
                  contentType: e.contentType,
                ),
              )
              .toList(),
          masterId: _esEditProductState.productMasterId,
        ),
        skuInfo: this._esEditProductState.preSelectedSKUs.map((element) {
          return AddSkuPayload(
            skuId: element.skuId,
            basePrice: Utils.getPriceInPaisa(element.price),
            properties: SKUProperties(
                quant: SKUQuant(
              unit: element.unit,
              val: element.quantity,
            )),
            inStock: element.inStock,
            isActive: element.isActive,
          );
        }).toList(),
        // CategoriesInfo
        categoriesInfo:
            this._esEditProductState.preSelectedCategories.length > 0
                ? this
                    ._esEditProductState
                    .preSelectedCategories
                    .map((e) => CategoriesInfoForFullProduct(
                          categoryId: e.categoryId,
                        ))
                    .toList()[0]
                : null);
    final payloadString = json.encode(fullProductPayload.toJson());

    debugPrint(payloadString);
    //print(payloadString);
    final httpResponse = await this.httpService.esPatch(
        EsApiPaths.patchUpdateFullProduct(
          this.esBusinessesBloc.getSelectedBusinessId(),
        ),
        payloadString);
    if (httpResponse.statusCode == 200) {
      this._esEditProductState.submitState = LoadingState.SUCCESS;
      final addedProduct = EsProduct.fromJson(json.decode(httpResponse.body));
      if (onUpdateProductSuccess != null) {
        onUpdateProductSuccess(addedProduct);
      }
    } else {
      this._esEditProductState.submitState = LoadingState.ERROR;
      if (onUpdateProductFailed != null) {
        onUpdateProductFailed();
      }
    }
    this._updateState();
  }

  getCategories() async {
    this._esEditProductState.loadingState = LoadingState.LOADING;
    this._esEditProductState.productCategoriesResponse = null;
    this._esEditProductState.categories = List<EsCategory>();
    this._updateState();
    // We need to load all categories to show the parent category in the UI.
    if (await getAllCategories()) {
      httpService
          .esGet(EsApiPaths.getCategoriesForProduct(
              this.esBusinessesBloc.getSelectedBusinessId(),
              this._esEditProductState.currentProduct.productId.toString()))
          .then((httpResponse) {
        if (httpResponse.statusCode == 200) {
          this._esEditProductState.loadingState = LoadingState.SUCCESS;
          this._esEditProductState.productCategoriesResponse =
              EsGetCategoriesForProductResponse.fromJson(
                  json.decode(httpResponse.body));
          this._esEditProductState.categories =
              this._esEditProductState.productCategoriesResponse.categories;
          this._esEditProductState.preSelectedCategories =
              this._esEditProductState.productCategoriesResponse.categories;
        } else {
          this._esEditProductState.loadingState = LoadingState.ERROR;
        }
        this._updateState();
      }).catchError((onError) {
        this._esEditProductState.loadingState = LoadingState.ERROR;
        this._updateState();
      });
    } else {
      this._esEditProductState.loadingState = LoadingState.ERROR;
      this._updateState();
    }
  }

  Future<bool> getAllCategories() async {
    if (this._esEditProductState.allCategoriesResponse != null) {
      return true;
    }
    try {
      final httpResponse = await httpService.esGet(
        EsApiPaths.getCategories(this.esBusinessesBloc.getSelectedBusinessId()),
      );
      if (httpResponse.statusCode == 200) {
        this._esEditProductState.allCategoriesResponse =
            EsGetCategoriesResponse.fromJson(json.decode(httpResponse.body));
        return true;
      }
      return false;
    } catch (err) {
      return false;
    }
  }

  setCurrentProduct(EsProduct product) {
    this._esEditProductState.currentProduct = product;
    updateControllers(product);
    this._updateState();
  }

  setIsSubmitting(LoadingState isSubmitting) {
    this._esEditProductState.submitState = isSubmitting;
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

  removeUploadableImage(EsUploadableFile image) {
    final index = this
        ._esEditProductState
        .uploadingImages
        .indexWhere((element) => element.id == image.id);
    this._esEditProductState.uploadingImages.removeAt(index);
    this._updateState();
  }

  removeUploadedImage(EsImage image) {
    final index = this
        ._esEditProductState
        .uploadedImages
        .indexWhere((element) => element.photoId == image.photoId);
    this._esEditProductState.uploadedImages.removeAt(index);
    this._updateState();
  }

  Future<File> _pickImageFromGallery(BuildContext context) async {
    final pickedFile =
        await ImagePickerDialog.showImagePickerBottomSheet(context);
    final file = new File(pickedFile.path);
    return file;
  }

  selectAndUploadImageForAddProduct(BuildContext context) async {
    try {
      final file = await _pickImageFromGallery(context);
      if (file != null) {
        final croppedImageFile =
            await ImageCropperView.getSquareCroppedImage(file);
        if (croppedImageFile == null) return;
        final uploadableFile = EsUploadableFile(croppedImageFile);
        this
            ._esEditProductState
            .uploadingImages
            .add(EsUploadableFile(croppedImageFile));
        this._updateState();
        try {
          final respnose = await this
              .httpService
              .esUpload(EsApiPaths.uploadPhoto, croppedImageFile);
          final uploadImageResponse =
              EsUploadImageResponse.fromJson(json.decode(respnose));

          this._esEditProductState.uploadedImages.add(
                EsImage(
                    photoId: uploadImageResponse.photoId,
                    contentType: uploadImageResponse.contentType,
                    photoUrl: uploadImageResponse.photoUrl),
              );
          final index = this
              ._esEditProductState
              .uploadingImages
              .indexWhere((element) => element.id == uploadableFile.id);
          this._esEditProductState.uploadingImages.removeAt(index);
          this._updateState();
        } catch (err) {
          final index = this
              ._esEditProductState
              .uploadingImages
              .indexWhere((element) => element.id == uploadableFile.id);
          this._esEditProductState.uploadingImages[index].setUploadFailed();
          this._updateState();
        }
      }
    } catch (err) {}
  }

  // Add Product flow
  addPreSelectedCategories(List<EsCategory> categories) {
    this._esEditProductState.preSelectedCategories = categories;
    this._updateState();
  }

  addPreSelectedSKU() {
    this._esEditProductState.preSelectedSKUs.add(EsProductSKUTamplate());
    this._updateState();
  }

  removePreSelectedCategory(int categoryId) {
    this
        ._esEditProductState
        .preSelectedCategories
        .removeWhere((element) => element.categoryId == categoryId);
    this._updateState();
  }

  removePreSelectedSKU(UniqueKey id) {
    // If the sku is already created we will deactivate it otherwise we will remove from the list.
    this._esEditProductState.preSelectedSKUs = this
        ._esEditProductState
        .preSelectedSKUs
        .fold<List<EsProductSKUTamplate>>([], (previousValue, element) {
      if (element.key == id) {
        if (element.skuCode != null) {
          element.isActive = false;
        } else {
          return previousValue;
        }
      }
      return [...previousValue, element];
    });
    this._updateState();
  }

  restorePreSelectedSKU(UniqueKey key) {
    this._esEditProductState.preSelectedSKUs = this
        ._esEditProductState
        .preSelectedSKUs
        .fold<List<EsProductSKUTamplate>>([], (previousValue, element) {
      if (element.key == key) {
        element.isActive = true;
      }
      return [...previousValue, element];
    });
    this._updateState();
  }

  updatePreSelectedSKUUnit(UniqueKey id, String unit) {
    this._esEditProductState.preSelectedSKUs.forEach((element) {
      if (element.key == id) {
        element.unit = unit;
      }
    });
    this._updateState();
  }

  updatePreSelectedSKUPrice(UniqueKey id, String price) {
    this._esEditProductState.preSelectedSKUs.forEach((element) {
      if (element.key == id) {
        element.price = price;
      }
    });
    this._updateState();
  }

  updatePreSelectedSKUQuantity(UniqueKey id, String quantity) {
    this._esEditProductState.preSelectedSKUs.forEach((element) {
      if (element.key == id) {
        element.quantity = quantity;
      }
    });
    this._updateState();
  }

  updatePreSelectedSKUStock(UniqueKey id, bool inStock) {
    this._esEditProductState.preSelectedSKUs.forEach((element) {
      if (element.key == id) {
        element.inStock = inStock;
      }
    });
    this._updateState();
  }

  updateProductStock(bool inStock) {
    this._esEditProductState.preSelectedSKUs.forEach((element) {
      if (element.isActive) {
        element.inStock = inStock;
      }
    });
    this._updateState();
  }

  updateProductSpotlight(bool spotlight) {
    this._esEditProductState.spotlight = spotlight;
    this._updateState();
  }

  List<String> getUnitsList(String preSelectedUnit) {
    List<String> unitList = [...StringConstants.unitsList];
    if (preSelectedUnit != null) {
      unitList.removeWhere((element) => preSelectedUnit == element);
      unitList = [preSelectedUnit, ...unitList];
    }
    return unitList;
  }
}

class EsEditProductState {
  LoadingState loadingState = LoadingState.IDLE;
  LoadingState submitState = LoadingState.IDLE;

  // Only used for creating product.
  List<EsImage> uploadedImages = List<EsImage>();

  List<EsUploadableFile> uploadingImages = List<EsUploadableFile>();

  EsGetCategoriesResponse allCategoriesResponse;

  List<EsCategory> categories = List<EsCategory>();
  EsGetCategoriesForProductResponse productCategoriesResponse;

  EsProduct currentProduct;
  EsSku currentSku;

  int get currentProductId => currentProduct?.productId;

  int get currentSkuId => currentSku?.skuId;

  bool get isNewProduct => currentProduct == null;

  bool get isNewSku => currentSku == null;

  int productMasterId;

  bool spotlight = false;
  bool get inStock => preSelectedActiveSKUs.fold(
      false,
      (previousValue, element) =>
          element.inStock ? element.inStock : previousValue);

  //Add Product flow
  List<EsCategory> preSelectedCategories = List<EsCategory>();

  List<EsProductSKUTamplate> preSelectedSKUs = [EsProductSKUTamplate()];

  List<EsProductSKUTamplate> get preSelectedActiveSKUs =>
      preSelectedSKUs.where((value) => value.isActive).toList();

  List<EsProductSKUTamplate> get preSelectedInactiveSKUs =>
      preSelectedSKUs.where((value) => !value.isActive).toList();

  EsProductSKUTamplate getPreSelectedSKU(Key key) {
    return preSelectedSKUs.firstWhere(
      (element) => element.key == key,
      orElse: () => null,
    );
  }

  EsCategory getCategoryById(int categoryId) {
    if (allCategoriesResponse == null) {
      return null;
    }
    return allCategoriesResponse.categories.firstWhere(
        (element) => element.categoryId == categoryId,
        orElse: () => null);
  }

  EsEditProductState();
}

class EsProductSKUTamplate {
  UniqueKey key;
  int masterId;
  String quantity;
  String unit;
  String price;
  String skuCode;
  bool isActive;
  bool inStock;
  int skuId;
  EsProductSKUTamplate({
    UniqueKey id,
    int masterId,
    String quantity,
    String unit,
    int price,
    String skuCode,
    bool isActive,
    bool inStock,
    int skuId,
  }) {
    this.key = id ?? new UniqueKey();
    this.quantity = quantity ?? '1';
    this.price = price != null ? (price / 100).toString() : '1.00';
    this.unit = unit ?? 'Piece';
    this.masterId = masterId;
    this.skuCode = skuCode;
    this.isActive = isActive ?? true;
    this.inStock = inStock ?? true;
    this.skuId = skuId;
  }
}
