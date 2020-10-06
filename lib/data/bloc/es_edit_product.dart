import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foore/data/bloc/es_businesses.dart';
import 'package:foore/data/constants/es_api_path.dart';
import 'package:foore/data/http_service.dart';
import 'package:foore/data/model/es_categories.dart';
import 'package:foore/data/model/es_media.dart';
import 'package:foore/data/model/es_product.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';

class EsEditProductBloc {
  EsEditProductState _esEditProductState = new EsEditProductState();
  final nameEditController = TextEditingController();
  final shortDescriptionEditController = TextEditingController();
  final longDescriptionEditController = TextEditingController();
  final displayLine1EditController = TextEditingController();
  final unitEditController = TextEditingController();
  final skuPriceEditController = TextEditingController();
  final skuCodeEditController = TextEditingController();
  final skuVariationValueEditController = TextEditingController();
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
    shortDescriptionEditController.text = product?.dProductDescription;
    longDescriptionEditController.text = product?.dProductLongDescription;
    displayLine1EditController.text = product?.dLine1;
    unitEditController.text = product?.dUnit;
  }

  updateControllersForSku(EsSku sku) {
    skuCodeEditController.text = sku.skuCode;
    skuPriceEditController.text = (sku.basePrice / 100).toString();
    skuVariationValueEditController.text = sku.variationValue;
  }

  addProduct(Function onAddProductSuccess) {
    //print('add Product');
    this._esEditProductState.isSubmitting = true;
    this._esEditProductState.isSubmitFailed = false;
    this._esEditProductState.isSubmitSuccess = false;
    this._updateState();
    var payload = new EsAddProductPayload(
      productName: this.nameEditController.text,
      productDescription: this.shortDescriptionEditController.text,
      longDescription: this.longDescriptionEditController.text,
      images: _esEditProductState.uploadedImages
          .map((e) => EsImage(photoId: e.photoId))
          .toList(),
      unitName: this.unitEditController.text,
      displayLine1: this.displayLine1EditController.text,
    );
    var payloadString = json.encode(payload.toJson());
    //print(payloadString);
    this
        .httpService
        .esPost(
            EsApiPaths.postAddProductToBusiness(
                this.esBusinessesBloc.getSelectedBusinessId()),
            payloadString)
        .then((httpResponse) {
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

  updateProduct(
      EsUpdateProductPayload payload,
      Function(EsProduct) onUpdateProductSuccess,
      Function onUpdateProductFailed) {
    this._esEditProductState.isSubmitting = true;
    this._esEditProductState.isSubmitFailed = false;
    this._esEditProductState.isSubmitSuccess = false;
    this._updateState();
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
        this._esEditProductState.currentProduct = updatedProduct;
        updateControllers(updatedProduct);
        if (onUpdateProductSuccess != null) {
          onUpdateProductSuccess(updatedProduct);
        }
      } else {
        this._esEditProductState.isSubmitting = false;
        this._esEditProductState.isSubmitFailed = true;
        this._esEditProductState.isSubmitSuccess = false;
        if (onUpdateProductFailed != null) {
          onUpdateProductFailed();
        }
      }
      this._updateState();
    }).catchError((onError) {
      print(onError.toString());
      this._esEditProductState.isSubmitting = false;
      this._esEditProductState.isSubmitFailed = true;
      this._esEditProductState.isSubmitSuccess = false;
      if (onUpdateProductFailed != null) {
        onUpdateProductFailed();
      }
      this._updateState();
    });
  }

  putCategoriesToProduct(List<EsCategory> categories) {
    var payload = AddCategoriesToProductPayload(
        categoryIds: categories.map((e) => e.categoryId).toList());
    this._esEditProductState.isSubmitting = true;
    this._esEditProductState.isSubmitFailed = false;
    this._esEditProductState.isSubmitSuccess = false;
    this._updateState();
    var payloadString = json.encode(payload.toJson());
    print(payloadString);
    this
        .httpService
        .esPut(
            EsApiPaths.putAddCategoriesToProduct(
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
        this._esEditProductState.categories.addAll(categories);
      } else {
        this._esEditProductState.isSubmitting = false;
        this._esEditProductState.isSubmitFailed = true;
        this._esEditProductState.isSubmitSuccess = false;
      }
      this._updateState();
    }).catchError((onError) {
      print(onError.toString());
      this._esEditProductState.isSubmitting = false;
      this._esEditProductState.isSubmitFailed = true;
      this._esEditProductState.isSubmitSuccess = false;
      this._updateState();
    });
  }

  addSkuToProduct(bool inStock, bool isActive, onSuccess, onFail) {
    var payload = AddSkuPayload(
        basePrice: (double.parse(skuPriceEditController.text) * 100).toInt(),
        skuCode: skuCodeEditController.text,
        variationValue: skuVariationValueEditController.text,
        inStock: inStock,
        isActive: isActive);
    this._esEditProductState.isSubmitting = true;
    this._esEditProductState.isSubmitFailed = false;
    this._esEditProductState.isSubmitSuccess = false;
    this._updateState();
    var payloadString = json.encode(payload.toJson());
    print(payloadString);
    this
        .httpService
        .esPost(
            EsApiPaths.postAddSkuToProduct(
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
        var addedSku = EsSku.fromJson(json.decode(httpResponse.body));
        this._esEditProductState.currentProduct.skus.add(addedSku);
        onSuccess();
      } else {
        this._esEditProductState.isSubmitting = false;
        this._esEditProductState.isSubmitFailed = true;
        this._esEditProductState.isSubmitSuccess = false;
        onFail();
      }
      this._updateState();
    }).catchError((onError) {
      print(onError.toString());
      this._esEditProductState.isSubmitting = false;
      this._esEditProductState.isSubmitFailed = true;
      this._esEditProductState.isSubmitSuccess = false;
      onFail();
      this._updateState();
    });
  }

  editCurrentSku(int skuId, bool inStock, bool isActive, onSuccess, onFail) {
    var payload = AddSkuPayload(
        basePrice: (double.parse(skuPriceEditController.text) * 100).toInt(),
        variationValue: skuVariationValueEditController.text,
        inStock: inStock,
        isActive: isActive);
    this._esEditProductState.isSubmitting = true;
    this._esEditProductState.isSubmitFailed = false;
    this._esEditProductState.isSubmitSuccess = false;
    this._updateState();
    var payloadString = json.encode(payload.toJson());
    print(payloadString);

    this
        .httpService
        .esPatch(
            EsApiPaths.updateSku(this.esBusinessesBloc.getSelectedBusinessId(),
                this._esEditProductState.currentProductId, skuId),
            payloadString)
        .then((httpResponse) {
      if (httpResponse.statusCode == 200 ||
          httpResponse.statusCode == 202 ||
          httpResponse.statusCode == 201) {
        this._esEditProductState.isSubmitting = false;
        this._esEditProductState.isSubmitFailed = false;
        this._esEditProductState.isSubmitSuccess = true;
        var updatedSku = EsSku.fromJson(json.decode(httpResponse.body));

        this._esEditProductState.currentProduct.updateSku(updatedSku);

        onSuccess();
      } else {
        this._esEditProductState.isSubmitting = false;
        this._esEditProductState.isSubmitFailed = true;
        this._esEditProductState.isSubmitSuccess = false;
        onFail();
      }
      this._updateState();
    }).catchError((onError) {
      print(onError.toString());
      this._esEditProductState.isSubmitting = false;
      this._esEditProductState.isSubmitFailed = true;
      this._esEditProductState.isSubmitSuccess = false;
      onFail();
      this._updateState();
    });
  }

  removeCategoryFromProduct(EsCategory category) {
    this._esEditProductState.isSubmitting = true;
    this._esEditProductState.isSubmitFailed = false;
    this._esEditProductState.isSubmitSuccess = false;
    this._updateState();
    this
        .httpService
        .esDel(EsApiPaths.delRemoveCategoryFromProduct(
            this.esBusinessesBloc.getSelectedBusinessId(),
            this._esEditProductState.currentProductId,
            category.categoryId))
        .then((httpResponse) {
      if (httpResponse.statusCode == 200 ||
          httpResponse.statusCode == 202 ||
          httpResponse.statusCode == 201) {
        this._esEditProductState.isSubmitting = false;
        this._esEditProductState.isSubmitFailed = false;
        this._esEditProductState.isSubmitSuccess = true;
        this._esEditProductState.categories = this
            ._esEditProductState
            .categories
            .where((element) => element.categoryId != category.categoryId)
            .toList();
      } else {
        this._esEditProductState.isSubmitting = false;
        this._esEditProductState.isSubmitFailed = true;
        this._esEditProductState.isSubmitSuccess = false;
      }
      this._updateState();
    }).catchError((onError) {
      print(onError.toString());
      this._esEditProductState.isSubmitting = false;
      this._esEditProductState.isSubmitFailed = true;
      this._esEditProductState.isSubmitSuccess = false;
      this._updateState();
    });
  }

  getCategories() {
    this._esEditProductState.isLoading = true;
    this._esEditProductState.response = null;
    this._esEditProductState.categories = List<EsCategory>();
    this._updateState();
    httpService
        .esGet(EsApiPaths.getCategoriesForProduct(
            this.esBusinessesBloc.getSelectedBusinessId(),
            this._esEditProductState.currentProduct.productId.toString()))
        .then((httpResponse) {
      if (httpResponse.statusCode == 200) {
        this._esEditProductState.isLoadingFailed = false;
        this._esEditProductState.isLoading = false;
        this._esEditProductState.response =
            EsGetCategoriesForProductResponse.fromJson(
                json.decode(httpResponse.body));
        this._esEditProductState.categories =
            this._esEditProductState.response.categories;
      } else {
        this._esEditProductState.isLoadingFailed = true;
        this._esEditProductState.isLoading = false;
      }
      this._updateState();
    }).catchError((onError) {
      this._esEditProductState.isLoadingFailed = true;
      this._esEditProductState.isLoading = false;
      this._updateState();
    });
  }

  Future<bool> updateSku(int skuId, payloadString) async {
    bool success = false;
    this._esEditProductState.isSubmitting = true;
    this._esEditProductState.isSubmitFailed = false;
    this._esEditProductState.isSubmitSuccess = false;
    this._updateState();

    try {
      var httpResponse = await this.httpService.esPatch(
          EsApiPaths.updateSku(this.esBusinessesBloc.getSelectedBusinessId(),
              this._esEditProductState.currentProductId, skuId),
          payloadString);
      if (httpResponse.statusCode == 200 ||
          httpResponse.statusCode == 202 ||
          httpResponse.statusCode == 201) {
        this._esEditProductState.isSubmitting = false;
        this._esEditProductState.isSubmitFailed = false;
        this._esEditProductState.isSubmitSuccess = true;
        success = true;
      } else {
        this._esEditProductState.isSubmitting = false;
        this._esEditProductState.isSubmitFailed = true;
        this._esEditProductState.isSubmitSuccess = false;
      }
    } catch (err) {
      print(err.toString());
      this._esEditProductState.isSubmitting = false;
      this._esEditProductState.isSubmitFailed = true;
      this._esEditProductState.isSubmitSuccess = false;
    }

    return success;
  }

  updateSkuInStock(int skuId, bool inStock) async {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['in_stock'] = inStock;
    var payloadString = json.encode(data);
    print(payloadString);
    bool sucess = await updateSku(skuId, payloadString);
    if (sucess) {
      this._esEditProductState.currentProduct.setInStockForSku(skuId, inStock);
    }
    this._updateState();
  }

  updateSkuInActive(int skuId, bool isActive) async {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['is_active'] = isActive;
    var payloadString = json.encode(data);
    print(payloadString);
    bool sucess = await updateSku(skuId, payloadString);
    if (sucess) {
      this
          ._esEditProductState
          .currentProduct
          .setIsActiveForSku(skuId, isActive);
    }
    this._updateState();
  }

  setCurrentProduct(EsProduct product) {
    this._esEditProductState.currentProduct = product;
    updateControllers(product);
    // this._esEditProductState.isProductInStock = product.inStock;
    this._updateState();
  }

  setCurrentSku(EsSku sku) {
    this._esEditProductState.currentSku = sku;
    updateControllersForSku(sku);
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

  removeImage(EsImage image) {
    var existingImages = List<EsImage>();
    if (_esEditProductState.currentProduct.images != null) {
      _esEditProductState.currentProduct.images.forEach((element) {
        if (image.photoId != element.photoId) {
          existingImages.add(EsImage(photoId: element.photoId));
        }
      });
    }
    var updateProductPayload = EsUpdateProductPayload(
      images: existingImages,
    );
    this.updateProduct(updateProductPayload, (product) {}, () {});
  }

  removeUploadableImage(EsUploadableFile image) {
    var index = this
        ._esEditProductState
        .uploadingImages
        .indexWhere((element) => element.id == image.id);
    this._esEditProductState.uploadingImages.removeAt(index);
    this._updateState();
  }

  removeUploadedImage(EsImage image) {
    var index = this
        ._esEditProductState
        .uploadedImages
        .indexWhere((element) => element.photoId == image.photoId);
    this._esEditProductState.uploadedImages.removeAt(index);
    this._updateState();
  }

  Future<File> _pickImageFromGallery() async {
    final pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      imageQuality: 25,
    );
    final file = new File(pickedFile.path);
    return file;
  }

  selectAndUploadImage() async {
    try {
      var file = await _pickImageFromGallery();
      if (file != null) {
        final uploadableFile = EsUploadableFile(file);
        this._esEditProductState.uploadingImages.add(EsUploadableFile(file));
        this._updateState();
        try {
          var respnose =
              await this.httpService.esUpload(EsApiPaths.uploadPhoto, file);
          var uploadImageResponse =
              EsUploadImageResponse.fromJson(json.decode(respnose));

          var existingImages = List<EsImage>();
          if (_esEditProductState.currentProduct.images != null) {
            _esEditProductState.currentProduct.images.forEach((element) {
              existingImages.add(EsImage(photoId: element.photoId));
            });
          }
          existingImages.add(EsImage(photoId: uploadImageResponse.photoId));
          var updateProductPayload = EsUpdateProductPayload(
            images: existingImages,
          );

          this.updateProduct(updateProductPayload, (product) {
            var index = this
                ._esEditProductState
                .uploadingImages
                .indexWhere((element) => element.id == uploadableFile.id);
            this._esEditProductState.uploadingImages.removeAt(index);
            this._updateState();
          }, () {
            var index = this
                ._esEditProductState
                .uploadingImages
                .indexWhere((element) => element.id == uploadableFile.id);
            this._esEditProductState.uploadingImages[index].setUploadFailed();
            this._updateState();
          });
        } catch (err) {
          var index = this
              ._esEditProductState
              .uploadingImages
              .indexWhere((element) => element.id == uploadableFile.id);
          this._esEditProductState.uploadingImages[index].setUploadFailed();
          this._updateState();
        }
      }
    } catch (err) {}
  }

  updateName(onSuccess, onFail) {
    var payload =
        EsUpdateProductPayload(productName: this.nameEditController.text);
    this.updateProduct(payload, onSuccess, onFail);
  }

  updateShortDescription(onSuccess, onFail) {
    var payload = EsUpdateProductPayload(
        productDescription: this.shortDescriptionEditController.text);
    this.updateProduct(payload, onSuccess, onFail);
  }

  updateLongDescription(onSuccess, onFail) {
    var payload = EsUpdateProductPayload(
        longDescription: this.longDescriptionEditController.text);
    this.updateProduct(payload, onSuccess, onFail);
  }

  updateDisplayLine1(onSuccess, onFail) {
    var payload = EsUpdateProductPayload(
        displayLine1: this.displayLine1EditController.text);
    this.updateProduct(payload, onSuccess, onFail);
  }

  updateUnit(onSuccess, onFail) {
    var payload =
        EsUpdateProductPayload(unitName: this.unitEditController.text);
    this.updateProduct(payload, onSuccess, onFail);
  }

  updateIsActive(isActive, onSuccess, onFail) {
    var payload = EsUpdateProductPayload(isActive: isActive);
    this.updateProduct(payload, onSuccess, onFail);
  }

  updateInStock(inStock, onSuccess, onFail) {
    var payload = EsUpdateProductPayload(inStock: inStock);
    this.updateProduct(payload, onSuccess, onFail);
  }

  selectAndUploadImageForAddProduct() async {
    try {
      var file = await _pickImageFromGallery();
      if (file != null) {
        final uploadableFile = EsUploadableFile(file);
        this._esEditProductState.uploadingImages.add(EsUploadableFile(file));
        this._updateState();
        try {
          var respnose =
              await this.httpService.esUpload(EsApiPaths.uploadPhoto, file);
          var uploadImageResponse =
              EsUploadImageResponse.fromJson(json.decode(respnose));

          this._esEditProductState.uploadedImages.add(
                EsImage(
                    photoId: uploadImageResponse.photoId,
                    contentType: uploadImageResponse.contentType,
                    photoUrl: uploadImageResponse.photoUrl),
              );
          var index = this
              ._esEditProductState
              .uploadingImages
              .indexWhere((element) => element.id == uploadableFile.id);
          this._esEditProductState.uploadingImages.removeAt(index);
          this._updateState();
        } catch (err) {
          var index = this
              ._esEditProductState
              .uploadingImages
              .indexWhere((element) => element.id == uploadableFile.id);
          this._esEditProductState.uploadingImages[index].setUploadFailed();
          this._updateState();
        }
      }
    } catch (err) {}
  }
}

class EsEditProductState {
  bool isLoading = true;
  bool isLoadingFailed = false;
  bool isSubmitting = false;
  bool isSubmitSuccess = false;
  bool isSubmitFailed = false;

  // Only used for creating product.
  List<EsImage> uploadedImages = List<EsImage>();

  List<EsUploadableFile> uploadingImages = List<EsUploadableFile>();

  List<EsCategory> categories = List<EsCategory>();
  EsGetCategoriesForProductResponse response;

  EsProduct currentProduct;
  EsSku currentSku;

  int get currentProductId => currentProduct?.productId;
  int get currentSkuId => currentSku?.skuId;

  bool get isNewProduct => currentProduct == null;
  bool get isNewSku => currentSku == null;

  EsEditProductState();
}
