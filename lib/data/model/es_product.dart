import 'package:intl/intl.dart';

class EsAddProductPayload {
  String productName;
  String unitName;
  String productDescription;
  List<EsImage> images;
  String longDescription;
  String displayLine1;

  EsAddProductPayload(
      {this.productName,
      this.unitName,
      this.productDescription,
      this.images,
      this.longDescription,
      this.displayLine1});

  EsAddProductPayload.fromJson(Map<String, dynamic> json) {
    productName = json['product_name'];
    unitName = json['unit_name'];
    productDescription = json['product_description'];
    if (json['images'] != null) {
      images = new List<EsImage>();
      json['images'].forEach((v) {
        images.add(new EsImage.fromJson(v));
      });
    }
    longDescription = json['long_description'];
    displayLine1 = json['display_line_1'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product_name'] = this.productName;
    data['unit_name'] = this.unitName;
    data['product_description'] = this.productDescription;
    if (this.images != null) {
      data['images'] = this.images.map((v) => v.toJson()).toList();
    }
    data['long_description'] = this.longDescription;
    data['display_line_1'] = this.displayLine1;
    return data;
  }
}

class EsUpdateProductPayload {
  String productName;
  String unitName;
  String productDescription;
  List<EsImage> images;
  String longDescription;
  String displayLine1;
  bool inStock;
  bool isActive;

  EsUpdateProductPayload(
      {this.productName,
      this.unitName,
      this.productDescription,
      this.images,
      this.longDescription,
      this.displayLine1,
      this.inStock,
      this.isActive});

  EsUpdateProductPayload.fromJson(Map<String, dynamic> json) {
    productName = json['product_name'];
    unitName = json['unit_name'];
    productDescription = json['product_description'];
    if (json['images'] != null) {
      images = new List<EsImage>();
      json['images'].forEach((v) {
        images.add(new EsImage.fromJson(v));
      });
    }
    longDescription = json['long_description'];
    displayLine1 = json['display_line_1'];
    inStock = json['in_stock'];
    isActive = json['is_active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.productName != null) {
      data['product_name'] = this.productName;
    }
    if (this.unitName != null) {
      data['unit_name'] = this.unitName;
    }
    if (this.productDescription != null) {
      data['product_description'] = this.productDescription;
    }
    if (this.images != null) {
      data['images'] = this.images.map((v) => v.toJson()).toList();
    }
    if (this.longDescription != null) {
      data['long_description'] = this.longDescription;
    }
    if (this.displayLine1 != null) {
      data['display_line_1'] = this.displayLine1;
    }
    if (this.inStock != null) {
      data['in_stock'] = this.inStock;
    }
    if (this.isActive != null) {
      data['is_active'] = this.isActive;
    }
    return data;
  }
}

class EsGetProductsResponse {
  int count;
  String next;
  String previous;
  List<EsProduct> results;

  EsGetProductsResponse({this.count, this.next, this.previous, this.results});

  EsGetProductsResponse.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    next = json['next'];
    previous = json['previous'];
    if (json['results'] != null) {
      results = new List<EsProduct>();
      json['results'].forEach((v) {
        results.add(new EsProduct.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    data['next'] = this.next;
    data['previous'] = this.previous;
    if (this.results != null) {
      data['results'] = this.results.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class EsProduct {
  int productId;
  String productName;
  String productDescription;
  bool isActive;
  bool inStock;
  List<EsImage> images;
  String longDescription;
  String displayLine1;
  String unitName;
  List<EsSku> skus;

  setInStockForSku(int skuId, bool inStock) {
    for (var sku in this.skus) {
      if (sku.skuId == skuId) {
        sku.setInStock(inStock);
        break;
      }
    }
  }

  setIsActiveForSku(int skuId, bool isActive) {
    for (var sku in this.skus) {
      if (sku.skuId == skuId) {
        sku.setIsActive(isActive);
        break;
      }
    }
  }

  updateSku(EsSku updatedSku) {
    for (EsSku currentSku in this.skus) {
      if (currentSku.skuId == updatedSku.skuId) {
        //Match
        currentSku.basePrice = updatedSku.basePrice;
        currentSku.variationOptions = updatedSku.variationOptions;
        currentSku.inStock = updatedSku.inStock;
        currentSku.isActive = updatedSku.isActive;
        currentSku.variationValue = updatedSku.variationValue;

        break;
      }
    }
  }

  get dProductName {
    if (productName != null) {
      return productName;
    }
    return '';
  }

  get dProductDescription {
    if (productDescription != null) {
      return productDescription;
    }
    return '';
  }

  get dProductLongDescription {
    if (longDescription != null) {
      return longDescription;
    }
    return '';
  }

  get dUnit {
    if (unitName != null) {
      return unitName;
    }
    return '';
  }

  get dLine1 {
    if (displayLine1 != null) {
      return displayLine1;
    }
    return '';
  }

  String get dPrice {
    if (skus.length > 0) {
      return skus[0].basePrice != null
          ? '${getPrice(skus[0].basePrice)}'
          : '₹ 0.00';
    }
    return '₹0.00';
  }

  String getPrice(price) {
    return NumberFormat.simpleCurrency(locale: 'en_IN').format(price / 100);
  }

  String get dPhotoUrl {
    if (images != null) {
      if (images.length > 0) {
        return images[0].photoUrl != null ? images[0].photoUrl : '';
      }
    }
    return '';
  }

  int get dNumberOfMoreVariations {
    final numberOfMoreVariations = skus.length - 1;
    return numberOfMoreVariations > 0 ? numberOfMoreVariations : 0;
  }

  int get dNumberOfMorePhotos {
    final numberOfMorePhotos = images.length - 1;
    return numberOfMorePhotos > 0 ? numberOfMorePhotos : 0;
  }

  EsProduct(
      {this.productId,
      this.productName,
      this.productDescription,
      this.isActive,
      this.inStock,
      this.images,
      this.longDescription,
      this.displayLine1,
      this.unitName,
      this.skus});

  EsProduct.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    productName = json['product_name'];
    productDescription = json['product_description'];
    isActive = json['is_active'];
    inStock = json['in_stock'];
    longDescription = json['long_description'];
    displayLine1 = json['display_line_1'];
    unitName = json['unit_name'];
    if (json['skus'] != null) {
      skus = new List<EsSku>();
      json['skus'].forEach((v) {
        skus.add(new EsSku.fromJson(v));
      });
    }
    if (json['images'] != null) {
      images = new List<EsImage>();
      json['images'].forEach((v) {
        images.add(new EsImage.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product_id'] = this.productId;
    data['product_name'] = this.productName;
    data['product_description'] = this.productDescription;
    data['is_active'] = this.isActive;
    data['in_stock'] = this.inStock;
    data['long_description'] = this.longDescription;
    data['display_line_1'] = this.displayLine1;
    data['unit_name'] = this.unitName;
    if (this.skus != null) {
      data['skus'] = this.skus.map((v) => v.toJson()).toList();
    }
    if (this.images != null) {
      data['images'] = this.images.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class EsAddCategoryToProductPayload {
  int categoryId;

  EsAddCategoryToProductPayload({this.categoryId});

  EsAddCategoryToProductPayload.fromJson(Map<String, dynamic> json) {
    categoryId = json['category_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['category_id'] = this.categoryId;
    return data;
  }
}

class EsSku {
  int skuId;
  String skuCode;
  bool isActive;
  bool inStock;
  Map<String, dynamic> charges;
  int basePrice;
  Map<String, dynamic> variationOptions;
  String variationValue;

  get dBasePrice {
    if (basePrice != null) {
      return getPrice(basePrice);
    }
    return '₹0.00';
  }

  String getPrice(price) {
    return NumberFormat.simpleCurrency(locale: 'en_IN').format(price / 100);
  }

  get dSkuCode {
    if (skuCode != null) {
      return skuCode;
    }
    return '';
  }

  get dVariationValue {
    if (variationValue != null) {
      return variationValue;
    }
    return '';
  }

  setInStock(bool inStock) {
    this.inStock = inStock;
  }

  setIsActive(bool isActive) {
    this.isActive = isActive;
  }

  EsSku(
      {this.skuId,
      this.skuCode,
      this.isActive,
      this.inStock,
      this.charges,
      this.basePrice,
      this.variationOptions});

  EsSku.fromJson(Map<String, dynamic> json) {
    skuId = json['sku_id'];
    skuCode = json['sku_code'];
    isActive = json['is_active'];
    inStock = json['in_stock'];
    charges = json['charges'];
    basePrice = json['base_price'];
    variationOptions = json['variation_options'];
    if (json.containsKey('variation_options') &&
        json['variation_options'] != null) {
      Map<String, dynamic> variationOptions = json['variation_options'];
      if (variationOptions.isNotEmpty) {
        variationValue = variationOptions.values.toList()[0];
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sku_id'] = this.skuId;
    // data['sku_code'] = this.skuCode;
    data['is_active'] = this.isActive;
    data['in_stock'] = this.inStock;
    data['charges'] = this.charges;
    if (variationValue != null && variationValue.isNotEmpty) {
      //final Map<String, dynamic> variation_options = new Map<String, dynamic>();
      //variation_options['variation_options'] = this.variationValue;
      //data['variation_options'] = variation_options;
      data['variation_options'] = {'Weight': this.variationValue};
    }
    return data;
  }
}

class EsImage {
  String photoId;
  String photoUrl;
  String contentType;

  EsImage({this.photoId, this.photoUrl, this.contentType});

  EsImage.fromJson(Map<String, dynamic> json) {
    photoId = json['photo_id'];
    photoUrl = json['photo_url'];
    contentType = json['content_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['photo_id'] = this.photoId;
    data['photo_url'] = this.photoUrl;
    data['content_type'] = this.contentType;
    return data;
  }
}

class AddSkuPayload {
  int basePrice;
  // String skuCode;
  String variationValue;
  bool isActive;
  bool inStock;

  AddSkuPayload(
      {this.basePrice,
      // this.skuCode,
      this.variationValue,
      this.isActive,
      this.inStock});

  AddSkuPayload.fromJson(Map<String, dynamic> inputJson) {
    basePrice = inputJson['base_price'];
    // skuCode = inputJson['sku_code'];
    isActive = inputJson['is_active'];
    inStock = inputJson['in_stock'];
    if (inputJson.containsKey('variation_option') &&
        inputJson['variation_option'] != null) {
      Map<String, dynamic> variationOptions = inputJson['variation_option'];
      if (variationOptions.isNotEmpty) {
        variationValue = variationOptions.values.toList()[0];
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['base_price'] = this.basePrice;
    // data['sku_code'] = this.skuCode;
    if (variationValue != null && variationValue.isNotEmpty) {
      //final Map<String, dynamic> variation_options = new Map<String, dynamic>();
      //variation_options['variation_options'] = this.variationValue;
      //data['variation_options'] = variation_options;
      data['variation_options'] = {'Weight': this.variationValue};
    }
    data['is_active'] = this.isActive;
    data['in_stock'] = this.inStock;
    return data;
  }
}
