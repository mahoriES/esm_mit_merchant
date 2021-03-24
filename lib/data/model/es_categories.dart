import 'es_media.dart';

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
    if (this.categoryName != null) {
      data['category_name'] = this.categoryName;
    }
    if (this.categoryDescription != null) {
      data['category_description'] = this.categoryDescription;
    }
    if (this.images != null) {
      data['images'] = this.images;
    }
    return data;
  }
}

class EsAddSubCategoryPayload {
  String categoryName;
  int parentCategoryId;

  EsAddSubCategoryPayload({this.categoryName, this.parentCategoryId});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.categoryName != null) {
      data['category_name'] = this.categoryName;
    }
    data['parent_category_id'] = this.parentCategoryId;
    return data;
  }
}

class EsCategory {
  int categoryId;
  String categoryName;
  String categoryDescription;
  int parentCategoryId;
  bool isActive;
  List<EsUploadImageResponse> images;

  bool _isSelected;
  bool _isExpanded;

  get dCategoryName {
    if (categoryName != null) {
      return categoryName;
    }
    return '';
  }

  get dCategoryDescription {
    if (categoryDescription != null) {
      return categoryDescription;
    }
    return '';
  }

  get dImageUrl {
    if (images == null) {
      return '';
    }
    if (images.length == 0) {
      return '';
    }
    return images.first.photoUrl ?? '';
  }

  set dIsSelected(bool isSelected) {
    this._isSelected = isSelected;
  }

  set dIsExpanded(bool isExpanded) {
    this._isExpanded = isExpanded;
  }

  get dIsSelected => this._isSelected ?? false;

  get dIsExpanded => this._isExpanded ?? false;

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
    if (json['images'] != null) {
      images = new List<EsUploadImageResponse>();
      json['images'].forEach((v) {
        images.add(new EsUploadImageResponse.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['category_id'] = this.categoryId;
    data['category_name'] = this.categoryName;
    data['category_description'] = this.categoryDescription;
    data['parent_category_id'] = this.parentCategoryId;
    data['is_active'] = this.isActive;
    if (this.images != null) {
      data['images'] = this.images.map((v) => v.toJson()).toList();
    }
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

class AddCategoriesToProductPayload {
  List<int> categoryIds;

  AddCategoriesToProductPayload({this.categoryIds});

  AddCategoriesToProductPayload.fromJson(Map<String, dynamic> json) {
    categoryIds = json['category_ids'].cast<int>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['category_ids'] = this.categoryIds;
    return data;
  }
}
