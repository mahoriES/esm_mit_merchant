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

  static final putAddCategoriesToProduct = (String businessId, int productId) =>
      'businesses/$businessId/catalog/products/$productId/categories';
  static final delRemoveCategoryFromProduct = (String businessId, int productId,
          int categoryId) =>
      'businesses/$businessId/catalog/products/$productId/categories/$categoryId';
  static final patchUpdateProduct = (String businessId, int productId) =>
      'businesses/$businessId/catalog/products/$productId';
  static final delProduct = (String businessId, int productId) =>
      'businesses/$businessId/catalog/products/$productId';
  static final postAddProductToBusiness =
      (String businessId) => 'businesses/$businessId/catalog/products';
  static final getProducts =
      (String businessId) => 'businesses/$businessId/catalog/products';
  static final getProductsForCategory = (String businessId, int categoryId) =>
      'businesses/$businessId/catalog/categories/$categoryId/products';
  static final getCategoriesForProduct =
      (String businessId, String productId) =>
          'businesses/$businessId/catalog/products/$productId/categories';

  static final postAddCategory =
      (String businessId) => 'businesses/$businessId/catalog/categories';
  static final getCategories =
      (String businessId) => 'businesses/$businessId/catalog/categories';

  static const getProfiles = 'auth/profiles';
  static const postAddProfile = 'auth/profiles';
  static const patchUpdateProfile = 'auth/profiles';

  static const uploadPhoto = 'media/photo/';

  static final postAddSkuToProduct = (String businessId, int productId) =>
      'businesses/$businessId/catalog/products/$productId/skus';

  static final getOrders = (String businessId, {String orderStatus}) =>
      'orders/?business_id=$businessId' +
      (orderStatus == null ? '' : '&order_status=$orderStatus');

  static final postAcceptOrder = (String orderId) => 'orders/$orderId/accept';
  static final postCancelOrder = (String orderId) => 'orders/$orderId/cancel';
  static final postUpdateOrder = (String orderId) => 'orders/$orderId';
  static final orderPaymentUpdate =
      (String orderId) => 'orders/$orderId/payment';
  static final postOrderRequestDeliveryAgent =
      (String orderId) => 'orders/$orderId/request_delivery';
  static final postCompleteOrder =
      (String orderId) => 'orders/$orderId/complete';
  static final postReadyOrder = (String orderId) => 'orders/$orderId/ready';

  static final getOrderDetail = (String orderId) => 'orders/$orderId';

  static final getDeliveryAgents =
      (String businessId) => 'businesses/$businessId/deliveryagents';

  static final updateSku = (String businessId, int productId, int skuId) =>
      'businesses/$businessId/catalog/products/$productId/skus/$skuId';

  static final addFcmToken = 'notifications/mobile/tokens';

  // video feature endpoints
  static final getVideoPath = 'post/';
  static final getSignedUrl = 'media/video/url';
  static final publishVideo = (String videoId) => 'post/$videoId/publish';
  static final updateVideo = (String videoId) => 'post/$videoId';
}
