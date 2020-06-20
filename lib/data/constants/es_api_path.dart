class EsApiPaths {
  static const getOTP = 'auth/token/';
  static const postToken = 'auth/token/';
  static const getUserInfo = 'auth/user/';
  static const postSignUp = 'auth/user/';

  static const getClusters = 'clusters/';

  static const getBusinesses = 'businesses/';
  static const postCreateBusiness = 'businesses/';
  static final postMarkBusinessOpen =
      (String businessId) => 'businesses/$businessId/open';
  static final delMarkBusinessClosed =
      (String businessId) => 'businesses/$businessId/open';
  static final putUpdateBusinessAddress =
      (String businessId) => 'businesses/$businessId/address';
  static final patchUpdateBusinessInfo =
      (String businessId) => 'businesses/$businessId';

  static final postAddCategoryToProduct =
      (String businessId, String productId) =>
          'businesses/$businessId/catalog/products/$productId/categories/';
  static final delRemoveCategoryFromProduct = (String businessId,
          String productId, String categoryId) =>
      'businesses/$businessId/catalog/products/$productId/categories/$categoryId/';
  static final patchUpdateProduct = (String businessId, String productId) =>
      'businesses/$businessId/catalog/products/$productId/';
  static final delProduct = (String businessId, String productId) =>
      'businesses/$businessId/catalog/products/$productId/';
  static final postAddProductToBusiness =
      (String businessId) => 'businesses/$businessId/catalog/products';
  static final getProducts =
      (String businessId) => 'businesses/$businessId/catalog/products';
  static final getCategoriesForProduct =
      (String businessId, String productId) =>
          'businesses/$businessId/catalog/products/$productId/categories/';

  static final postAddCategory =
      (String businessId) => 'businesses/$businessId/catalog/categories';
  static final getCategories =
      (String businessId) => 'businesses/$businessId/catalog/categories';

  static final getProfiles = 'auth/profiles';
  static final postAddProfile = 'auth/profiles';
  static final patchUpdateProfile = 'auth/profiles';
}
