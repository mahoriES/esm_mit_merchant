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
    nameEditController.text = product.dProductName;
    shortDescriptionEditController.text = product.dProductDescription;
    longDescriptionEditController.text = product.dProductLongDescription;
    displayLine1EditController.text = product.dLine1;
    unitEditController.text = product.dUnit;
  }

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
      images: _esEditProductState.uploadedImages
          .map((e) => EsImage(photoId: e.photoId))
          .toList(),
      unitName: this.unitEditController.text,
      displayLine1: this.displayLine1EditController.text,
    );
    var payloadString = json.encode(payload.toJson());
    print(payloadString);
//     '''{
// 	"product_name":"Dettol-Extra2",[EsImage(photoId: "18d039fa-c478-4abc-852f-2e17d335d53c")]
// 	"unit_name":"Ml",
// 	"product_description":"Herbal, works!",
// 	"images":[{"photo_id": "18d039fa-c478-4abc-852f-2e17d335d53c"}],
// 	"long_description":"This is supposed to be long descripton.",
// 	"display_line_1":"5+5 Gram free"
// }'''
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

  addCategoriesToProduct(List<EsCategory> categories) {
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

  addSkuToProduct(onSuccess, onFail) {
    var payload = AddSkuPayload(
      basePrice: int.parse(skuPriceEditController.text) * 100,
      skuCode: skuCodeEditController.text,
    );
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

  setCurrentProduct(EsProduct product) {
    this._esEditProductState.currentProduct = product;
    updateControllers(product);
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

  Future<File> _pickImageFromGallery() async {
    final pickedFile =
        await ImagePicker.platform.pickImage(source: ImageSource.gallery);
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

  int get currentProductId => currentProduct.productId;

  // bool isProductInStock = false;

  get isNewProduct => currentProduct == null;

  EsEditProductState();
}
