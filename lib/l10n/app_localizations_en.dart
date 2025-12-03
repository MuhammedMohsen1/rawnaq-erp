// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Been Edeek Portal';

  @override
  String get welcomeBack => 'Welcome Back!';

  @override
  String get signInToRestaurantPortal => 'Sign in to your restaurant portal';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get enterYourEmail => 'Enter your email';

  @override
  String get password => 'Password';

  @override
  String get enterYourPassword => 'Enter your password';

  @override
  String get signIn => 'Sign In';

  @override
  String get needHelp => 'Need help? Contact your system administrator';

  @override
  String get logout => 'Logout';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirmLogout => 'Are you sure you want to sign out?';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get dashboardOverview => 'Dashboard Overview';

  @override
  String get dashboardWelcomeMessage =>
      'Welcome back! Here\'s what\'s happening with your restaurant today.';

  @override
  String get todaysOrders => 'Today\'s Orders';

  @override
  String get revenue => 'Revenue';

  @override
  String get pendingOrders => 'Pending Orders';

  @override
  String get menuItems => 'Menu Items';

  @override
  String get revenueTrend => 'Revenue Trend';

  @override
  String get ordersOverview => 'Orders Overview';

  @override
  String get recentActivities => 'Recent Activities';

  @override
  String get viewAll => 'View All';

  @override
  String newOrderReceived(String orderId) {
    return 'New order #$orderId received';
  }

  @override
  String menuItemUpdated(String itemName) {
    return 'Menu item \"$itemName\" updated';
  }

  @override
  String orderCompleted(String orderId) {
    return 'Order #$orderId completed';
  }

  @override
  String newReviewReceived(int stars) {
    return 'New review received ($stars stars)';
  }

  @override
  String paymentReceived(String orderId) {
    return 'Payment received for order #$orderId';
  }

  @override
  String get foodManagement => 'Food Management';

  @override
  String get categories => 'Categories';

  @override
  String get orders => 'Orders';

  @override
  String get pickupManagement => 'Pickup Management';

  @override
  String get reviews => 'Reviews';

  @override
  String get workingHours => 'Working Hours';

  @override
  String get restaurantProfile => 'Restaurant Profile';

  @override
  String get userAccess => 'User Access';

  @override
  String get reports => 'Reports';

  @override
  String get deactivateRestaurant => 'Deactivate Restaurant';

  @override
  String get restaurantPortal => 'Restaurant Portal';

  @override
  String get managementSystem => 'Management System';

  @override
  String get menuManagement => 'Manage your restaurant\'s food items and menu';

  @override
  String get orderManagement => 'Order Management';

  @override
  String get orderManagementSubtitle => 'Track and manage all customer orders';

  @override
  String get categoryManagement => 'Category Management';

  @override
  String get advertisementManagement => 'Advertisement Management';

  @override
  String get pendingApproval => 'Pending Approval';

  @override
  String get pricingTiers => 'Pricing Tiers';

  @override
  String get noPendingAdvertisements => 'No pending advertisements found';

  @override
  String get vendor => 'Vendor';

  @override
  String get approve => 'Approve';

  @override
  String get approveAdvertisement => 'Approve Advertisement';

  @override
  String get rejectAdvertisement => 'Reject Advertisement';

  @override
  String get approveConfirmation =>
      'Are you sure you want to approve this advertisement?';

  @override
  String get rejectionReasonPrompt => 'Please provide a reason for rejection:';

  @override
  String get rejectionReason => 'Rejection Reason';

  @override
  String get rejectionReasonHint => 'Enter reason for rejection';

  @override
  String get pricingTiersManagement => 'Pricing Tiers Management';

  @override
  String get configurePricingTiers => 'Configure advertisement pricing tiers';

  @override
  String get loadPricingTiers => 'Load Pricing Tiers';

  @override
  String get advertisementAnalytics => 'Advertisement Analytics';

  @override
  String get performanceMetrics => 'View performance metrics and insights';

  @override
  String get loadAnalytics => 'Load Analytics';

  @override
  String get createPricingTier => 'Create Pricing Tier';

  @override
  String get noPricingTiers => 'No pricing tiers configured';

  @override
  String get createFirstPricingTier =>
      'Create your first pricing tier to get started';

  @override
  String get basePrice => 'Base Price';

  @override
  String get duration => 'Duration';

  @override
  String get multiplier => 'Multiplier';

  @override
  String get createPricingTierTitle => 'Create New Pricing Tier';

  @override
  String get updatePricingTierTitle => 'Update Pricing Tier';

  @override
  String get advertisementType => 'Advertisement Type';

  @override
  String get selectAdvertisementType => 'Select Advertisement Type';

  @override
  String get selectPosition => 'Select Position';

  @override
  String get basePriceHint => 'Enter base price';

  @override
  String get durationType => 'Duration Type';

  @override
  String get selectDurationType => 'Select Duration Type';

  @override
  String get multiplierHint => 'Enter multiplier (default: 1.0)';

  @override
  String get deletePricingTierTitle => 'Delete Pricing Tier';

  @override
  String get deletePricingTierConfirmation =>
      'Are you sure you want to delete this pricing tier? This action cannot be undone.';

  @override
  String get createAdvertisement => 'Create Advertisement';

  @override
  String get createNewAdvertisement => 'Create New Advertisement';

  @override
  String get advertisementTitle => 'Advertisement Title';

  @override
  String get enterAdvertisementTitle => 'Enter advertisement title';

  @override
  String get advertisementDescription => 'Advertisement Description';

  @override
  String get enterAdvertisementDescription => 'Enter advertisement description';

  @override
  String get advertisementImageUrl => 'Advertisement Image URL';

  @override
  String get enterAdvertisementImageUrl => 'Enter advertisement image URL';

  @override
  String get targetUrl => 'Target URL';

  @override
  String get enterTargetUrl => 'Enter target URL';

  @override
  String get adStartDate => 'Start Date';

  @override
  String get adEndDate => 'End Date';

  @override
  String get selectAdStartDate => 'Select start date';

  @override
  String get selectAdEndDate => 'Select end date';

  @override
  String get totalCost => 'Total Cost';

  @override
  String get createAdvertisementButton => 'Create Advertisement';

  @override
  String get advertisementDetails => 'Advertisement Details';

  @override
  String get placementConfiguration => 'Placement Configuration';

  @override
  String get campaignDuration => 'Campaign Duration';

  @override
  String get costCalculation => 'Cost Calculation';

  @override
  String get advertisementTitleRequired => 'Advertisement title is required';

  @override
  String get advertisementDescriptionRequired =>
      'Advertisement description is required';

  @override
  String get imageUrlRequired => 'Image URL is required';

  @override
  String get validImageUrlRequired => 'Please enter a valid image URL';

  @override
  String get targetUrlRequired => 'Target URL is required';

  @override
  String get validTargetUrlRequired => 'Please enter a valid target URL';

  @override
  String get adStartDateRequired => 'Start date is required';

  @override
  String get adEndDateRequired => 'End date is required';

  @override
  String get endDateMustBeAfterStartDate => 'End date must be after start date';

  @override
  String get calculatedCost => 'Calculated Cost';

  @override
  String get previewAdvertisement => 'Preview Advertisement';

  @override
  String get advertisementPreview => 'Advertisement Preview';

  @override
  String get adType => 'Advertisement Type';

  @override
  String get position => 'Position';

  @override
  String get save => 'Save';

  @override
  String get no => 'No';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get noOrders => 'No Orders';

  @override
  String get noOrdersSubtitle =>
      'Orders will appear here when customers place them';

  @override
  String get noOrdersFound => 'No Orders Found';

  @override
  String get noPickupOrdersFound => 'No pickup orders found';

  @override
  String get noPickupOrdersFoundForSearch =>
      'No pickup orders found for your search';

  @override
  String get noPickupOrdersFoundForFilter =>
      'No pickup orders found for this filter';

  @override
  String get pickupOrdersWillAppearHere => 'Pickup orders will appear here';

  @override
  String get rejectOrder => 'Reject Order';

  @override
  String get estimatedReady => 'Estimated Ready';

  @override
  String get itemsText => 'items';

  @override
  String get close => 'Close';

  @override
  String get rejectOrderConfirmation =>
      'Are you sure you want to reject this order?';

  @override
  String get orderID => 'Order ID';

  @override
  String get customer => 'Customer';

  @override
  String get items => 'Items';

  @override
  String get total => 'Total';

  @override
  String get status => 'Status';

  @override
  String get time => 'Time';

  @override
  String get actions => 'Actions';

  @override
  String get view => 'View';

  @override
  String get viewDetails => 'View Details';

  @override
  String get unauthorized => 'Unauthorized';

  @override
  String get unauthorizedMessage =>
      'You don\'t have permission to access this page.\\nPlease contact your administrator if you need access.';

  @override
  String get goBack => 'Go Back';

  @override
  String get searchFoodItems => 'Search food items...';

  @override
  String get mainCourse => 'Main Course';

  @override
  String get appetizers => 'Appetizers';

  @override
  String get desserts => 'Desserts';

  @override
  String get beverages => 'Beverages';

  @override
  String get workingHoursTitle => 'Working Hours';

  @override
  String get workingHoursSubtitle =>
      'Manage your restaurant\'s operating hours';

  @override
  String get openingTime => 'Opening Time';

  @override
  String get closingTime => 'Closing Time';

  @override
  String get selectOpeningTime => 'Select opening time';

  @override
  String get selectClosingTime => 'Select closing time';

  @override
  String get updateWorkingHours => 'Update Working Hours';

  @override
  String get workingHoursUpdated => 'Working hours updated successfully!';

  @override
  String get invalidTimeRange => 'Closing time must be after opening time';

  @override
  String get currentWorkingHours => 'Current Working Hours';

  @override
  String get restaurantProfileSubtitle =>
      'Manage your restaurant information and settings';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get cancelEdit => 'Cancel';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get restaurantInformation => 'Restaurant Information';

  @override
  String get basicRestaurantInfo => 'Basic information about your restaurant';

  @override
  String get restaurantName => 'Restaurant Name';

  @override
  String get enterRestaurantName => 'Enter restaurant name';

  @override
  String get restaurantDescription => 'Description';

  @override
  String get pleaseEnterRestaurantName => 'Please enter restaurant name';

  @override
  String get pleaseEnterDescription => 'Please enter restaurant description';

  @override
  String get notSet => 'Not set';

  @override
  String get noDescriptionAvailable => 'No description available';

  @override
  String get locationInformation => 'Location Information';

  @override
  String get restaurantLocationZone => 'Restaurant location and zone details';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get enterLatitude => 'Enter latitude';

  @override
  String get enterLongitude => 'Enter longitude';

  @override
  String get pleaseEnterLatitude => 'Please enter latitude';

  @override
  String get pleaseEnterLongitude => 'Please enter longitude';

  @override
  String get invalidLatitude => 'Invalid latitude';

  @override
  String get invalidLongitude => 'Invalid longitude';

  @override
  String get zone => 'Zone';

  @override
  String get selectZone => 'Select zone';

  @override
  String get pleaseSelectZone => 'Please select a zone';

  @override
  String get coordinates => 'Coordinates';

  @override
  String get notSelected => 'Not selected';

  @override
  String get unknownZone => 'Unknown zone';

  @override
  String get viewOnMap => 'View on Map';

  @override
  String get clickToViewLocation => 'Click to view restaurant location on map';

  @override
  String get mapIntegrationComingSoon => 'Map integration coming soon!';

  @override
  String get operatingHours => 'Operating Hours';

  @override
  String get restaurantWorkingHours => 'Restaurant working hours';

  @override
  String get opensAt => 'Opens';

  @override
  String get closesAt => 'Closes';

  @override
  String get currentlyOpen => 'Currently Open';

  @override
  String get currentlyClosed => 'Currently Closed';

  @override
  String get pleaseSelectOpeningTime => 'Please select opening time';

  @override
  String get pleaseSelectClosingTime => 'Please select closing time';

  @override
  String get restaurantStatus => 'Restaurant Status';

  @override
  String get statusAccountInfo => 'Status and account information';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get restaurantInactiveWarning =>
      'Restaurant is currently inactive. Customers cannot place orders.';

  @override
  String get customerRating => 'Customer Rating';

  @override
  String get excellent => 'Excellent';

  @override
  String get veryGood => 'Very Good';

  @override
  String get good => 'Good';

  @override
  String get fair => 'Fair';

  @override
  String get poor => 'Poor';

  @override
  String get created => 'Created';

  @override
  String get lastUpdated => 'Last Updated';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String daysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get unknown => 'Unknown';

  @override
  String get downtown => 'Downtown';

  @override
  String get mallArea => 'Mall Area';

  @override
  String get businessDistrict => 'Business District';

  @override
  String get residentialArea => 'Residential Area';

  @override
  String get profileUpdatedSuccessfully =>
      'Restaurant profile updated successfully!';

  @override
  String errorUpdatingProfile(String error) {
    return 'Error updating profile: $error';
  }

  @override
  String get errorLoadingProfile => 'Error loading restaurant profile';

  @override
  String get pageNotFound => 'Page Not Found';

  @override
  String get pageNotFoundDescription =>
      'The page you are looking for doesn\'t exist or has been moved.';

  @override
  String get goToDashboard => 'Go to Dashboard';

  @override
  String get retry => 'Retry';

  @override
  String get ordersChartPlaceholder => 'Orders chart will be displayed here';

  @override
  String get revenueChartPlaceholder => 'Revenue chart will be displayed here';

  @override
  String get accessDenied => 'Access Denied';

  @override
  String get all => 'All';

  @override
  String get newCategory => 'New';

  @override
  String get preparing => 'Preparing';

  @override
  String get ready => 'Ready';

  @override
  String get pending => 'Pending';

  @override
  String get completed => 'Completed';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get filterByStatus => 'Filter by Status';

  @override
  String get orderDetails => 'Order Details';

  @override
  String get orderStatusUpdated => 'Order status updated successfully';

  @override
  String get orderNotFound => 'Order not found';

  @override
  String get orderNumber => 'Order Number';

  @override
  String get estimatedDelivery => 'Estimated Delivery';

  @override
  String get customerInfo => 'Customer Information';

  @override
  String get customerName => 'Customer Name';

  @override
  String get phone => 'Phone';

  @override
  String get email => 'Email';

  @override
  String get deliveryAddress => 'Delivery Address';

  @override
  String get orderItems => 'Order Items';

  @override
  String get quantity => 'Quantity';

  @override
  String get notes => 'Notes';

  @override
  String get currency => 'EGP';

  @override
  String get orderSummary => 'Order Summary';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get deliveryFee => 'Delivery Fee';

  @override
  String get tax => 'Tax';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get paymentStatus => 'Payment Status';

  @override
  String get acceptOrder => 'Accept Order';

  @override
  String get cancelOrder => 'Cancel Order';

  @override
  String get markAsCompleted => 'Mark as Completed';

  @override
  String get customerInformation => 'Customer Information';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get customerId => 'Customer ID';

  @override
  String get address => 'Address';

  @override
  String get addressLine1 => 'Address Line 1';

  @override
  String get addressLine2 => 'Address Line 2';

  @override
  String get city => 'City';

  @override
  String get specialInstructions => 'Special Instructions';

  @override
  String get restaurantPickups => 'Restaurant Pickups';

  @override
  String get restaurantId => 'Restaurant ID';

  @override
  String get estimatedTime => 'Estimated Time';

  @override
  String get pickedUpAt => 'Picked Up At';

  @override
  String get actualTime => 'Actual Time';

  @override
  String get preparationTime => 'Preparation Time';

  @override
  String get specialNotes => 'Special Notes';

  @override
  String get customizations => 'Customizations';

  @override
  String get am => 'AM';

  @override
  String get pm => 'PM';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'items',
      one: 'item',
    );
    return '$count $_temp0';
  }

  @override
  String minutesAgo(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'minutes',
      one: 'minute',
    );
    return '$minutes $_temp0 ago';
  }

  @override
  String hoursAgo(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'hours',
      one: 'hour',
    );
    return '$hours $_temp0 ago';
  }

  @override
  String get startPreparing => 'Start Preparing';

  @override
  String get markAsPickedUp => 'Mark as Picked Up';

  @override
  String get accept => 'Accept';

  @override
  String get reject => 'Reject';

  @override
  String get markReadyForPickup => 'Mark Ready for Pickup';

  @override
  String get readyForPickup => 'Ready for Pickup';

  @override
  String get searchOrdersPlaceholder => 'Search orders...';

  @override
  String get search => 'Search';

  @override
  String get refresh => 'Refresh';

  @override
  String get error => 'Error';

  @override
  String get available => 'Available';

  @override
  String get unavailable => 'Unavailable';

  @override
  String get busy => 'Busy';

  @override
  String get showing => 'Showing';

  @override
  String get totalItems => 'Total Items';

  @override
  String get required => 'Required';

  @override
  String get addFood => 'Add Food';

  @override
  String get updateFood => 'Update Food';

  @override
  String get addNewFoodItem => 'Add New Food Item';

  @override
  String get editFoodItem => 'Edit Food Item';

  @override
  String get foodDetails => 'Food Details';

  @override
  String get foodName => 'Food Name';

  @override
  String get enterFoodName => 'Enter food name';

  @override
  String get pleaseEnterFoodName => 'Please enter food name';

  @override
  String get nameMinLength => 'Name must be at least 2 characters';

  @override
  String get nameMaxLength => 'Name cannot exceed 50 characters';

  @override
  String get description => 'Description';

  @override
  String get enterFoodDescription => 'Enter food description';

  @override
  String get pleaseEnterFoodDescription => 'Please enter food description';

  @override
  String get descriptionMinLength =>
      'Description must be at least 10 characters';

  @override
  String get descriptionMaxLength => 'Description cannot exceed 500 characters';

  @override
  String get price => 'Price';

  @override
  String get enterPrice => 'Enter price';

  @override
  String get pleaseEnterPrice => 'Please enter price';

  @override
  String get pleaseEnterValidPrice => 'Please enter a valid price';

  @override
  String get priceMinValue => 'Price must be greater than 0';

  @override
  String get category => 'Category';

  @override
  String get selectCategory => 'Select Category';

  @override
  String get pleaseSelectCategory => 'Please select a category';

  @override
  String get imageUrl => 'Image URL';

  @override
  String get enterImageUrl => 'Enter image URL';

  @override
  String get pleaseEnterImageUrl => 'Please enter image URL';

  @override
  String get invalidImageUrl => 'Please enter a valid image URL';

  @override
  String get foodRequirements => 'Food Requirements';

  @override
  String get addRequirement => 'Add Requirement';

  @override
  String get requirement => 'Requirement';

  @override
  String get requirementName => 'Requirement Name';

  @override
  String get requirementNameHint => 'e.g., Size, Spice Level';

  @override
  String get pleaseEnterRequirementName => 'Please enter requirement name';

  @override
  String get requirementNameMinLength =>
      'Requirement name must be at least 2 characters';

  @override
  String get requirementNameMaxLength =>
      'Requirement name cannot exceed 30 characters';

  @override
  String get requirementType => 'Requirement Type';

  @override
  String get singleChoice => 'Single Choice';

  @override
  String get multiChoice => 'Multi Choice';

  @override
  String get requiredRequirementInfo =>
      'Required: Customer must select an option';

  @override
  String get multiChoiceInfo =>
      'Multi-choice: Customer can select multiple options';

  @override
  String get options => 'Options';

  @override
  String get optionName => 'Option Name';

  @override
  String get optionNameHint => 'e.g., Small, Medium, Large';

  @override
  String get pleaseEnterOptionName => 'Please enter option name';

  @override
  String get optionNameMinLength => 'Option name must be at least 1 character';

  @override
  String get optionNameMaxLength => 'Option name cannot exceed 20 characters';

  @override
  String get additionalPrice => 'Additional Price';

  @override
  String get additionalPriceMinValue => 'Additional price cannot be negative';

  @override
  String get addOption => 'Add Option';

  @override
  String get minimumOneRequirement => 'At least one requirement is needed';

  @override
  String get minimumTwoOptions => 'At least two options are required';

  @override
  String get atLeastOneRequiredSingleChoice =>
      'At least one single-choice requirement must be required';

  @override
  String get multiChoiceCannotBeRequired =>
      'Multi-choice requirements cannot be required';

  @override
  String get noRequirementsAdded => 'No requirements added yet';

  @override
  String get foodItemAddedSuccessfully => 'Food item added successfully';

  @override
  String get foodItemUpdatedSuccessfully => 'Food item updated successfully';

  @override
  String get toggleAvailability => 'Toggle Availability';

  @override
  String get errorTogglingAvailability => 'Error toggling availability';

  @override
  String get restaurantAvailability => 'Restaurant Availability';

  @override
  String get availabilityStatus => 'Availability Status';

  @override
  String get availabilityToggleDescription =>
      'Toggle between available and busy status';

  @override
  String get currentStatus => 'Current Status';

  @override
  String get statusDescription => 'Status Description';

  @override
  String get availabilityInfoAvailable => 'Restaurant is accepting orders';

  @override
  String get availabilityInfoBusy => 'Restaurant is temporarily busy';

  @override
  String get restaurantIsAvailable => 'Restaurant is available';

  @override
  String get restaurantIsBusy => 'Restaurant is busy';

  @override
  String get setToAvailable => 'Set to Available';

  @override
  String get setToBusy => 'Set to Busy';

  @override
  String get availabilityUpdated => 'Availability updated successfully';

  @override
  String get restaurantPickup => 'Restaurant Pickup';

  @override
  String get addNewItem => 'Add New Item';

  @override
  String get enterRestaurantDescription => 'Enter restaurant description';

  @override
  String get manageOrdersForPickupAndDelivery =>
      'Manage orders for pickup and delivery';

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get adminDashboardSubtitle =>
      'Comprehensive platform management and analytics';

  @override
  String get platformOverview => 'Platform Overview';

  @override
  String get keyMetrics => 'Key Metrics';

  @override
  String get realtimeUpdates => 'Real-time Updates';

  @override
  String get managementSections => 'Management Sections';

  @override
  String get restaurantManagement => 'Restaurant Management';

  @override
  String get searchRestaurantsToSeeResults =>
      'Search for restaurants to see results';

  @override
  String get ofText => 'of';

  @override
  String get restaurants => 'restaurants';

  @override
  String get page => 'Page';

  @override
  String get systemReports => 'System Reports';

  @override
  String get totalOrders => 'Total Orders';

  @override
  String get totalRevenue => 'Total Revenue';

  @override
  String get averageOrderValue => 'Average Order Value';

  @override
  String get userManagement => 'User Management';

  @override
  String get loadingUsers => 'Loading users...';

  @override
  String get errorLoadingUsers => 'Error loading users';

  @override
  String get noUsersFound => 'No users found';

  @override
  String get searchUsers => 'Search users';

  @override
  String get userType => 'User Type';

  @override
  String get allUserTypes => 'All User Types';

  @override
  String get customers => 'Customers';

  @override
  String get deliveryPersonnel => 'Delivery Personnel';

  @override
  String get deliveryPersonnelManagement => 'Delivery Personnel Management';

  @override
  String get manageDeliveryMenTrackPerformanceAssignZones =>
      'Manage delivery men, track performance, and assign zones';

  @override
  String get addDeliveryMan => 'Add Delivery Man';

  @override
  String get searchByNameEmailOrPhone => 'Search by name, email, or phone...';

  @override
  String deliveryMenSelected(int count) {
    return '$count delivery men selected';
  }

  @override
  String get clearSelection => 'Clear Selection';

  @override
  String get deliveryManCreatedSuccessfully =>
      'Delivery man created successfully';

  @override
  String get deliveryManUpdatedSuccessfully =>
      'Delivery man updated successfully';

  @override
  String get deliveryManDeletedSuccessfully =>
      'Delivery man deleted successfully';

  @override
  String get loadingDeliveryPersonnel => 'Loading delivery personnel...';

  @override
  String get errorLoadingDeliveryPersonnel =>
      'Error Loading Delivery Personnel';

  @override
  String get noDeliveryPersonnelFound => 'No delivery personnel found';

  @override
  String get addDeliveryPersonnelToStartManagingDeliveries =>
      'Add delivery personnel to start managing deliveries';

  @override
  String get deleteDeliveryMan => 'Delete Delivery Man';

  @override
  String get areYouSureDeleteDeliveryMan =>
      'Are you sure you want to delete this delivery man? This action cannot be undone.';

  @override
  String get analyticsFeatureComingSoon => 'Analytics feature coming soon';

  @override
  String get zoneAssignmentFeatureComingSoon =>
      'Zone assignment feature coming soon';

  @override
  String get activateSelectedDeliveryMen => 'Activate Selected Delivery Men';

  @override
  String get deactivateSelectedDeliveryMen =>
      'Deactivate Selected Delivery Men';

  @override
  String areYouSureBulkActivate(int count) {
    return 'Are you sure you want to activate $count delivery men?';
  }

  @override
  String areYouSureBulkDeactivate(int count) {
    return 'Are you sure you want to deactivate $count delivery men?';
  }

  @override
  String get editDeliveryMan => 'Edit Delivery Man';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get fullName => 'Full Name';

  @override
  String get nameIsRequired => 'Name is required';

  @override
  String get emailIsRequired => 'Email is required';

  @override
  String get enterValidEmail => 'Enter a valid email';

  @override
  String get phoneNumberIsRequired => 'Phone number is required';

  @override
  String get vehicleInformation => 'Vehicle Information';

  @override
  String get vehicleType => 'Vehicle Type';

  @override
  String get pleaseSelectVehicleType => 'Please select a vehicle type';

  @override
  String get licenseIdNumber => 'License/ID Number';

  @override
  String get motorcycle => 'Motorcycle';

  @override
  String get bicycle => 'Bicycle';

  @override
  String get car => 'Car';

  @override
  String get scooter => 'Scooter';

  @override
  String get licenseNumberIsRequired => 'License number is required';

  @override
  String get zoneAssignment => 'Zone Assignment';

  @override
  String get accountSecurity => 'Account Security';

  @override
  String get passwordIsRequired => 'Password is required';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get pleaseConfirmPassword => 'Please confirm password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get updateDeliveryMan => 'Update Delivery Man';

  @override
  String get allStatuses => 'All Statuses';

  @override
  String get suspended => 'Suspended';

  @override
  String get name => 'Name';

  @override
  String get joinedDate => 'Joined Date';

  @override
  String get activate => 'Activate';

  @override
  String get deactivate => 'Deactivate';

  @override
  String showingResults(int current, int total) {
    return 'Showing $current of $total results';
  }

  @override
  String pageOfPages(int current, int total) {
    return 'Page $current of $total';
  }

  @override
  String get assignedZoneOptional => 'Assigned Zone (Optional)';

  @override
  String get noZoneAssigned => 'No zone assigned';

  @override
  String get restaurantsByZones => 'Restaurants by Zones';

  @override
  String get zoneManagement => 'Zone Management';

  @override
  String get allZones => 'All Zones';

  @override
  String get activeRestaurants => 'Active Restaurants';

  @override
  String get inactiveRestaurants => 'Inactive Restaurants';

  @override
  String get totalZones => 'Total Zones';

  @override
  String get totalRestaurants => 'Total Restaurants';

  @override
  String get averageRating => 'Average Rating';

  @override
  String get totalMenuItems => 'Total Menu Items';

  @override
  String get baseDeliveryFee => 'Base Delivery Fee';

  @override
  String get restaurantOperatingHours => 'Operating Hours';

  @override
  String get verified => 'Verified';

  @override
  String get notVerified => 'Not Verified';

  @override
  String get zoneCode => 'Zone Code';

  @override
  String get zoneType => 'Zone Type';

  @override
  String get averageRestaurantsPerZone => 'Average Restaurants per Zone';

  @override
  String get includeStatistics => 'Include Statistics';

  @override
  String get zoneBreakdown => 'Zone Breakdown';

  @override
  String get overallStatistics => 'Overall Statistics';

  @override
  String get loadingRestaurants => 'Loading restaurants...';

  @override
  String get noRestaurantsFound => 'No restaurants found';

  @override
  String get errorLoadingRestaurants => 'Error loading restaurants';

  @override
  String get refreshRestaurants => 'Refresh Restaurants';

  @override
  String get loadMore => 'Load More';

  @override
  String get filterByZone => 'Filter by Zone';

  @override
  String get filterRestaurantsByStatus => 'Filter by Status';

  @override
  String get viewRestaurantDetails => 'View Restaurant Details';

  @override
  String get restaurantActions => 'Restaurant Actions';

  @override
  String get manageRestaurants => 'Manage Restaurants';

  @override
  String get adminManageRestaurants => 'Manage Restaurants';

  @override
  String get addRestaurant => 'Add Restaurant';

  @override
  String get welcomeToRestaurantManagement =>
      'Welcome to restaurant management';

  @override
  String get filters => 'Filters';

  @override
  String get adminOrders => 'Orders Management';

  @override
  String get adminSearchOrders => 'Search orders...';

  @override
  String get adminAllOrders => 'All Orders';

  @override
  String get adminPendingOrders => 'Pending';

  @override
  String get adminConfirmedOrders => 'Confirmed';

  @override
  String get adminPreparingOrders => 'Preparing';

  @override
  String get adminReadyOrders => 'Ready';

  @override
  String get adminCompletedOrders => 'Completed';

  @override
  String get adminCancelledOrders => 'Cancelled';

  @override
  String get adminOrderNumber => 'Order #';

  @override
  String get adminCustomerName => 'Customer';

  @override
  String get adminRestaurantName => 'Restaurant';

  @override
  String get adminOrderStatus => 'Status';

  @override
  String get adminOrderTotal => 'Total';

  @override
  String get adminOrderDate => 'Date';

  @override
  String get adminOrderActions => 'Actions';

  @override
  String get adminViewDetails => 'View Details';

  @override
  String get adminNoOrdersFound => 'No orders found';

  @override
  String get adminLoadingOrders => 'Loading orders...';

  @override
  String get adminErrorLoadingOrders => 'Error loading orders';

  @override
  String get adminExportOrders => 'Export Orders';

  @override
  String get adminTotalOrders => 'Total Orders';

  @override
  String get adminTotalRevenue => 'Total Revenue';

  @override
  String get adminNoOrdersMatchFilters =>
      'No orders match your current filters';

  @override
  String get adminOrderDetails => 'Order Details';

  @override
  String get adminCreatedAt => 'Created At';

  @override
  String get adminEstimatedDelivery => 'Estimated Delivery';

  @override
  String get adminActualDelivery => 'Actual Delivery';

  @override
  String get adminCustomerInfo => 'Customer Information';

  @override
  String get adminPhoneNumber => 'Phone Number';

  @override
  String get adminRestaurantInfo => 'Restaurant Information';

  @override
  String get adminDeliveryAddress => 'Delivery Address';

  @override
  String get adminOrderItems => 'Order Items';

  @override
  String get adminPaymentInfo => 'Payment Information';

  @override
  String get adminSubtotal => 'Subtotal';

  @override
  String get adminDeliveryFee => 'Delivery Fee';

  @override
  String get adminTax => 'Tax';

  @override
  String get adminTotalAmount => 'Total Amount';

  @override
  String get adminPaymentMethod => 'Payment Method';

  @override
  String get adminPaymentStatus => 'Payment Status';

  @override
  String get adminOrderNotes => 'Order Notes';

  @override
  String get adminOnTheWayOrders => 'On The Way';

  @override
  String get adminRefreshOrders => 'Refresh Orders';

  @override
  String get adminQuantity => 'Quantity';

  @override
  String get adminUnitPrice => 'Unit Price';

  @override
  String get adminSpecialNotes => 'Special Notes';

  @override
  String get adminGroupNumber => 'Group Number';

  @override
  String get adminOrdersCount => 'Orders Count';

  @override
  String get adminRestaurantsCount => 'Restaurants';

  @override
  String get adminFinalAmount => 'Final Amount';

  @override
  String get adminCrossZone => 'Cross Zone';

  @override
  String get adminSameZone => 'Same Zone';

  @override
  String get adminIndividualOrdersInGroup => 'Individual Orders in this Group:';

  @override
  String get adminTotalOrdersIndividual => 'Total Orders';

  @override
  String get adminAvgGroupValue => 'Avg Group Value';

  @override
  String get adminAvgOrdersPerGroup => 'Avg Orders/Group';

  @override
  String get adminOrdersPlural => 'orders';

  @override
  String get adminRestaurantsPlural => 'restaurants';

  @override
  String get adminCustomerLabel => 'Customer:';

  @override
  String get adminRestaurantLabel => 'Restaurant:';

  @override
  String get adminTotalLabel => 'Total:';

  @override
  String get adminDateLabel => 'Date:';

  @override
  String get adminRefundOrderGroupOnly => 'Refund Order Group Only';

  @override
  String get adminRefundAndDeactivate =>
      'Refund Order Group & Deactivate Customer';

  @override
  String get adminRefundOnly => 'Refund Only';

  @override
  String get adminRefundAndDeactivateShort => 'Refund & Deactivate';

  @override
  String get adminProcessingRefund =>
      'Processing refund and deactivating customer account...';

  @override
  String get adminProcessingRefundOnly =>
      'Processing refund only (customer account stays active)...';

  @override
  String get zoneManagementTitle => 'Zone Management';

  @override
  String get zoneManagementSubtitle => 'Manage delivery zones and boundaries';

  @override
  String get addZone => 'Add Zone';

  @override
  String get editZone => 'Edit Zone';

  @override
  String get deleteZone => 'Delete Zone';

  @override
  String get zoneName => 'Zone Name';

  @override
  String get zoneLevel => 'Zone Level';

  @override
  String get parentZone => 'Parent Zone';

  @override
  String get distanceFromCenter => 'Distance from Center';

  @override
  String get zoneActive => 'Zone Active';

  @override
  String get zoneBoundaries => 'Zone Boundaries';

  @override
  String get noZonesFound => 'No zones found';

  @override
  String get loadingZones => 'Loading zones...';

  @override
  String get zoneDetails => 'Zone Details';

  @override
  String get zoneCreated => 'Zone created successfully';

  @override
  String get zoneUpdated => 'Zone updated successfully';

  @override
  String get zoneDeleted => 'Zone deleted successfully';

  @override
  String get confirmDeleteZone => 'Are you sure you want to delete this zone?';

  @override
  String get cannotDeleteZone => 'Cannot delete zone';

  @override
  String get zoneHasRelatedData =>
      'This zone has related data and cannot be deleted';

  @override
  String get relatedRestaurants => 'Related Restaurants';

  @override
  String get relatedData => 'Related Data';

  @override
  String get relatedCustomerAddresses => 'Related Customer Addresses';

  @override
  String get relatedMarts => 'Related Marts';

  @override
  String get relatedSubZones => 'Related Sub-zones';

  @override
  String get totalRelatedRecords => 'Total Related Records';

  @override
  String get filterByZoneType => 'Filter by Zone Type';

  @override
  String get filterByZoneLevel => 'Filter by Zone Level';

  @override
  String get allZoneTypes => 'All Zone Types';

  @override
  String get allZoneLevels => 'All Zone Levels';

  @override
  String get government => 'Government';

  @override
  String get district => 'District';

  @override
  String get neighborhood => 'Neighborhood';

  @override
  String get area => 'Area';

  @override
  String get level1 => 'Level 1';

  @override
  String get level2 => 'Level 2';

  @override
  String get level3 => 'Level 3';

  @override
  String get level4 => 'Level 4';

  @override
  String get level5 => 'Level 5';

  @override
  String get selectParentZone => 'Select Parent Zone';

  @override
  String get noParentZone => 'No Parent Zone';

  @override
  String get zoneHierarchy => 'Zone Hierarchy';

  @override
  String get viewZoneHierarchy => 'View Zone Hierarchy';

  @override
  String get zoneCreatedAt => 'Created At';

  @override
  String get zoneUpdatedAt => 'Updated At';

  @override
  String get pleaseEnterZoneName => 'Please enter zone name';

  @override
  String get pleaseEnterZoneCode => 'Please enter zone code';

  @override
  String get pleaseSelectZoneType => 'Please select zone type';

  @override
  String get pleaseSelectZoneLevel => 'Please select zone level';

  @override
  String get pleaseEnterDeliveryFee => 'Please enter delivery fee';

  @override
  String get pleaseEnterValidDeliveryFee => 'Please enter valid delivery fee';

  @override
  String get pleaseEnterDistance => 'Please enter distance';

  @override
  String get pleaseEnterValidDistance => 'Please enter valid distance';

  @override
  String get zoneCodeAlreadyExists => 'Zone code already exists';

  @override
  String get errorCreatingZone => 'Error creating zone';

  @override
  String get errorUpdatingZone => 'Error updating zone';

  @override
  String get errorDeletingZone => 'Error deleting zone';

  @override
  String get errorLoadingZones => 'Error loading zones';

  @override
  String get errorLoadingZoneDetails => 'Error loading zone details';

  @override
  String get retryLoadingZones => 'Retry Loading Zones';

  @override
  String get zoneManagementHelp =>
      'Manage delivery zones to organize your service areas';

  @override
  String get exportZones => 'Export Zones';

  @override
  String get importZones => 'Import Zones';

  @override
  String get zoneExportSuccess => 'Zones exported successfully';

  @override
  String get zoneImportSuccess => 'Zones imported successfully';

  @override
  String get invalidZoneFile => 'Invalid zone file';

  @override
  String get errorExportingZones => 'Error exporting zones';

  @override
  String get errorImportingZones => 'Error importing zones';

  @override
  String get currentZone => 'Current Zone';

  @override
  String get subZones => 'Sub Zones';

  @override
  String get noSubZones => 'This zone has no sub-zones';

  @override
  String get level => 'Level';

  @override
  String get km => 'km';

  @override
  String get update => 'Update';

  @override
  String get create => 'Create';

  @override
  String get customerAddresses => 'Customer Addresses';

  @override
  String get marts => 'Marts';

  @override
  String get martAdminDashboard => 'Mart Dashboard';

  @override
  String get martPos => 'Point of Sale';

  @override
  String get martProducts => 'Products';

  @override
  String get martAddProduct => 'Add Product';

  @override
  String get martInventory => 'Inventory Management';

  @override
  String get martOrders => 'Orders';

  @override
  String get martReports => 'Reports';

  @override
  String get martProfile => 'Profile';

  @override
  String get cannotDeleteZoneWithDependencies =>
      'This zone cannot be deleted because it has related data or sub-zones';

  @override
  String get zoneDeliveryRules => 'Zone Delivery Rules';

  @override
  String get manageZoneDeliveryRules => 'Manage delivery rules between zones';

  @override
  String get addDeliveryRule => 'Add Delivery Rule';

  @override
  String get editDeliveryRule => 'Edit Delivery Rule';

  @override
  String get deleteDeliveryRule => 'Delete Delivery Rule';

  @override
  String get confirmDeleteDeliveryRule =>
      'Are you sure you want to delete this delivery rule?';

  @override
  String get deliveryRuleCreated => 'Delivery rule created successfully';

  @override
  String get deliveryRuleUpdated => 'Delivery rule updated successfully';

  @override
  String get deliveryRuleDeleted => 'Delivery rule deleted successfully';

  @override
  String get errorLoadingDeliveryRules => 'Error loading delivery rules';

  @override
  String get retryLoadingDeliveryRules => 'Retry Loading Rules';

  @override
  String get noDeliveryRulesFound => 'No delivery rules found';

  @override
  String get deliveryRulesHelp =>
      'Create delivery rules to manage cross-zone deliveries';

  @override
  String get fromZone => 'From Zone';

  @override
  String get toZone => 'To Zone';

  @override
  String get selectFromZone => 'Select from zone';

  @override
  String get selectToZone => 'Select to zone';

  @override
  String get canDeliver => 'Can Deliver';

  @override
  String get additionalFee => 'Additional Fee';

  @override
  String get minimumOrderAmount => 'Minimum Order Amount';

  @override
  String get estimatedTimeMinutes => 'Estimated Time (Minutes)';

  @override
  String get maxDistance => 'Max Distance (KM)';

  @override
  String get deliveryRuleDetails => 'Delivery Rule Details';

  @override
  String get pleaseSelectFromZone => 'Please select a from zone';

  @override
  String get pleaseSelectToZone => 'Please select a to zone';

  @override
  String get pleaseEnterValidAdditionalFee =>
      'Please enter a valid additional fee';

  @override
  String get pleaseEnterValidMinimumAmount =>
      'Please enter a valid minimum order amount';

  @override
  String get pleaseEnterValidEstimatedTime =>
      'Please enter a valid estimated time';

  @override
  String get pleaseEnterValidMaxDistance => 'Please enter a valid max distance';

  @override
  String get sameZoneSelected => 'From zone and to zone cannot be the same';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get deliveryAllowed => 'Delivery Allowed';

  @override
  String get deliveryNotAllowed => 'Delivery Not Allowed';

  @override
  String get minutes => 'minutes';

  @override
  String get minutesUnit => 'minutes';

  @override
  String get kilometers => 'KM';

  @override
  String get sar => 'SAR';

  @override
  String get optional => 'Optional';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get recentReports => 'Recent Reports';

  @override
  String get weeklyReport => 'Weekly Report';

  @override
  String get currentWeek => 'Current Week';

  @override
  String get previousWeek => 'Previous Week';

  @override
  String get profitMargin => 'Profit Margin';

  @override
  String get earnings => 'Earnings';

  @override
  String get totalEarnings => 'Total Earnings';

  @override
  String get netEarnings => 'Net Earnings';

  @override
  String get totalProducts => 'Total Products';

  @override
  String get totalStock => 'Total Stock';

  @override
  String get lowStockProducts => 'Low Stock Products';

  @override
  String get lowStock => 'Low Stock';

  @override
  String get inventorySummary => 'Inventory Summary';

  @override
  String get confirmed => 'Confirmed';

  @override
  String get disputed => 'Disputed';

  @override
  String get pendingConfirmation => 'Pending Confirmation';

  @override
  String get reportStatus => 'Report Status';

  @override
  String get confirmReport => 'Confirm Report';

  @override
  String get disputeReport => 'Dispute Report';

  @override
  String get reportDetails => 'Report Details';

  @override
  String get weekStart => 'Week Start';

  @override
  String get weekEnd => 'Week End';

  @override
  String get commission => 'Commission';

  @override
  String get commissionRate => 'Commission Rate';

  @override
  String get deliveryFees => 'Delivery Fees';

  @override
  String get crossZoneFees => 'Cross Zone Fees';

  @override
  String get orderValue => 'Order Value';

  @override
  String get totalOrdersValue => 'Total Orders Value';

  @override
  String get orderCount => 'Order Count';

  @override
  String get unionOrders => 'Union Orders';

  @override
  String get individualOrders => 'Individual Orders';

  @override
  String get topSellingItems => 'Top Selling Items';

  @override
  String get itemsSold => 'Items Sold';

  @override
  String get reportGenerated => 'Report Generated';

  @override
  String get reportConfirmed => 'Report Confirmed';

  @override
  String get reportDisputed => 'Report Disputed';

  @override
  String get unionOrder => 'Union Order';

  @override
  String get individualOrder => 'Individual Order';

  @override
  String get unionGroup => 'Union Group';

  @override
  String get reportInfo => 'Report Information';

  @override
  String get reportPeriod => 'Report Period';

  @override
  String get reportType => 'Report Type';

  @override
  String get financialSummary => 'Financial Summary';

  @override
  String get ordersSummary => 'Orders Summary';

  @override
  String get orderItemsDetails => 'Order Items Details';

  @override
  String get itemName => 'Item Name';

  @override
  String get unitPrice => 'Unit Price';

  @override
  String get orderDate => 'Order Date';

  @override
  String get deliveryDate => 'Delivery Date';

  @override
  String get confirmedBy => 'Confirmed By';

  @override
  String get confirmedAt => 'Confirmed At';

  @override
  String get generatedAt => 'Generated At';

  @override
  String get martReportsTitle => 'Mart Reports';

  @override
  String get refreshAllData => 'Refresh All Data';

  @override
  String get filterReports => 'Filter Reports';

  @override
  String get noDashboardData => 'No dashboard data';

  @override
  String get noAnalyticsData => 'No analytics data';

  @override
  String get noPerformanceData => 'No performance data';

  @override
  String get noReportsData => 'No reports data';

  @override
  String get dashboardSummary => 'Dashboard Summary';

  @override
  String get analyticsData => 'Analytics Data';

  @override
  String get productPerformance => 'Product Performance';

  @override
  String get reportsData => 'Reports Data';

  @override
  String get totalSales => 'Total Sales';

  @override
  String get totalProfit => 'Total Profit';

  @override
  String get pendingConfirmations => 'Pending Confirmations';

  @override
  String get avgOrderValue => 'Avg Order Value';

  @override
  String get revenueByPeriod => 'Revenue by Period';

  @override
  String get topProducts => 'Top Products';

  @override
  String get salesTrend => 'Sales Trend';

  @override
  String get productName => 'Product Name';

  @override
  String get unitsSold => 'Units Sold';

  @override
  String get profit => 'Profit';

  @override
  String get reportDate => 'Report Date';

  @override
  String get period => 'Period';

  @override
  String get amount => 'Amount';

  @override
  String get leEgp => 'LE';

  @override
  String get loading => 'Loading...';

  @override
  String get revised => 'Revised';

  @override
  String get rejected => 'Rejected';

  @override
  String get apply => 'Apply';

  @override
  String get analytics => 'Analytics';

  @override
  String get performance => 'Performance';

  @override
  String get reportInformation => 'Report Information';

  @override
  String get totalDeliveries => 'Total Deliveries';

  @override
  String get reportId => 'Report ID';

  @override
  String get yes => 'Yes';

  @override
  String get sold => 'Sold';

  @override
  String get rating => 'Rating';

  @override
  String get clearFilter => 'Clear Filter';

  @override
  String get allReports => 'All Reports';

  @override
  String get noReportsAvailable => 'No reports available';

  @override
  String get noProductPerformanceData =>
      'No product performance data available';

  @override
  String get productPerformanceTitle => 'Product Performance';

  @override
  String get reportsListTitle => 'Reports List';

  @override
  String get reportsSummary => 'Reports Summary';

  @override
  String get units => 'units';

  @override
  String get martInfo => 'Mart Information';

  @override
  String get martName => 'Mart Name';

  @override
  String get editableData => 'Editable Data';

  @override
  String get pleaseEnterName => 'Please enter your name';

  @override
  String get pleaseEnterPhoneNumber => 'Please enter your phone number';

  @override
  String get updateData => 'Update Data';

  @override
  String get updateYourPersonalInfo => 'Update your personal information';

  @override
  String get profile => 'Profile';

  @override
  String get enter => 'Enter';

  @override
  String get adminReports => 'Admin Reports';

  @override
  String get entityType => 'Entity Type';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get generateWeeklyReports => 'Generate Weekly Reports';

  @override
  String get automatedReportGeneration => 'Automated Report Generation';

  @override
  String get generateCurrentWeek => 'Generate Current Week';

  @override
  String get customDateRange => 'Custom Date Range';

  @override
  String get recentGenerationJobs => 'Recent Generation Jobs';

  @override
  String get reportTypeBreakdown => 'Report Type Breakdown';

  @override
  String get noRecentReportsAvailable => 'No recent reports available';

  @override
  String get resolve => 'Resolve';

  @override
  String get weeklyReportsGenerated => 'Weekly Reports Generated';

  @override
  String get allEntitiesProcessed => 'All entities processed';

  @override
  String get startedGeneratingReports =>
      'Started generating reports for current week...';

  @override
  String get generateReports => 'Generate Reports';

  @override
  String get topRestaurants => 'Top Restaurants';

  @override
  String get revenueBreakdown => 'Revenue Breakdown';

  @override
  String get ordersByStatus => 'Orders by Status';

  @override
  String get hourlyBreakdown => 'Hourly Breakdown';

  @override
  String get restaurantsSummary => 'Restaurants Summary';

  @override
  String get topPerformers => 'Top Performers';

  @override
  String get categoryPerformance => 'Category Performance';

  @override
  String get customersSummary => 'Customers Summary';

  @override
  String get topCustomers => 'Top Customers';

  @override
  String get newCustomers => 'New Customers';

  @override
  String get activeCustomers => 'Active Customers';

  @override
  String get totalCustomers => 'Total Customers';

  @override
  String reportsCount(int count) {
    return '$count reports';
  }

  @override
  String get generate => 'Generate';

  @override
  String get restaurant => 'Restaurant';

  @override
  String get mart => 'Mart';

  @override
  String get delivery => 'Delivery';

  @override
  String get noReportsFound => 'No reports found';

  @override
  String get noWeeklyReportsAvailable =>
      'No weekly reports available for the selected criteria';

  @override
  String get platformEarnings => 'Platform Earnings';

  @override
  String get businessEarnings => 'Business Earnings';

  @override
  String get pendingReports => 'Pending Reports';

  @override
  String get totalReports => 'Total Reports';

  @override
  String get confirmedReports => 'Confirmed Reports';

  @override
  String get disputedReports => 'Disputed Reports';

  @override
  String get runningJobs => 'Running Jobs';

  @override
  String get reportsAutomaticallyGenerated =>
      'Reports are automatically generated every Monday for the previous week. You can also manually trigger generation for specific date ranges.';

  @override
  String get errorLoadingDashboard => 'Error loading dashboard';

  @override
  String get week => 'Week';

  @override
  String get noRecentReports => 'No recent reports';

  @override
  String get reportsWillAppearHere => 'Reports will appear here once generated';

  @override
  String get weekOf => 'Week of';

  @override
  String get selectWeekStartDate =>
      'Select week start date for report generation:';

  @override
  String get selectDate => 'Select Date';

  @override
  String get pleaseSelectDateFirst => 'Please select a date first';

  @override
  String get profitAndLoss => 'Profit & Loss';

  @override
  String get profitAndLossSummary => 'Profit & Loss Summary';

  @override
  String get reportingPeriod => 'Reporting Period';

  @override
  String get discountGiven => 'Discount Given';

  @override
  String get costOfGoodsSold => 'Cost of Goods Sold';

  @override
  String get grossProfit => 'Gross Profit';

  @override
  String get inventoryPurchases => 'Inventory Purchases';

  @override
  String get purchaseValue => 'Purchase Value';

  @override
  String get netProfit => 'Net Profit';

  @override
  String get averageOrderMargin => 'Average Order Margin';

  @override
  String get invoiceCount => 'Invoice Count';

  @override
  String get deliveredItemCount => 'Delivered Item Count';

  @override
  String get salesBreakdown => 'Sales Breakdown';

  @override
  String get ordersChannel => 'Orders Channel';

  @override
  String get cashierChannel => 'Cashier Channel';

  @override
  String startedGeneratingReportsForWeek(String date) {
    return 'Started generating reports for week of $date...';
  }

  @override
  String get topPerformingRestaurants => 'Top Performing Restaurants';

  @override
  String get recentReportSubtitle => 'Dec 2-8, 2024 • All entities processed';

  @override
  String get revenueAnalytics => 'Revenue Analytics';

  @override
  String get orderAnalytics => 'Order Analytics';

  @override
  String get restaurantPerformance => 'Restaurant Performance';

  @override
  String get customerAnalytics => 'Customer Analytics';

  @override
  String get martManagement => 'Mart Management';

  @override
  String get martManagementSubtitle =>
      'Manage marts, staff, and operations across zones';

  @override
  String get addMart => 'Add Mart';

  @override
  String get editMart => 'Edit Mart';

  @override
  String get deleteMart => 'Delete Mart';

  @override
  String get searchMarts => 'Search marts...';

  @override
  String get filterMartsByZone => 'Filter by Zone';

  @override
  String get filterMartsByStatus => 'Filter by Status';

  @override
  String get activeMarts => 'Active Marts';

  @override
  String get inactiveMarts => 'Inactive Marts';

  @override
  String get allMartStatuses => 'All Statuses';

  @override
  String get noMartsFound => 'No marts found';

  @override
  String get loadingMarts => 'Loading marts...';

  @override
  String get errorLoadingMarts => 'Error loading marts';

  @override
  String get martDetails => 'Mart Details';

  @override
  String get martInformation => 'Mart Information';

  @override
  String get enterMartName => 'Enter mart name';

  @override
  String get pleaseEnterMartName => 'Please enter mart name';

  @override
  String get martLocation => 'Mart Location';

  @override
  String get enterMartLocation => 'Enter mart location';

  @override
  String get pleaseEnterMartLocation => 'Please enter mart location';

  @override
  String get martPhone => 'Mart Phone';

  @override
  String get enterMartPhone => 'Enter mart phone';

  @override
  String get pleaseEnterMartPhone => 'Please enter mart phone';

  @override
  String get martEmail => 'Mart Email';

  @override
  String get enterMartEmail => 'Enter mart email';

  @override
  String get pleaseEnterMartEmail => 'Please enter mart email';

  @override
  String get pleaseEnterValidMartEmail => 'Please enter a valid email';

  @override
  String get martZone => 'Mart Zone';

  @override
  String get selectMartZone => 'Select mart zone';

  @override
  String get pleaseSelectMartZone => 'Please select a zone';

  @override
  String get martDescription => 'Mart Description';

  @override
  String get enterMartDescription => 'Enter mart description';

  @override
  String get martCoordinates => 'Mart Coordinates';

  @override
  String get enterMartLatitude => 'Enter latitude';

  @override
  String get enterMartLongitude => 'Enter longitude';

  @override
  String get pleaseEnterValidLatitude => 'Please enter a valid latitude';

  @override
  String get pleaseEnterValidLongitude => 'Please enter a valid longitude';

  @override
  String get martOperatingHours => 'Operating Hours';

  @override
  String get openAllDay => 'Open 24/7';

  @override
  String get customHours => 'Custom Hours';

  @override
  String get mondayToFriday => 'Monday to Friday';

  @override
  String get weekends => 'Weekends';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get closed => 'Closed';

  @override
  String get createMart => 'Create Mart';

  @override
  String get updateMart => 'Update Mart';

  @override
  String get martCreatedSuccessfully => 'Mart created successfully';

  @override
  String get martUpdatedSuccessfully => 'Mart updated successfully';

  @override
  String get martDeletedSuccessfully => 'Mart deleted successfully';

  @override
  String get confirmDeleteMart => 'Are you sure you want to delete this mart?';

  @override
  String get cannotDeleteMartWithOrders =>
      'Cannot delete mart with existing orders';

  @override
  String get toggleMartStatus => 'Toggle Mart Status';

  @override
  String get activateMart => 'Activate Mart';

  @override
  String get deactivateMart => 'Deactivate Mart';

  @override
  String get martStatusUpdated => 'Mart status updated successfully';

  @override
  String get martStaffManagement => 'Staff Management';

  @override
  String get addMartStaff => 'Add Staff';

  @override
  String get manageMartStaff => 'Manage Staff';

  @override
  String get martStaff => 'Mart Staff';

  @override
  String get noMartStaffFound => 'No staff found';

  @override
  String get staffName => 'Staff Name';

  @override
  String get enterStaffName => 'Enter staff name';

  @override
  String get pleaseEnterStaffName => 'Please enter staff name';

  @override
  String get staffEmail => 'Staff Email';

  @override
  String get enterStaffEmail => 'Enter staff email';

  @override
  String get pleaseEnterStaffEmail => 'Please enter staff email';

  @override
  String get pleaseEnterValidStaffEmail => 'Please enter a valid email';

  @override
  String get staffPhone => 'Staff Phone';

  @override
  String get enterStaffPhone => 'Enter staff phone';

  @override
  String get pleaseEnterStaffPhone => 'Please enter staff phone';

  @override
  String get staffPassword => 'Staff Password';

  @override
  String get enterStaffPassword => 'Enter staff password';

  @override
  String get pleaseEnterStaffPassword => 'Please enter staff password';

  @override
  String get staffRole => 'Staff Role';

  @override
  String get selectStaffRole => 'Select staff role';

  @override
  String get pleaseSelectStaffRole => 'Please select a staff role';

  @override
  String get martAdmin => 'Mart Admin';

  @override
  String get martOperator => 'Mart Operator';

  @override
  String get createStaff => 'Create Staff';

  @override
  String get staffCreatedSuccessfully => 'Staff created successfully';

  @override
  String get staffRemovedSuccessfully => 'Staff removed successfully';

  @override
  String get confirmRemoveStaff =>
      'Are you sure you want to remove this staff member?';

  @override
  String get removeStaff => 'Remove Staff';

  @override
  String get toggleStaffStatus => 'Toggle Status';

  @override
  String get staffStatusUpdated => 'Staff status updated successfully';

  @override
  String get lastLogin => 'Last Login';

  @override
  String get neverLoggedIn => 'Never logged in';

  @override
  String get martPerformance => 'Mart Performance';

  @override
  String get viewMartPerformance => 'View Performance';

  @override
  String get martAnalytics => 'Mart Analytics';

  @override
  String get totalMartRevenue => 'Total Revenue';

  @override
  String get totalMartOrders => 'Total Orders';

  @override
  String get totalMartProducts => 'Total Products';

  @override
  String get activeMartProducts => 'Active Products';

  @override
  String get totalMartStaff => 'Total Staff';

  @override
  String get averageMartOrderValue => 'Average Order Value';

  @override
  String get todayOrders => 'Today\'s Orders';

  @override
  String get todayRevenue => 'Today\'s Revenue';

  @override
  String get topMartProducts => 'Top Products';

  @override
  String get soldQuantity => 'Sold Quantity';

  @override
  String get productRevenue => 'Product Revenue';

  @override
  String get martsByZone => 'Marts by Zone';

  @override
  String get viewMartsByZone => 'View by Zone';

  @override
  String get topPerformingMarts => 'Top Performing Marts';

  @override
  String get viewTopMarts => 'View Top Marts';

  @override
  String get dailyPerformance => 'Daily Performance';

  @override
  String get weeklyPerformance => 'Weekly Performance';

  @override
  String get monthlyPerformance => 'Monthly Performance';

  @override
  String get selectPerformancePeriod => 'Select period';

  @override
  String get performanceChart => 'Performance Chart';

  @override
  String get revenueChart => 'Revenue Chart';

  @override
  String get ordersChart => 'Orders Chart';

  @override
  String get exportMartData => 'Export Data';

  @override
  String get refreshMartData => 'Refresh Data';

  @override
  String get martSettings => 'Mart Settings';

  @override
  String get operatingStatus => 'Operating Status';

  @override
  String get martIsActive => 'Mart is active and accepting orders';

  @override
  String get martIsInactive => 'Mart is inactive and not accepting orders';

  @override
  String get createdOn => 'Created On';

  @override
  String get lastUpdatedOn => 'Last Updated On';

  @override
  String get clearMartFilters => 'Clear Filters';

  @override
  String get applyMartFilters => 'Apply Filters';

  @override
  String get selectDateRange => 'Select Date Range';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get errorCreatingMart => 'Error creating mart';

  @override
  String get errorUpdatingMart => 'Error updating mart';

  @override
  String get errorDeletingMart => 'Error deleting mart';

  @override
  String get errorLoadingMartStaff => 'Error loading mart staff';

  @override
  String get errorCreatingStaff => 'Error creating staff';

  @override
  String get errorRemovingStaff => 'Error removing staff';

  @override
  String get errorLoadingMartPerformance => 'Error loading mart performance';

  @override
  String get retryLoadingMarts => 'Retry Loading Marts';

  @override
  String showingMarts(int current, int total) {
    return 'Showing $current of $total marts';
  }

  @override
  String get basicInformation => 'Basic Information';

  @override
  String get contactInformation => 'Contact Information';

  @override
  String get pleaseEnterEmail => 'Please enter email address';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email address';

  @override
  String get pleaseEnterAddress => 'Please enter address';

  @override
  String get zones => 'Zones';

  @override
  String get vehicle => 'Vehicle';

  @override
  String get deliveryMan => 'Delivery Man';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get noZone => 'No zone';

  @override
  String get notAvailable => 'N/A';

  @override
  String get assignZone => 'Assign Zone';

  @override
  String get viewAnalytics => 'View Analytics';

  @override
  String showingDeliveryMen(int count, int total) {
    return 'Showing $count of $total delivery men';
  }

  @override
  String get settlementManagement => 'Settlement Management';

  @override
  String get settlementManagementSubtitle =>
      'Manage and download individual settlement reports';

  @override
  String get downloadAllReports => 'Download All Reports';

  @override
  String get downloadIndividualReports => 'Download Individual Reports';

  @override
  String get settlementSelectDate => 'Select Date';

  @override
  String get todaysReports => 'Today\'s Reports';

  @override
  String get vendorReports => 'Vendor Reports';

  @override
  String get deliveryManReports => 'Delivery Man Reports';

  @override
  String get systemRevenueReport => 'System Revenue Report';

  @override
  String get downloadingReports => 'Downloading Reports...';

  @override
  String get reportsDownloadSuccess => 'Reports downloaded successfully';

  @override
  String get reportsDownloadError => 'Error downloading reports';

  @override
  String get settlementGenerateReports => 'Generate Reports';

  @override
  String get settlementDate => 'Settlement Date';

  @override
  String get totalVendors => 'Total Vendors';

  @override
  String get totalDeliveryMen => 'Total Delivery Men';

  @override
  String get totalTransactions => 'Total Transactions';

  @override
  String get systemCommission => 'System Commission';

  @override
  String get settlementSummary => 'Settlement Summary';

  @override
  String get overallSummary => 'Overall Summary';

  @override
  String get martsSummary => 'Marts Summary';

  @override
  String get totalSubtotal => 'Total Subtotal';

  @override
  String get selectDateToViewSettlement =>
      'Select a date to view settlement information';

  @override
  String get downloadComprehensiveReports =>
      'Download comprehensive settlement reports for all entities';

  @override
  String get more => 'More';
}
