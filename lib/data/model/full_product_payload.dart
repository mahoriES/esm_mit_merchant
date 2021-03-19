import 'es_product.dart';


  

class FullProductPayload {
  List<AddSkuPayload> skuInfo;
  EsAddProductPayload productInfo;
  CategoriesInfoForFullProduct categoriesInfo;

  FullProductPayload({this.skuInfo, this.productInfo, this.categoriesInfo});

  FullProductPayload.fromJson(Map<String, dynamic> json) {
    if (json['sku_info'] != null) {
      skuInfo = new List<AddSkuPayload>();
      json['sku_info'].forEach((v) {
        skuInfo.add(new AddSkuPayload.fromJson(v));
      });
    }
    productInfo = json['product_info'] != null
        ? new EsAddProductPayload.fromJson(json['product_info'])
        : null;
    categoriesInfo = json['categories_info'] != null
        ? new CategoriesInfoForFullProduct.fromJson(json['categories_info'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.skuInfo != null) {
      data['sku_info'] = this.skuInfo.map((v) => v.toJson()).toList();
    }
    if (this.productInfo != null) {
      data['product_info'] = this.productInfo.toJson();
    }
    if (this.categoriesInfo != null) {
      data['categories_info'] = this.categoriesInfo.toJson();
    }
    return data;
  }
}

class ProductInfo {
  String productName;

  ProductInfo({this.productName});

  ProductInfo.fromJson(Map<String, dynamic> json) {
    productName = json['product_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product_name'] = this.productName;
    return data;
  }
}

class CategoriesInfoForFullProduct {
  int categoryId;

  CategoriesInfoForFullProduct({this.categoryId});

  CategoriesInfoForFullProduct.fromJson(Map<String, dynamic> json) {
    categoryId = json['category_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['category_id'] = this.categoryId;
    return data;
  }
}
