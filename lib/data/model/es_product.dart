class EsAddProductPayload {
  String productName;
  String unitName;
  String productDescription;
  List<String> images;
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
    images = json['images'].cast<String>();
    longDescription = json['long_description'];
    displayLine1 = json['display_line_1'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product_name'] = this.productName;
    data['unit_name'] = this.unitName;
    data['product_description'] = this.productDescription;
    data['images'] = this.images;
    data['long_description'] = this.longDescription;
    data['display_line_1'] = this.displayLine1;
    return data;
  }
}

class EsUpdateProductPayload {
  String productName;
  String unitName;
  String productDescription;
  List<String> images;
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
    images = json['images'].cast<String>();
    longDescription = json['long_description'];
    displayLine1 = json['display_line_1'];
    inStock = json['in_stock'];
    isActive = json['is_active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product_name'] = this.productName;
    data['unit_name'] = this.unitName;
    data['product_description'] = this.productDescription;
    data['images'] = this.images;
    data['long_description'] = this.longDescription;
    data['display_line_1'] = this.displayLine1;
    data['in_stock'] = this.inStock;
    data['is_active'] = this.isActive;
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
  List<String> images;
  String longDescription;
  String displayLine1;
  String unitName;
  List<String> skus;

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
    images = json['images'].cast<String>();
    longDescription = json['long_description'];
    displayLine1 = json['display_line_1'];
    unitName = json['unit_name'];
    skus = json['skus'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product_id'] = this.productId;
    data['product_name'] = this.productName;
    data['product_description'] = this.productDescription;
    data['is_active'] = this.isActive;
    data['in_stock'] = this.inStock;
    data['images'] = this.images;
    data['long_description'] = this.longDescription;
    data['display_line_1'] = this.displayLine1;
    data['unit_name'] = this.unitName;
    data['skus'] = this.skus;
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