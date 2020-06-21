class EsGetCategoriesResponse {
  List<EsCategory> categories;

  EsGetCategoriesResponse({this.categories});

  EsGetCategoriesResponse.fromJson(Map<String, dynamic> json) {
    if (json['categories'] != null) {
      categories = new List<EsCategory>();
      json['categories'].forEach((v) {
        categories.add(new EsCategory.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.categories != null) {
      data['categories'] = this.categories.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class EsAddCategoryPayload {
  String categoryName;
  String categoryDescription;
  List<String> images;

  EsAddCategoryPayload(
      {this.categoryName, this.categoryDescription, this.images});

  EsAddCategoryPayload.fromJson(Map<String, dynamic> json) {
    categoryName = json['category_name'];
    categoryDescription = json['category_description'];
    images = json['images'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['category_name'] = this.categoryName;
    data['category_description'] = this.categoryDescription;
    data['images'] = this.images;
    return data;
  }
}

class EsCategory {
  int categoryId;
  String categoryName;
  String categoryDescription;
  String parentCategoryId;
  bool isActive;
  List<String> images;

  get dCategoryName {
    if (categoryName != null) {
      return categoryName;
    }
    return '';
  }

  EsCategory(
      {this.categoryId,
      this.categoryName,
      this.categoryDescription,
      this.parentCategoryId,
      this.isActive,
      this.images});

  EsCategory.fromJson(Map<String, dynamic> json) {
    categoryId = json['category_id'];
    categoryName = json['category_name'];
    categoryDescription = json['category_description'];
    parentCategoryId = json['parent_category_id'];
    isActive = json['is_active'];
    images = json['images'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['category_id'] = this.categoryId;
    data['category_name'] = this.categoryName;
    data['category_description'] = this.categoryDescription;
    data['parent_category_id'] = this.parentCategoryId;
    data['is_active'] = this.isActive;
    data['images'] = this.images;
    return data;
  }
}

class EsGetCategoriesForProductResponse {
  List<EsCategory> categories;

  EsGetCategoriesForProductResponse({this.categories});

  EsGetCategoriesForProductResponse.fromJson(Map<String, dynamic> json) {
    if (json['categories'] != null) {
      categories = new List<EsCategory>();
      json['categories'].forEach((v) {
        categories.add(new EsCategory.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.categories != null) {
      data['categories'] = this.categories.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
