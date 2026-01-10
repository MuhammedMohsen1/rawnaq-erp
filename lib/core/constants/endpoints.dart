abstract class ApiEndpoints {
  // Base URL - Backend is running on port 3001
  // Using 127.0.0.1 instead of localhost to avoid macOS permission issues
  static const String baseUrl = 'http://localhost:3001/api/v1';
  //   static const String baseUrl = 'http://localhost:3001/api/v1';
  //   static const String baseUrl = 'https://beenedeek.com/api/v1';
  // static const String baseUrl =
  //     'http://10.0.2.2:3001/api/v1'; // For Android emulator

  // Auth Endpoints
  static const String login = '/login-portal';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String resetPassword = '/auth/reset-password';
  static const String getCurrentUser = '/profile';
  static const String register = '/auth/register';

  // Notifications Endpoints
  static const String refreshFCMToken = '/notifications/refresh-token';

  // Admin Endpoints
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static String adminUserById(String id) => '/admin/users/$id';
  static String updateAdminUserStatus(String id) => '/admin/users/$id/status';
  static const String adminRestaurantsByZones = '/admin/restaurants/by-zones';

  // Admin Reports Endpoints
  static const String adminReports = '/admin/reports';
  static const String adminReportsOverview = '/admin/reports/overview';

  // Admin Delivery Man Management Endpoints
  static const String adminDeliveryMen = '/admin/delivery/men';
  static String adminDeliveryManById(String id) => '/admin/delivery/men/$id';
  static String updateDeliveryManStatus(String id) =>
      '/admin/delivery/men/$id/status';
  static String assignDeliveryManZone(String id) =>
      '/admin/delivery/men/$id/zone';
  static String deliveryManAnalytics(String id) =>
      '/admin/delivery/men/$id/analytics';
  static const String deliveryMenBulkUpdate = '/admin/delivery/men/bulk';
  static const String adminDeliveryZones = '/admin/delivery/zones';

  // Admin Orders Endpoints
  static const String adminOrders = '/admin/orders';
  static String adminOrderById(String id) => '/admin/orders/$id';
  static String updateAdminOrderStatus(String id) => '/admin/orders/$id/status';
  static String assignDeliveryToOrder(String id) =>
      '/admin/orders/$id/assign-delivery';
  static const String adminOrdersStatistics = '/admin/orders/statistics';
  static const String adminOrdersExport = '/admin/orders/export';
  static const String adminOrdersBulkAction = '/admin/orders/bulk-action';
  static String adminRefundOrderGroup(String orderGroupId) =>
      '/admin/orders/group/$orderGroupId/refund-and-deactivate';
  static String adminRefundOrderGroupOnly(String orderGroupId) =>
      '/admin/orders/group/$orderGroupId/refund';

  // Admin Mart Management Endpoints
  static const String adminMarts = '/admin/marts';
  static String adminMartById(String id) => '/admin/marts/$id';
  static String adminMartToggleStatus(String id) =>
      '/admin/marts/$id/toggle-status';
  static String adminMartStaff(String martId) => '/admin/marts/$martId/staff';
  static String adminMartStaffById(String martId, String staffId) =>
      '/admin/marts/$martId/staff/$staffId';
  static String adminMartStaffStatus(String martId, String staffId) =>
      '/admin/marts/$martId/staff/$staffId/status';
  static String adminMartsByZone(String zoneId) => '/admin/marts/zones/$zoneId';
  static String adminMartPerformance(String martId) =>
      '/admin/marts/$martId/performance';
  static const String adminTopPerformingMarts = '/admin/marts/top-performing';

  // Admin Advertisement Management Endpoints
  static const String adminAdvertisements = '/ads';
  static const String adminCreateAdvertisement = '/ads/admin';
  static String adminAdvertisementById(String id) => '/ads/$id';
  static String approveAdvertisement(String id) => '/ads/$id/approve';
  static const String adminAdvertisementAnalytics = '/ads/admin/analytics';
  static const String adminPricingTiers = '/ads/admin/pricing/tiers';
  static String adminPricingTierById(String id) =>
      '/ads/admin/pricing/tiers/$id';

  // Zone Management and Conflict Detection Endpoints
  static const String checkAdvertisementAvailability =
      '/ads/check-reserved-slots';
  static const String vendorZoneInfo = '/ads/admin/vendor/zone';
  static const String zoneDisplay = '/ads/admin/zone/display';
  static const String adminAdvertisementCreation = '/ads/admin/create';

  // Restaurant Profile Endpoints
  static const String restaurantProfile = '/restaurant/profile';
  static const String updateRestaurantProfile = '/restaurant/profile';
  static const String restaurantProfileStatus = '/restaurant/profile/status';
  static const String uploadRestaurantLogo = '/restaurant/logo';
  static const String restaurantMenu = '/restaurant/menu';
  static const String restaurantOperatingHours =
      '/restaurant/profile/operating-hours';

  // Category Management Endpoints
  static const String restaurantCategories = '/restaurant/categories';
  static const String restaurantCategoriesAll = '/restaurant/categories/all';
  static String categoryById(String id) => '/categories/$id';

  // Food Management Endpoints
  static const String foods = '/foods';
  static String foodById(String id) => '/foods/$id';
  static String menuItemById(String id) => '/restaurant/menu/$id';
  static String toggleMenuItemAvailability(String id) =>
      '/restaurant/menu/$id/toggle-availability';
  static String foodsByCategory(String categoryId) =>
      '/categories/$categoryId/foods';
  static String uploadFoodImage(String foodId) => '/foods/$foodId/image';

  // Order Management Endpoints
  static const String orders = '/orders';
  static String orderById(String id) => '/orders/$id';
  static String updateOrderStatus(String id) => '/orders/$id/status';
  static const String orderStatistics = '/orders/statistics';

  // Restaurant Order Endpoints
  static const String restaurantOrders = '/restaurant/orders';
  static String restaurantOrderById(String id) => '/restaurant/orders/$id';

  // Pickup Management Endpoints (Restaurant Orders)
  static const String pickupOrders = '/restaurant/orders';
  static String pickupOrderById(String id) => '/restaurant/orders/$id';
  static String acceptOrder(String id) => '/restaurant/orders/$id/accept';
  static String rejectOrder(String id) => '/restaurant/orders/$id/reject';
  static String prepareOrder(String id) => '/restaurant/orders/$id/prepare';
  static String finishOrder(String id) => '/restaurant/orders/$id/finish';
  static String pickupOrder(String id) => '/restaurant/orders/$id/picked-up';
  static const String searchPickupOrders = '/restaurant/pickup/orders/search';

  // Reports Endpoints
  static const String salesReport = '/reports/sales';
  static const String orderReport = '/reports/orders';
  static const String popularItemsReport = '/reports/popular-items';
  static const String revenueReport = '/reports/revenue';

  // Reviews Endpoints
  static const String reviews = '/reviews';
  static String reviewById(String id) => '/reviews/$id';
  static String respondToReview(String id) => '/reviews/$id/respond';

  // User Access Endpoints
  static const String users = '/users';
  static String userById(String id) => '/users/$id';
  static String activateUser(String id) => '/users/$id/activate';
  static String deactivateUser(String id) => '/users/$id/deactivate';

  // Dashboard Endpoints
  static const String dashboard = '/restaurant/dashboard';
  static const String dashboardStats = '/dashboard/stats';
  static const String dashboardNotifications = '/dashboard/notifications';
  static const String dashboardRecentOrders = '/dashboard/recent-orders';

  // Restaurant Deactivation Endpoints
  static const String deactivateRestaurant = '/restaurant/deactivate';
  static const String activateRestaurant = '/restaurant/activate';
  static const String getDeactivationReasons =
      '/restaurant/deactivation-reasons';

  // Admin Zone Management Endpoints
  static const String adminZones = '/admin/zones';
  static String adminZoneById(String id) => '/admin/zones/$id';
  static const String adminZoneHierarchy = '/admin/zones/hierarchy';
  static String adminZoneCanDelete(String id) => '/admin/zones/$id/can-delete';

  // Mart Admin Endpoints
  static const String categories = '/mart/admin/categories';
  static const String martAdminProfile = '/profile';
  static const String martAdminUpdateProfile = '/update-profile';
  static const String martInventory = '/mart/admin/inventory';
  static const String martStocktaking = '/mart/admin/stocktaking';
  static const String martProducts = '/mart/admin/products';
  static String martProductById(String productId) =>
      '/mart/admin/mart-products/$productId';
  static String martProductStock(String productId) =>
      '/mart-products/$productId/stock';
  static String martAdminProductStock(String productId) =>
      '/mart/admin/mart-products/$productId/stock';
  static String martProductsByBarcode(String barcode) =>
      '/mart/admin/products/barcode/$barcode';
  static const String martOrders = '/mart/admin/orders';
  static const String martToggleStatus = '/mart/admin/toggle-status';
  static const String martLowStock = '/mart/admin/low-stock';
  static const String martSalesAnalytics = '/mart/admin/reports/sales';
  static const String martProductPerformance = '/mart/admin/reports/products';
  static const String martProductsBulkUpdate =
      '/admin/mart-products/bulk-stock-update';
  static const String martPurchaseInvoices = '/mart/admin/purchase-invoices';
  static String martPurchaseInvoiceById(String invoiceId) =>
      '/mart/admin/purchase-invoices/$invoiceId';

  // Admin Product Gallery Endpoints - Following API v1 structure
  static const String adminProductGallery = '/product-gallery';
  static String adminProductGalleryById(String id) => '/product-gallery/$id';
  static String adminProductGalleryToggleStatus(String id) =>
      '/product-gallery/$id/toggle-status';
  static String adminProductGalleryByCategory(String categoryId) =>
      '/product-gallery/category/$categoryId';
  static const String adminProductGalleryStats = '/product-gallery/stats';
  static String adminProductGalleryRecordUsage(String id) =>
      '/product-gallery/$id/record-usage';
  static const String adminProductGalleryBulkDelete =
      '/product-gallery/bulk-delete';
  static String adminProductGalleryDuplicate(String id) =>
      '/product-gallery/$id/duplicate';
  static String adminProductGalleryGrouped() => '/product-gallery/grouped';

  // Mart Admin Gallery Requests Endpoints
  static const String martGalleryRequests = '/mart/admin/gallery/requests';
  static String martGalleryRequestById(String id) =>
      '/mart/admin/gallery/requests/$id';

  // Admin Gallery Requests Endpoints
  static const String adminGalleryRequests = '/admin/gallery/requests';
  static String adminGalleryRequestById(String id) =>
      '/admin/gallery/requests/$id';
  static String adminGalleryRequestApprove(String id) =>
      '/admin/gallery/requests/$id/approve';
  static String adminGalleryRequestReject(String id) =>
      '/admin/gallery/requests/$id/reject';

  // Mart Product Gallery Integration Endpoints
  static String martProductWithGallery(String martId) =>
      '/marts/$martId/products/with-gallery';
  static String martCategoryProductsWithGallery(
    String martId,
    String categoryId,
  ) => '/marts/$martId/categories/$categoryId/products-with-gallery';
  static String martProductImageUpdate(String productId) =>
      '/mart-products/$productId/image';

  // Projects Endpoints
  static const String projects = '/projects';
  static String projectById(String id) => '/projects/$id';
  static String updateProjectStatus(String id) => '/projects/$id/status';

  // Pricing Endpoints
  static String pricingVersions(String projectId) =>
      '/projects/$projectId/pricing';
  static String pricingVersion(String projectId, int version) =>
      '/projects/$projectId/pricing/$version';
  static String updatePricingVersion(String projectId, int version) =>
      '/projects/$projectId/pricing/$version';
  static String pricingItems(String projectId, int version) =>
      '/projects/$projectId/pricing/$version/items';
  static String pricingItem(String projectId, int version, String itemId) =>
      '/projects/$projectId/pricing/$version/items/$itemId';
  static String deletePricingItem(
    String projectId,
    int version,
    String itemId,
  ) => '/projects/$projectId/pricing/$version/items/$itemId';
  static String pricingSubItems(String projectId, int version, String itemId) =>
      '/projects/$projectId/pricing/$version/items/$itemId/sub-items';
  static String pricingSubItem(
    String projectId,
    int version,
    String itemId,
    String subItemId,
  ) =>
      '/projects/$projectId/pricing/$version/items/$itemId/sub-items/$subItemId';
  static String deletePricingSubItem(
    String projectId,
    int version,
    String itemId,
    String subItemId,
  ) =>
      '/projects/$projectId/pricing/$version/items/$itemId/sub-items/$subItemId';
  static String pricingSubItemImages(
    String projectId,
    int version,
    String itemId,
    String subItemId,
  ) =>
      '/projects/$projectId/pricing/$version/items/$itemId/sub-items/$subItemId/images';
  static String deletePricingSubItemImage(
    String projectId,
    int version,
    String itemId,
    String subItemId,
  ) =>
      '/projects/$projectId/pricing/$version/items/$itemId/sub-items/$subItemId/images';
  static String pricingElements(
    String projectId,
    int version,
    String itemId,
    String subItemId,
  ) =>
      '/projects/$projectId/pricing/$version/items/$itemId/sub-items/$subItemId/elements';
  static String pricingElement(
    String projectId,
    int version,
    String itemId,
    String subItemId,
    String elementId,
  ) =>
      '/projects/$projectId/pricing/$version/items/$itemId/sub-items/$subItemId/elements/$elementId';
  static String updateSubItemProfitMargin(
    String projectId,
    int version,
    String itemId,
    String subItemId,
  ) =>
      '/projects/$projectId/pricing/$version/items/$itemId/sub-items/$subItemId/profit-margin';
  static String calculateProfit(String projectId, int version) =>
      '/projects/$projectId/pricing/$version/calculate-profit';
  static String calculateSubItemProfit(String projectId, int version) =>
      '/projects/$projectId/pricing/$version/calculate-subitem-profit';
  static String submitForApproval(String projectId, int version) =>
      '/projects/$projectId/pricing/$version/submit-approval';
  static String approvePricing(String projectId, int version) =>
      '/projects/$projectId/pricing/$version/approve';
  static String rejectPricing(String projectId, int version) =>
      '/projects/$projectId/pricing/$version/reject';
  static String returnToPricing(String projectId, int version) =>
      '/projects/$projectId/pricing/$version/return-to-pricing';
  static String confirmPricing(String projectId, int version) =>
      '/projects/$projectId/pricing/$version/confirm';
  static String exportPricingPdf(String projectId, int version) =>
      '/projects/$projectId/pricing/$version/export-pdf';
  static String exportPricingImages(String projectId, int version) =>
      '/projects/$projectId/pricing/$version/export-images';
  static String toggleItemVisibility(
    String projectId,
    int version,
    String itemId,
  ) => '/projects/$projectId/pricing/$version/items/$itemId/visibility';
  static String toggleSubItemVisibility(
    String projectId,
    int version,
    String itemId,
    String subItemId,
  ) => '/projects/$projectId/pricing/$version/items/$itemId/sub-items/$subItemId/visibility';

  // Contract Endpoints
  static String contract(String projectId) => '/projects/$projectId/contract';
  static String exportContractPdf(String projectId) =>
      '/projects/$projectId/contract/export-pdf';
  static String confirmContract(String projectId) =>
      '/projects/$projectId/contract/confirm';
  static String returnContractToPricing(String projectId) =>
      '/projects/$projectId/contract/return-to-pricing';

  // Settings Endpoints
  static const String contractTerms = '/settings/contract-terms';
}
