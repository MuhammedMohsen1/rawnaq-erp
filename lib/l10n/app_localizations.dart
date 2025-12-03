import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Been Edeek Portal'**
  String get appTitle;

  /// Welcome message on login page
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// Login page subtitle
  ///
  /// In en, this message translates to:
  /// **'Sign in to your restaurant portal'**
  String get signInToRestaurantPortal;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// Email field placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Password field placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// Sign in button text
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Help text on login page
  ///
  /// In en, this message translates to:
  /// **'Need help? Contact your system administrator'**
  String get needHelp;

  /// Logout button text
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Logout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get confirmLogout;

  /// Dashboard navigation item
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Dashboard page title
  ///
  /// In en, this message translates to:
  /// **'Dashboard Overview'**
  String get dashboardOverview;

  /// Dashboard welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome back! Here\'s what\'s happening with your restaurant today.'**
  String get dashboardWelcomeMessage;

  /// Today's orders statistics card title
  ///
  /// In en, this message translates to:
  /// **'Today\'s Orders'**
  String get todaysOrders;

  /// Revenue statistics card title
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// Pending orders statistics card title
  ///
  /// In en, this message translates to:
  /// **'Pending Orders'**
  String get pendingOrders;

  /// Menu items statistics card title
  ///
  /// In en, this message translates to:
  /// **'Menu Items'**
  String get menuItems;

  /// Revenue chart title
  ///
  /// In en, this message translates to:
  /// **'Revenue Trend'**
  String get revenueTrend;

  /// Orders chart title
  ///
  /// In en, this message translates to:
  /// **'Orders Overview'**
  String get ordersOverview;

  /// Recent activities section title
  ///
  /// In en, this message translates to:
  /// **'Recent Activities'**
  String get recentActivities;

  /// View all button text
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// New order activity message
  ///
  /// In en, this message translates to:
  /// **'New order #{orderId} received'**
  String newOrderReceived(String orderId);

  /// Menu item updated activity message
  ///
  /// In en, this message translates to:
  /// **'Menu item \"{itemName}\" updated'**
  String menuItemUpdated(String itemName);

  /// Order completed activity message
  ///
  /// In en, this message translates to:
  /// **'Order #{orderId} completed'**
  String orderCompleted(String orderId);

  /// New review activity message
  ///
  /// In en, this message translates to:
  /// **'New review received ({stars} stars)'**
  String newReviewReceived(int stars);

  /// Payment received activity message
  ///
  /// In en, this message translates to:
  /// **'Payment received for order #{orderId}'**
  String paymentReceived(String orderId);

  /// Food management navigation item
  ///
  /// In en, this message translates to:
  /// **'Food Management'**
  String get foodManagement;

  /// Categories navigation item
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// Orders navigation item
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// Pickup management navigation item
  ///
  /// In en, this message translates to:
  /// **'Pickup Management'**
  String get pickupManagement;

  /// Reviews navigation item
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// Working hours navigation item
  ///
  /// In en, this message translates to:
  /// **'Working Hours'**
  String get workingHours;

  /// Restaurant profile navigation item
  ///
  /// In en, this message translates to:
  /// **'Restaurant Profile'**
  String get restaurantProfile;

  /// User access navigation item
  ///
  /// In en, this message translates to:
  /// **'User Access'**
  String get userAccess;

  /// Reports navigation item
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// Deactivate restaurant navigation item
  ///
  /// In en, this message translates to:
  /// **'Deactivate Restaurant'**
  String get deactivateRestaurant;

  /// Restaurant portal title in sidebar
  ///
  /// In en, this message translates to:
  /// **'Restaurant Portal'**
  String get restaurantPortal;

  /// Management system subtitle in sidebar
  ///
  /// In en, this message translates to:
  /// **'Management System'**
  String get managementSystem;

  /// Food management page subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage your restaurant\'s food items and menu'**
  String get menuManagement;

  /// Order management page title
  ///
  /// In en, this message translates to:
  /// **'Order Management'**
  String get orderManagement;

  /// Order management page subtitle
  ///
  /// In en, this message translates to:
  /// **'Track and manage all customer orders'**
  String get orderManagementSubtitle;

  /// Category management page title
  ///
  /// In en, this message translates to:
  /// **'Category Management'**
  String get categoryManagement;

  /// Advertisement management menu item
  ///
  /// In en, this message translates to:
  /// **'Advertisement Management'**
  String get advertisementManagement;

  /// Pending approval tab label
  ///
  /// In en, this message translates to:
  /// **'Pending Approval'**
  String get pendingApproval;

  /// Pricing tiers tab label
  ///
  /// In en, this message translates to:
  /// **'Pricing Tiers'**
  String get pricingTiers;

  /// Empty state message for pending ads
  ///
  /// In en, this message translates to:
  /// **'No pending advertisements found'**
  String get noPendingAdvertisements;

  /// Vendor label
  ///
  /// In en, this message translates to:
  /// **'Vendor'**
  String get vendor;

  /// Approve button text
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// Approve advertisement dialog title
  ///
  /// In en, this message translates to:
  /// **'Approve Advertisement'**
  String get approveAdvertisement;

  /// Reject advertisement dialog title
  ///
  /// In en, this message translates to:
  /// **'Reject Advertisement'**
  String get rejectAdvertisement;

  /// Approval confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to approve this advertisement?'**
  String get approveConfirmation;

  /// Rejection reason prompt
  ///
  /// In en, this message translates to:
  /// **'Please provide a reason for rejection:'**
  String get rejectionReasonPrompt;

  /// Rejection reason field label
  ///
  /// In en, this message translates to:
  /// **'Rejection Reason'**
  String get rejectionReason;

  /// Rejection reason field hint
  ///
  /// In en, this message translates to:
  /// **'Enter reason for rejection'**
  String get rejectionReasonHint;

  /// Pricing tiers management title
  ///
  /// In en, this message translates to:
  /// **'Pricing Tiers Management'**
  String get pricingTiersManagement;

  /// Pricing tiers description
  ///
  /// In en, this message translates to:
  /// **'Configure advertisement pricing tiers'**
  String get configurePricingTiers;

  /// Load pricing tiers button
  ///
  /// In en, this message translates to:
  /// **'Load Pricing Tiers'**
  String get loadPricingTiers;

  /// Analytics title
  ///
  /// In en, this message translates to:
  /// **'Advertisement Analytics'**
  String get advertisementAnalytics;

  /// Analytics description
  ///
  /// In en, this message translates to:
  /// **'View performance metrics and insights'**
  String get performanceMetrics;

  /// Load analytics button
  ///
  /// In en, this message translates to:
  /// **'Load Analytics'**
  String get loadAnalytics;

  /// Create pricing tier button
  ///
  /// In en, this message translates to:
  /// **'Create Pricing Tier'**
  String get createPricingTier;

  /// Empty state message for pricing tiers
  ///
  /// In en, this message translates to:
  /// **'No pricing tiers configured'**
  String get noPricingTiers;

  /// Empty state description for pricing tiers
  ///
  /// In en, this message translates to:
  /// **'Create your first pricing tier to get started'**
  String get createFirstPricingTier;

  /// Base price label
  ///
  /// In en, this message translates to:
  /// **'Base Price'**
  String get basePrice;

  /// Duration label
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// Multiplier label
  ///
  /// In en, this message translates to:
  /// **'Multiplier'**
  String get multiplier;

  /// Create pricing tier dialog title
  ///
  /// In en, this message translates to:
  /// **'Create New Pricing Tier'**
  String get createPricingTierTitle;

  /// Update pricing tier dialog title
  ///
  /// In en, this message translates to:
  /// **'Update Pricing Tier'**
  String get updatePricingTierTitle;

  /// Advertisement type field label
  ///
  /// In en, this message translates to:
  /// **'Advertisement Type'**
  String get advertisementType;

  /// Advertisement type dropdown hint
  ///
  /// In en, this message translates to:
  /// **'Select Advertisement Type'**
  String get selectAdvertisementType;

  /// Position dropdown hint
  ///
  /// In en, this message translates to:
  /// **'Select Position'**
  String get selectPosition;

  /// Base price field hint
  ///
  /// In en, this message translates to:
  /// **'Enter base price'**
  String get basePriceHint;

  /// Duration type field label
  ///
  /// In en, this message translates to:
  /// **'Duration Type'**
  String get durationType;

  /// Duration type dropdown hint
  ///
  /// In en, this message translates to:
  /// **'Select Duration Type'**
  String get selectDurationType;

  /// Multiplier field hint
  ///
  /// In en, this message translates to:
  /// **'Enter multiplier (default: 1.0)'**
  String get multiplierHint;

  /// Delete pricing tier dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Pricing Tier'**
  String get deletePricingTierTitle;

  /// Delete pricing tier confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this pricing tier? This action cannot be undone.'**
  String get deletePricingTierConfirmation;

  /// Create advertisement tab label
  ///
  /// In en, this message translates to:
  /// **'Create Advertisement'**
  String get createAdvertisement;

  /// Create advertisement page title
  ///
  /// In en, this message translates to:
  /// **'Create New Advertisement'**
  String get createNewAdvertisement;

  /// Advertisement title field label
  ///
  /// In en, this message translates to:
  /// **'Advertisement Title'**
  String get advertisementTitle;

  /// Advertisement title field hint
  ///
  /// In en, this message translates to:
  /// **'Enter advertisement title'**
  String get enterAdvertisementTitle;

  /// Advertisement description field label
  ///
  /// In en, this message translates to:
  /// **'Advertisement Description'**
  String get advertisementDescription;

  /// Advertisement description field hint
  ///
  /// In en, this message translates to:
  /// **'Enter advertisement description'**
  String get enterAdvertisementDescription;

  /// Advertisement image URL field label
  ///
  /// In en, this message translates to:
  /// **'Advertisement Image URL'**
  String get advertisementImageUrl;

  /// Advertisement image URL field hint
  ///
  /// In en, this message translates to:
  /// **'Enter advertisement image URL'**
  String get enterAdvertisementImageUrl;

  /// Target URL field label
  ///
  /// In en, this message translates to:
  /// **'Target URL'**
  String get targetUrl;

  /// Target URL field hint
  ///
  /// In en, this message translates to:
  /// **'Enter target URL'**
  String get enterTargetUrl;

  /// Advertisement start date field label
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get adStartDate;

  /// Advertisement end date field label
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get adEndDate;

  /// Advertisement start date field hint
  ///
  /// In en, this message translates to:
  /// **'Select start date'**
  String get selectAdStartDate;

  /// Advertisement end date field hint
  ///
  /// In en, this message translates to:
  /// **'Select end date'**
  String get selectAdEndDate;

  /// Total cost field label
  ///
  /// In en, this message translates to:
  /// **'Total Cost'**
  String get totalCost;

  /// Create advertisement button text
  ///
  /// In en, this message translates to:
  /// **'Create Advertisement'**
  String get createAdvertisementButton;

  /// Advertisement details section title
  ///
  /// In en, this message translates to:
  /// **'Advertisement Details'**
  String get advertisementDetails;

  /// Placement configuration section title
  ///
  /// In en, this message translates to:
  /// **'Placement Configuration'**
  String get placementConfiguration;

  /// Campaign duration section title
  ///
  /// In en, this message translates to:
  /// **'Campaign Duration'**
  String get campaignDuration;

  /// Cost calculation section title
  ///
  /// In en, this message translates to:
  /// **'Cost Calculation'**
  String get costCalculation;

  /// Advertisement title required validation
  ///
  /// In en, this message translates to:
  /// **'Advertisement title is required'**
  String get advertisementTitleRequired;

  /// Advertisement description required validation
  ///
  /// In en, this message translates to:
  /// **'Advertisement description is required'**
  String get advertisementDescriptionRequired;

  /// Image URL required validation
  ///
  /// In en, this message translates to:
  /// **'Image URL is required'**
  String get imageUrlRequired;

  /// Valid image URL required validation
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid image URL'**
  String get validImageUrlRequired;

  /// Target URL required validation
  ///
  /// In en, this message translates to:
  /// **'Target URL is required'**
  String get targetUrlRequired;

  /// Valid target URL required validation
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid target URL'**
  String get validTargetUrlRequired;

  /// Advertisement start date required validation
  ///
  /// In en, this message translates to:
  /// **'Start date is required'**
  String get adStartDateRequired;

  /// Advertisement end date required validation
  ///
  /// In en, this message translates to:
  /// **'End date is required'**
  String get adEndDateRequired;

  /// End date validation message
  ///
  /// In en, this message translates to:
  /// **'End date must be after start date'**
  String get endDateMustBeAfterStartDate;

  /// Calculated cost display label
  ///
  /// In en, this message translates to:
  /// **'Calculated Cost'**
  String get calculatedCost;

  /// Preview advertisement section title
  ///
  /// In en, this message translates to:
  /// **'Preview Advertisement'**
  String get previewAdvertisement;

  /// Advertisement preview label
  ///
  /// In en, this message translates to:
  /// **'Advertisement Preview'**
  String get advertisementPreview;

  /// Advertisement type field label
  ///
  /// In en, this message translates to:
  /// **'Advertisement Type'**
  String get adType;

  /// Position field label
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get position;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No button text
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No data message
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No orders empty state title
  ///
  /// In en, this message translates to:
  /// **'No Orders'**
  String get noOrders;

  /// No orders empty state subtitle
  ///
  /// In en, this message translates to:
  /// **'Orders will appear here when customers place them'**
  String get noOrdersSubtitle;

  /// Displayed when no pickup orders are found
  ///
  /// In en, this message translates to:
  /// **'No Orders Found'**
  String get noOrdersFound;

  /// General message when no pickup orders are found
  ///
  /// In en, this message translates to:
  /// **'No pickup orders found'**
  String get noPickupOrdersFound;

  /// Message when no pickup orders match the search query
  ///
  /// In en, this message translates to:
  /// **'No pickup orders found for your search'**
  String get noPickupOrdersFoundForSearch;

  /// Message when no pickup orders match the selected filter
  ///
  /// In en, this message translates to:
  /// **'No pickup orders found for this filter'**
  String get noPickupOrdersFoundForFilter;

  /// Subtitle for empty pickup orders list
  ///
  /// In en, this message translates to:
  /// **'Pickup orders will appear here'**
  String get pickupOrdersWillAppearHere;

  /// Title for reject order dialog
  ///
  /// In en, this message translates to:
  /// **'Reject Order'**
  String get rejectOrder;

  /// Label for estimated ready time
  ///
  /// In en, this message translates to:
  /// **'Estimated Ready'**
  String get estimatedReady;

  /// Text for items count suffix (e.g., '5 items')
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get itemsText;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Confirmation message for rejecting an order
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reject this order?'**
  String get rejectOrderConfirmation;

  /// Order ID column header
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get orderID;

  /// Customer column header
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// Items column header
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// Total column header
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Status column header
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// Time column header
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// Actions column header
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// View button text
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// View details button text
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// Unauthorized page title
  ///
  /// In en, this message translates to:
  /// **'Unauthorized'**
  String get unauthorized;

  /// Unauthorized page message
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to access this page.\\nPlease contact your administrator if you need access.'**
  String get unauthorizedMessage;

  /// Tooltip text for back button
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// Placeholder text for the food items search bar
  ///
  /// In en, this message translates to:
  /// **'Search food items...'**
  String get searchFoodItems;

  /// Main course food filter label
  ///
  /// In en, this message translates to:
  /// **'Main Course'**
  String get mainCourse;

  /// Appetizers food filter label
  ///
  /// In en, this message translates to:
  /// **'Appetizers'**
  String get appetizers;

  /// Desserts food filter label
  ///
  /// In en, this message translates to:
  /// **'Desserts'**
  String get desserts;

  /// Beverages food filter label
  ///
  /// In en, this message translates to:
  /// **'Beverages'**
  String get beverages;

  /// Working hours page title
  ///
  /// In en, this message translates to:
  /// **'Working Hours'**
  String get workingHoursTitle;

  /// Working hours page subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage your restaurant\'s operating hours'**
  String get workingHoursSubtitle;

  /// Opening time field label
  ///
  /// In en, this message translates to:
  /// **'Opening Time'**
  String get openingTime;

  /// Closing time field label
  ///
  /// In en, this message translates to:
  /// **'Closing Time'**
  String get closingTime;

  /// Opening time field placeholder
  ///
  /// In en, this message translates to:
  /// **'Select opening time'**
  String get selectOpeningTime;

  /// Closing time field placeholder
  ///
  /// In en, this message translates to:
  /// **'Select closing time'**
  String get selectClosingTime;

  /// Update working hours button text
  ///
  /// In en, this message translates to:
  /// **'Update Working Hours'**
  String get updateWorkingHours;

  /// Success message for working hours update
  ///
  /// In en, this message translates to:
  /// **'Working hours updated successfully!'**
  String get workingHoursUpdated;

  /// Error message for invalid time range
  ///
  /// In en, this message translates to:
  /// **'Closing time must be after opening time'**
  String get invalidTimeRange;

  /// Title displaying the current working hours
  ///
  /// In en, this message translates to:
  /// **'Current Working Hours'**
  String get currentWorkingHours;

  /// Subtitle for restaurant profile page
  ///
  /// In en, this message translates to:
  /// **'Manage your restaurant information and settings'**
  String get restaurantProfileSubtitle;

  /// Edit profile button text
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Cancel edit button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelEdit;

  /// Save changes button text
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// Restaurant information section title
  ///
  /// In en, this message translates to:
  /// **'Restaurant Information'**
  String get restaurantInformation;

  /// Restaurant information section subtitle
  ///
  /// In en, this message translates to:
  /// **'Basic information about your restaurant'**
  String get basicRestaurantInfo;

  /// Restaurant name field label
  ///
  /// In en, this message translates to:
  /// **'Restaurant Name'**
  String get restaurantName;

  /// Restaurant name field placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter restaurant name'**
  String get enterRestaurantName;

  /// Restaurant description field label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get restaurantDescription;

  /// Restaurant name validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter restaurant name'**
  String get pleaseEnterRestaurantName;

  /// Restaurant description validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter restaurant description'**
  String get pleaseEnterDescription;

  /// Text shown when a field is not set
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// Text shown when no description is available
  ///
  /// In en, this message translates to:
  /// **'No description available'**
  String get noDescriptionAvailable;

  /// Location information section title
  ///
  /// In en, this message translates to:
  /// **'Location Information'**
  String get locationInformation;

  /// Location information section subtitle
  ///
  /// In en, this message translates to:
  /// **'Restaurant location and zone details'**
  String get restaurantLocationZone;

  /// Latitude field label
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// Longitude field label
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// Latitude field placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter latitude'**
  String get enterLatitude;

  /// Longitude field placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter longitude'**
  String get enterLongitude;

  /// Latitude validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter latitude'**
  String get pleaseEnterLatitude;

  /// Longitude validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter longitude'**
  String get pleaseEnterLongitude;

  /// Invalid latitude validation error
  ///
  /// In en, this message translates to:
  /// **'Invalid latitude'**
  String get invalidLatitude;

  /// Invalid longitude validation error
  ///
  /// In en, this message translates to:
  /// **'Invalid longitude'**
  String get invalidLongitude;

  /// Zone field label
  ///
  /// In en, this message translates to:
  /// **'Zone'**
  String get zone;

  /// Zone field placeholder
  ///
  /// In en, this message translates to:
  /// **'Select zone'**
  String get selectZone;

  /// Zone validation error
  ///
  /// In en, this message translates to:
  /// **'Please select a zone'**
  String get pleaseSelectZone;

  /// Coordinates label
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get coordinates;

  /// Text shown when no option is selected
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get notSelected;

  /// Text shown for unknown zone
  ///
  /// In en, this message translates to:
  /// **'Unknown zone'**
  String get unknownZone;

  /// View on map button text
  ///
  /// In en, this message translates to:
  /// **'View on Map'**
  String get viewOnMap;

  /// Map button subtitle
  ///
  /// In en, this message translates to:
  /// **'Click to view restaurant location on map'**
  String get clickToViewLocation;

  /// Map integration message
  ///
  /// In en, this message translates to:
  /// **'Map integration coming soon!'**
  String get mapIntegrationComingSoon;

  /// Operating hours section title
  ///
  /// In en, this message translates to:
  /// **'Operating Hours'**
  String get operatingHours;

  /// Operating hours section subtitle
  ///
  /// In en, this message translates to:
  /// **'Restaurant working hours'**
  String get restaurantWorkingHours;

  /// Opens at label
  ///
  /// In en, this message translates to:
  /// **'Opens'**
  String get opensAt;

  /// Closes at label
  ///
  /// In en, this message translates to:
  /// **'Closes'**
  String get closesAt;

  /// Currently open status
  ///
  /// In en, this message translates to:
  /// **'Currently Open'**
  String get currentlyOpen;

  /// Currently closed status
  ///
  /// In en, this message translates to:
  /// **'Currently Closed'**
  String get currentlyClosed;

  /// Opening time validation error
  ///
  /// In en, this message translates to:
  /// **'Please select opening time'**
  String get pleaseSelectOpeningTime;

  /// Closing time validation error
  ///
  /// In en, this message translates to:
  /// **'Please select closing time'**
  String get pleaseSelectClosingTime;

  /// Restaurant status section title
  ///
  /// In en, this message translates to:
  /// **'Restaurant Status'**
  String get restaurantStatus;

  /// Restaurant status section subtitle
  ///
  /// In en, this message translates to:
  /// **'Status and account information'**
  String get statusAccountInfo;

  /// Active status
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Inactive status
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// Warning message for inactive restaurant
  ///
  /// In en, this message translates to:
  /// **'Restaurant is currently inactive. Customers cannot place orders.'**
  String get restaurantInactiveWarning;

  /// Customer rating label
  ///
  /// In en, this message translates to:
  /// **'Customer Rating'**
  String get customerRating;

  /// Excellent rating label
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get excellent;

  /// Very good rating label
  ///
  /// In en, this message translates to:
  /// **'Very Good'**
  String get veryGood;

  /// Good rating label
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// Fair rating label
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get fair;

  /// Poor rating label
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get poor;

  /// Created timestamp label
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// Last updated timestamp label
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get lastUpdated;

  /// Today date label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Yesterday date label
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Days ago format
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(int count);

  /// Unknown label
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// Downtown zone name
  ///
  /// In en, this message translates to:
  /// **'Downtown'**
  String get downtown;

  /// Mall area zone name
  ///
  /// In en, this message translates to:
  /// **'Mall Area'**
  String get mallArea;

  /// Business district zone name
  ///
  /// In en, this message translates to:
  /// **'Business District'**
  String get businessDistrict;

  /// Residential area zone name
  ///
  /// In en, this message translates to:
  /// **'Residential Area'**
  String get residentialArea;

  /// Success message after profile update
  ///
  /// In en, this message translates to:
  /// **'Restaurant profile updated successfully!'**
  String get profileUpdatedSuccessfully;

  /// Error message when profile update fails
  ///
  /// In en, this message translates to:
  /// **'Error updating profile: {error}'**
  String errorUpdatingProfile(String error);

  /// Error message when profile loading fails
  ///
  /// In en, this message translates to:
  /// **'Error loading restaurant profile'**
  String get errorLoadingProfile;

  /// Title for 404 error page
  ///
  /// In en, this message translates to:
  /// **'Page Not Found'**
  String get pageNotFound;

  /// Description for 404 error page
  ///
  /// In en, this message translates to:
  /// **'The page you are looking for doesn\'t exist or has been moved.'**
  String get pageNotFoundDescription;

  /// Button text to go to dashboard
  ///
  /// In en, this message translates to:
  /// **'Go to Dashboard'**
  String get goToDashboard;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Placeholder text for orders chart
  ///
  /// In en, this message translates to:
  /// **'Orders chart will be displayed here'**
  String get ordersChartPlaceholder;

  /// Placeholder text for revenue chart
  ///
  /// In en, this message translates to:
  /// **'Revenue chart will be displayed here'**
  String get revenueChartPlaceholder;

  /// Access denied title
  ///
  /// In en, this message translates to:
  /// **'Access Denied'**
  String get accessDenied;

  /// All filter option
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// New order status
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newCategory;

  /// Preparing order status
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get preparing;

  /// Ready order status
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// Pending order status
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Completed order status
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// Cancelled order status
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// Filter by status label
  ///
  /// In en, this message translates to:
  /// **'Filter by Status'**
  String get filterByStatus;

  /// Order details dialog title
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// Order status update success message
  ///
  /// In en, this message translates to:
  /// **'Order status updated successfully'**
  String get orderStatusUpdated;

  /// Order not found error message
  ///
  /// In en, this message translates to:
  /// **'Order not found'**
  String get orderNotFound;

  /// Order number label
  ///
  /// In en, this message translates to:
  /// **'Order Number'**
  String get orderNumber;

  /// Estimated delivery time label
  ///
  /// In en, this message translates to:
  /// **'Estimated Delivery'**
  String get estimatedDelivery;

  /// Customer information section title
  ///
  /// In en, this message translates to:
  /// **'Customer Information'**
  String get customerInfo;

  /// Customer name label
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get customerName;

  /// Phone number label
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// Email address label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Delivery address label
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get deliveryAddress;

  /// Order items section title
  ///
  /// In en, this message translates to:
  /// **'Order Items'**
  String get orderItems;

  /// Item quantity label
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// Order notes label
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// Currency symbol
  ///
  /// In en, this message translates to:
  /// **'EGP'**
  String get currency;

  /// Order summary section title
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderSummary;

  /// Order subtotal label
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// Delivery fee label
  ///
  /// In en, this message translates to:
  /// **'Delivery Fee'**
  String get deliveryFee;

  /// Tax amount label
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// Payment method label
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// Payment status label
  ///
  /// In en, this message translates to:
  /// **'Payment Status'**
  String get paymentStatus;

  /// Accept order button text
  ///
  /// In en, this message translates to:
  /// **'Accept Order'**
  String get acceptOrder;

  /// Cancel order button text
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get cancelOrder;

  /// Mark order as completed button text
  ///
  /// In en, this message translates to:
  /// **'Mark as Completed'**
  String get markAsCompleted;

  /// Customer information section title
  ///
  /// In en, this message translates to:
  /// **'Customer Information'**
  String get customerInformation;

  /// Phone number label
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// Customer ID label
  ///
  /// In en, this message translates to:
  /// **'Customer ID'**
  String get customerId;

  /// Address label
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// Address line 1 label
  ///
  /// In en, this message translates to:
  /// **'Address Line 1'**
  String get addressLine1;

  /// Address line 2 label
  ///
  /// In en, this message translates to:
  /// **'Address Line 2'**
  String get addressLine2;

  /// City label
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// Special instructions label
  ///
  /// In en, this message translates to:
  /// **'Special Instructions'**
  String get specialInstructions;

  /// Restaurant pickups section title
  ///
  /// In en, this message translates to:
  /// **'Restaurant Pickups'**
  String get restaurantPickups;

  /// Restaurant ID label
  ///
  /// In en, this message translates to:
  /// **'Restaurant ID'**
  String get restaurantId;

  /// Label for estimated time field
  ///
  /// In en, this message translates to:
  /// **'Estimated Time'**
  String get estimatedTime;

  /// Label for pickup timestamp
  ///
  /// In en, this message translates to:
  /// **'Picked Up At'**
  String get pickedUpAt;

  /// Label for actual delivery/pickup time
  ///
  /// In en, this message translates to:
  /// **'Actual Time'**
  String get actualTime;

  /// Label for food preparation time
  ///
  /// In en, this message translates to:
  /// **'Preparation Time'**
  String get preparationTime;

  /// Label for special notes on order items
  ///
  /// In en, this message translates to:
  /// **'Special Notes'**
  String get specialNotes;

  /// Label for order item customizations
  ///
  /// In en, this message translates to:
  /// **'Customizations'**
  String get customizations;

  /// AM indicator for 12-hour time format
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get am;

  /// PM indicator for 12-hour time format
  ///
  /// In en, this message translates to:
  /// **'PM'**
  String get pm;

  /// Number of items in an order
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{item} other{items}}'**
  String itemsCount(int count);

  /// Time elapsed in minutes
  ///
  /// In en, this message translates to:
  /// **'{minutes} {minutes, plural, =1{minute} other{minutes}} ago'**
  String minutesAgo(int minutes);

  /// Time elapsed in hours
  ///
  /// In en, this message translates to:
  /// **'{hours} {hours, plural, =1{hour} other{hours}} ago'**
  String hoursAgo(int hours);

  /// Button text to start preparing an order
  ///
  /// In en, this message translates to:
  /// **'Start Preparing'**
  String get startPreparing;

  /// Button text to mark order as picked up
  ///
  /// In en, this message translates to:
  /// **'Mark as Picked Up'**
  String get markAsPickedUp;

  /// Accept button text
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// Reject button text
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// Mark ready for pickup button text
  ///
  /// In en, this message translates to:
  /// **'Mark Ready for Pickup'**
  String get markReadyForPickup;

  /// Ready for pickup status text
  ///
  /// In en, this message translates to:
  /// **'Ready for Pickup'**
  String get readyForPickup;

  /// Placeholder text for order search field
  ///
  /// In en, this message translates to:
  /// **'Search orders...'**
  String get searchOrdersPlaceholder;

  /// Search button text
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Refresh button text
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Generic error text
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Available status text
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// Unavailable status text
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// Busy status text
  ///
  /// In en, this message translates to:
  /// **'Busy'**
  String get busy;

  /// Showing text for lists
  ///
  /// In en, this message translates to:
  /// **'Showing'**
  String get showing;

  /// Total items count label
  ///
  /// In en, this message translates to:
  /// **'Total Items'**
  String get totalItems;

  /// Required field indicator
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// Add food button text
  ///
  /// In en, this message translates to:
  /// **'Add Food'**
  String get addFood;

  /// Update food button text
  ///
  /// In en, this message translates to:
  /// **'Update Food'**
  String get updateFood;

  /// Add new food item page title
  ///
  /// In en, this message translates to:
  /// **'Add New Food Item'**
  String get addNewFoodItem;

  /// Edit food item page title
  ///
  /// In en, this message translates to:
  /// **'Edit Food Item'**
  String get editFoodItem;

  /// Food details section title
  ///
  /// In en, this message translates to:
  /// **'Food Details'**
  String get foodDetails;

  /// Food name field label
  ///
  /// In en, this message translates to:
  /// **'Food Name'**
  String get foodName;

  /// Food name field placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter food name'**
  String get enterFoodName;

  /// Food name validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter food name'**
  String get pleaseEnterFoodName;

  /// Name minimum length validation
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get nameMinLength;

  /// Name maximum length validation
  ///
  /// In en, this message translates to:
  /// **'Name cannot exceed 50 characters'**
  String get nameMaxLength;

  /// Description field label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Food description field placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter food description'**
  String get enterFoodDescription;

  /// Food description validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter food description'**
  String get pleaseEnterFoodDescription;

  /// Description minimum length validation
  ///
  /// In en, this message translates to:
  /// **'Description must be at least 10 characters'**
  String get descriptionMinLength;

  /// Description maximum length validation
  ///
  /// In en, this message translates to:
  /// **'Description cannot exceed 500 characters'**
  String get descriptionMaxLength;

  /// Price field label
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// Price field placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter price'**
  String get enterPrice;

  /// Price validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter price'**
  String get pleaseEnterPrice;

  /// Valid price validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid price'**
  String get pleaseEnterValidPrice;

  /// Price minimum value validation
  ///
  /// In en, this message translates to:
  /// **'Price must be greater than 0'**
  String get priceMinValue;

  /// Category field label
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Category selection placeholder
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// Category selection validation
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get pleaseSelectCategory;

  /// Image URL field label
  ///
  /// In en, this message translates to:
  /// **'Image URL'**
  String get imageUrl;

  /// Image URL field placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter image URL'**
  String get enterImageUrl;

  /// Image URL validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter image URL'**
  String get pleaseEnterImageUrl;

  /// Invalid image URL validation
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid image URL'**
  String get invalidImageUrl;

  /// Food requirements section title
  ///
  /// In en, this message translates to:
  /// **'Food Requirements'**
  String get foodRequirements;

  /// Add requirement button text
  ///
  /// In en, this message translates to:
  /// **'Add Requirement'**
  String get addRequirement;

  /// Requirement label
  ///
  /// In en, this message translates to:
  /// **'Requirement'**
  String get requirement;

  /// Requirement name field label
  ///
  /// In en, this message translates to:
  /// **'Requirement Name'**
  String get requirementName;

  /// Requirement name field hint
  ///
  /// In en, this message translates to:
  /// **'e.g., Size, Spice Level'**
  String get requirementNameHint;

  /// Requirement name validation
  ///
  /// In en, this message translates to:
  /// **'Please enter requirement name'**
  String get pleaseEnterRequirementName;

  /// Requirement name minimum length validation
  ///
  /// In en, this message translates to:
  /// **'Requirement name must be at least 2 characters'**
  String get requirementNameMinLength;

  /// Requirement name maximum length validation
  ///
  /// In en, this message translates to:
  /// **'Requirement name cannot exceed 30 characters'**
  String get requirementNameMaxLength;

  /// Requirement type label
  ///
  /// In en, this message translates to:
  /// **'Requirement Type'**
  String get requirementType;

  /// Single choice requirement type
  ///
  /// In en, this message translates to:
  /// **'Single Choice'**
  String get singleChoice;

  /// Multi choice requirement type
  ///
  /// In en, this message translates to:
  /// **'Multi Choice'**
  String get multiChoice;

  /// Required requirement information
  ///
  /// In en, this message translates to:
  /// **'Required: Customer must select an option'**
  String get requiredRequirementInfo;

  /// Multi choice requirement information
  ///
  /// In en, this message translates to:
  /// **'Multi-choice: Customer can select multiple options'**
  String get multiChoiceInfo;

  /// Options label
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// Option name field label
  ///
  /// In en, this message translates to:
  /// **'Option Name'**
  String get optionName;

  /// Option name field hint
  ///
  /// In en, this message translates to:
  /// **'e.g., Small, Medium, Large'**
  String get optionNameHint;

  /// Option name validation
  ///
  /// In en, this message translates to:
  /// **'Please enter option name'**
  String get pleaseEnterOptionName;

  /// Option name minimum length validation
  ///
  /// In en, this message translates to:
  /// **'Option name must be at least 1 character'**
  String get optionNameMinLength;

  /// Option name maximum length validation
  ///
  /// In en, this message translates to:
  /// **'Option name cannot exceed 20 characters'**
  String get optionNameMaxLength;

  /// Additional price field label
  ///
  /// In en, this message translates to:
  /// **'Additional Price'**
  String get additionalPrice;

  /// Additional price minimum value validation
  ///
  /// In en, this message translates to:
  /// **'Additional price cannot be negative'**
  String get additionalPriceMinValue;

  /// Add option button text
  ///
  /// In en, this message translates to:
  /// **'Add Option'**
  String get addOption;

  /// Minimum requirement validation
  ///
  /// In en, this message translates to:
  /// **'At least one requirement is needed'**
  String get minimumOneRequirement;

  /// Minimum options validation
  ///
  /// In en, this message translates to:
  /// **'At least two options are required'**
  String get minimumTwoOptions;

  /// Required single choice validation
  ///
  /// In en, this message translates to:
  /// **'At least one single-choice requirement must be required'**
  String get atLeastOneRequiredSingleChoice;

  /// Multi choice required validation
  ///
  /// In en, this message translates to:
  /// **'Multi-choice requirements cannot be required'**
  String get multiChoiceCannotBeRequired;

  /// No requirements message
  ///
  /// In en, this message translates to:
  /// **'No requirements added yet'**
  String get noRequirementsAdded;

  /// Food item added success message
  ///
  /// In en, this message translates to:
  /// **'Food item added successfully'**
  String get foodItemAddedSuccessfully;

  /// Food item updated success message
  ///
  /// In en, this message translates to:
  /// **'Food item updated successfully'**
  String get foodItemUpdatedSuccessfully;

  /// Toggle availability button text
  ///
  /// In en, this message translates to:
  /// **'Toggle Availability'**
  String get toggleAvailability;

  /// Error toggling availability message
  ///
  /// In en, this message translates to:
  /// **'Error toggling availability'**
  String get errorTogglingAvailability;

  /// Restaurant availability title
  ///
  /// In en, this message translates to:
  /// **'Restaurant Availability'**
  String get restaurantAvailability;

  /// Availability status label
  ///
  /// In en, this message translates to:
  /// **'Availability Status'**
  String get availabilityStatus;

  /// Availability toggle description
  ///
  /// In en, this message translates to:
  /// **'Toggle between available and busy status'**
  String get availabilityToggleDescription;

  /// Current status label
  ///
  /// In en, this message translates to:
  /// **'Current Status'**
  String get currentStatus;

  /// Status description label
  ///
  /// In en, this message translates to:
  /// **'Status Description'**
  String get statusDescription;

  /// Available status description
  ///
  /// In en, this message translates to:
  /// **'Restaurant is accepting orders'**
  String get availabilityInfoAvailable;

  /// Busy status description
  ///
  /// In en, this message translates to:
  /// **'Restaurant is temporarily busy'**
  String get availabilityInfoBusy;

  /// Restaurant available message
  ///
  /// In en, this message translates to:
  /// **'Restaurant is available'**
  String get restaurantIsAvailable;

  /// Restaurant busy message
  ///
  /// In en, this message translates to:
  /// **'Restaurant is busy'**
  String get restaurantIsBusy;

  /// Set to available button text
  ///
  /// In en, this message translates to:
  /// **'Set to Available'**
  String get setToAvailable;

  /// Set to busy button text
  ///
  /// In en, this message translates to:
  /// **'Set to Busy'**
  String get setToBusy;

  /// Availability updated success message
  ///
  /// In en, this message translates to:
  /// **'Availability updated successfully'**
  String get availabilityUpdated;

  /// Restaurant pickup label
  ///
  /// In en, this message translates to:
  /// **'Restaurant Pickup'**
  String get restaurantPickup;

  /// Add new item button text
  ///
  /// In en, this message translates to:
  /// **'Add New Item'**
  String get addNewItem;

  /// Restaurant description field placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter restaurant description'**
  String get enterRestaurantDescription;

  /// Subtitle for pickup management section
  ///
  /// In en, this message translates to:
  /// **'Manage orders for pickup and delivery'**
  String get manageOrdersForPickupAndDelivery;

  /// Admin dashboard page title
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// Admin dashboard page subtitle
  ///
  /// In en, this message translates to:
  /// **'Comprehensive platform management and analytics'**
  String get adminDashboardSubtitle;

  /// Platform overview section title
  ///
  /// In en, this message translates to:
  /// **'Platform Overview'**
  String get platformOverview;

  /// Key metrics section title
  ///
  /// In en, this message translates to:
  /// **'Key Metrics'**
  String get keyMetrics;

  /// Real-time updates section title
  ///
  /// In en, this message translates to:
  /// **'Real-time Updates'**
  String get realtimeUpdates;

  /// Management sections title
  ///
  /// In en, this message translates to:
  /// **'Management Sections'**
  String get managementSections;

  /// Restaurant management page title
  ///
  /// In en, this message translates to:
  /// **'Restaurant Management'**
  String get restaurantManagement;

  /// Message to show when no search has been performed
  ///
  /// In en, this message translates to:
  /// **'Search for restaurants to see results'**
  String get searchRestaurantsToSeeResults;

  /// Of text for pagination
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get ofText;

  /// Restaurants plural text
  ///
  /// In en, this message translates to:
  /// **'restaurants'**
  String get restaurants;

  /// Page text for pagination
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get page;

  /// System reports menu item
  ///
  /// In en, this message translates to:
  /// **'System Reports'**
  String get systemReports;

  /// Total orders label for dashboard
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get totalOrders;

  /// Total revenue label for dashboard
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get totalRevenue;

  /// Average order value label for dashboard
  ///
  /// In en, this message translates to:
  /// **'Average Order Value'**
  String get averageOrderValue;

  /// User management page title
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get userManagement;

  /// Loading users message
  ///
  /// In en, this message translates to:
  /// **'Loading users...'**
  String get loadingUsers;

  /// Error loading users message
  ///
  /// In en, this message translates to:
  /// **'Error loading users'**
  String get errorLoadingUsers;

  /// No users found message
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsersFound;

  /// Search users placeholder
  ///
  /// In en, this message translates to:
  /// **'Search users'**
  String get searchUsers;

  /// User type label
  ///
  /// In en, this message translates to:
  /// **'User Type'**
  String get userType;

  /// All user types filter option
  ///
  /// In en, this message translates to:
  /// **'All User Types'**
  String get allUserTypes;

  /// Customers user type
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// Delivery personnel user type
  ///
  /// In en, this message translates to:
  /// **'Delivery Personnel'**
  String get deliveryPersonnel;

  /// Title for delivery personnel management page
  ///
  /// In en, this message translates to:
  /// **'Delivery Personnel Management'**
  String get deliveryPersonnelManagement;

  /// Subtitle for delivery personnel management page
  ///
  /// In en, this message translates to:
  /// **'Manage delivery men, track performance, and assign zones'**
  String get manageDeliveryMenTrackPerformanceAssignZones;

  /// Button text to add new delivery man
  ///
  /// In en, this message translates to:
  /// **'Add Delivery Man'**
  String get addDeliveryMan;

  /// Search placeholder for delivery men
  ///
  /// In en, this message translates to:
  /// **'Search by name, email, or phone...'**
  String get searchByNameEmailOrPhone;

  /// Text showing number of selected delivery men
  ///
  /// In en, this message translates to:
  /// **'{count} delivery men selected'**
  String deliveryMenSelected(int count);

  /// Clear selection button text
  ///
  /// In en, this message translates to:
  /// **'Clear Selection'**
  String get clearSelection;

  /// Success message for delivery man creation
  ///
  /// In en, this message translates to:
  /// **'Delivery man created successfully'**
  String get deliveryManCreatedSuccessfully;

  /// Success message for delivery man update
  ///
  /// In en, this message translates to:
  /// **'Delivery man updated successfully'**
  String get deliveryManUpdatedSuccessfully;

  /// Success message for delivery man deletion
  ///
  /// In en, this message translates to:
  /// **'Delivery man deleted successfully'**
  String get deliveryManDeletedSuccessfully;

  /// Loading message for delivery personnel
  ///
  /// In en, this message translates to:
  /// **'Loading delivery personnel...'**
  String get loadingDeliveryPersonnel;

  /// Error title when loading delivery personnel fails
  ///
  /// In en, this message translates to:
  /// **'Error Loading Delivery Personnel'**
  String get errorLoadingDeliveryPersonnel;

  /// Message when no delivery personnel are found
  ///
  /// In en, this message translates to:
  /// **'No delivery personnel found'**
  String get noDeliveryPersonnelFound;

  /// Message to encourage adding delivery personnel
  ///
  /// In en, this message translates to:
  /// **'Add delivery personnel to start managing deliveries'**
  String get addDeliveryPersonnelToStartManagingDeliveries;

  /// Delete delivery man dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Delivery Man'**
  String get deleteDeliveryMan;

  /// Delete delivery man confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this delivery man? This action cannot be undone.'**
  String get areYouSureDeleteDeliveryMan;

  /// Message for analytics feature placeholder
  ///
  /// In en, this message translates to:
  /// **'Analytics feature coming soon'**
  String get analyticsFeatureComingSoon;

  /// Message for zone assignment feature placeholder
  ///
  /// In en, this message translates to:
  /// **'Zone assignment feature coming soon'**
  String get zoneAssignmentFeatureComingSoon;

  /// Title for bulk activate dialog
  ///
  /// In en, this message translates to:
  /// **'Activate Selected Delivery Men'**
  String get activateSelectedDeliveryMen;

  /// Title for bulk deactivate dialog
  ///
  /// In en, this message translates to:
  /// **'Deactivate Selected Delivery Men'**
  String get deactivateSelectedDeliveryMen;

  /// Bulk activate confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to activate {count} delivery men?'**
  String areYouSureBulkActivate(int count);

  /// Bulk deactivate confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to deactivate {count} delivery men?'**
  String areYouSureBulkDeactivate(int count);

  /// Edit delivery man dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit Delivery Man'**
  String get editDeliveryMan;

  /// Personal information section title
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// Full name field label
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// Name required validation message
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameIsRequired;

  /// Email required validation message
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailIsRequired;

  /// Invalid email validation message
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterValidEmail;

  /// Phone number required validation message
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneNumberIsRequired;

  /// Vehicle information section title
  ///
  /// In en, this message translates to:
  /// **'Vehicle Information'**
  String get vehicleInformation;

  /// Vehicle type label
  ///
  /// In en, this message translates to:
  /// **'Vehicle Type'**
  String get vehicleType;

  /// Vehicle type selection validation message
  ///
  /// In en, this message translates to:
  /// **'Please select a vehicle type'**
  String get pleaseSelectVehicleType;

  /// License ID number field label
  ///
  /// In en, this message translates to:
  /// **'License/ID Number'**
  String get licenseIdNumber;

  /// Motorcycle vehicle type
  ///
  /// In en, this message translates to:
  /// **'Motorcycle'**
  String get motorcycle;

  /// Bicycle vehicle type
  ///
  /// In en, this message translates to:
  /// **'Bicycle'**
  String get bicycle;

  /// Car vehicle type
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get car;

  /// Scooter vehicle type
  ///
  /// In en, this message translates to:
  /// **'Scooter'**
  String get scooter;

  /// License number required validation message
  ///
  /// In en, this message translates to:
  /// **'License number is required'**
  String get licenseNumberIsRequired;

  /// Zone assignment section title
  ///
  /// In en, this message translates to:
  /// **'Zone Assignment'**
  String get zoneAssignment;

  /// Account security section title
  ///
  /// In en, this message translates to:
  /// **'Account Security'**
  String get accountSecurity;

  /// Password required validation message
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordIsRequired;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Confirm password required validation message
  ///
  /// In en, this message translates to:
  /// **'Please confirm password'**
  String get pleaseConfirmPassword;

  /// Passwords mismatch validation message
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Update delivery man button text
  ///
  /// In en, this message translates to:
  /// **'Update Delivery Man'**
  String get updateDeliveryMan;

  /// All statuses filter option
  ///
  /// In en, this message translates to:
  /// **'All Statuses'**
  String get allStatuses;

  /// Suspended status
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get suspended;

  /// Name label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Joined date label
  ///
  /// In en, this message translates to:
  /// **'Joined Date'**
  String get joinedDate;

  /// Activate button text
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activate;

  /// Deactivate button text
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get deactivate;

  /// Showing results pagination text
  ///
  /// In en, this message translates to:
  /// **'Showing {current} of {total} results'**
  String showingResults(int current, int total);

  /// Page of pages text
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String pageOfPages(int current, int total);

  /// Assigned zone dropdown label
  ///
  /// In en, this message translates to:
  /// **'Assigned Zone (Optional)'**
  String get assignedZoneOptional;

  /// No zone assigned dropdown option
  ///
  /// In en, this message translates to:
  /// **'No zone assigned'**
  String get noZoneAssigned;

  /// Admin restaurants by zones page title
  ///
  /// In en, this message translates to:
  /// **'Restaurants by Zones'**
  String get restaurantsByZones;

  /// Zone management section title
  ///
  /// In en, this message translates to:
  /// **'Zone Management'**
  String get zoneManagement;

  /// All zones filter option
  ///
  /// In en, this message translates to:
  /// **'All Zones'**
  String get allZones;

  /// Active restaurants filter option
  ///
  /// In en, this message translates to:
  /// **'Active Restaurants'**
  String get activeRestaurants;

  /// Inactive restaurants filter option
  ///
  /// In en, this message translates to:
  /// **'Inactive Restaurants'**
  String get inactiveRestaurants;

  /// Total zones statistics label
  ///
  /// In en, this message translates to:
  /// **'Total Zones'**
  String get totalZones;

  /// Total restaurants statistics label
  ///
  /// In en, this message translates to:
  /// **'Total Restaurants'**
  String get totalRestaurants;

  /// Average rating label
  ///
  /// In en, this message translates to:
  /// **'Average Rating'**
  String get averageRating;

  /// Total menu items label
  ///
  /// In en, this message translates to:
  /// **'Total Menu Items'**
  String get totalMenuItems;

  /// Base delivery fee label
  ///
  /// In en, this message translates to:
  /// **'Base Delivery Fee'**
  String get baseDeliveryFee;

  /// Restaurant operating hours label
  ///
  /// In en, this message translates to:
  /// **'Operating Hours'**
  String get restaurantOperatingHours;

  /// Verified status label
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// Not verified status label
  ///
  /// In en, this message translates to:
  /// **'Not Verified'**
  String get notVerified;

  /// Zone code label
  ///
  /// In en, this message translates to:
  /// **'Zone Code'**
  String get zoneCode;

  /// Zone type label
  ///
  /// In en, this message translates to:
  /// **'Zone Type'**
  String get zoneType;

  /// Average restaurants per zone label
  ///
  /// In en, this message translates to:
  /// **'Average Restaurants per Zone'**
  String get averageRestaurantsPerZone;

  /// Include statistics checkbox label
  ///
  /// In en, this message translates to:
  /// **'Include Statistics'**
  String get includeStatistics;

  /// Zone breakdown section title
  ///
  /// In en, this message translates to:
  /// **'Zone Breakdown'**
  String get zoneBreakdown;

  /// Overall statistics section title
  ///
  /// In en, this message translates to:
  /// **'Overall Statistics'**
  String get overallStatistics;

  /// Loading restaurants message
  ///
  /// In en, this message translates to:
  /// **'Loading restaurants...'**
  String get loadingRestaurants;

  /// No restaurants found message
  ///
  /// In en, this message translates to:
  /// **'No restaurants found'**
  String get noRestaurantsFound;

  /// Error loading restaurants message
  ///
  /// In en, this message translates to:
  /// **'Error loading restaurants'**
  String get errorLoadingRestaurants;

  /// Refresh restaurants button text
  ///
  /// In en, this message translates to:
  /// **'Refresh Restaurants'**
  String get refreshRestaurants;

  /// Load more button text
  ///
  /// In en, this message translates to:
  /// **'Load More'**
  String get loadMore;

  /// Filter by zone label
  ///
  /// In en, this message translates to:
  /// **'Filter by Zone'**
  String get filterByZone;

  /// Filter restaurants by status label
  ///
  /// In en, this message translates to:
  /// **'Filter by Status'**
  String get filterRestaurantsByStatus;

  /// View restaurant details button text
  ///
  /// In en, this message translates to:
  /// **'View Restaurant Details'**
  String get viewRestaurantDetails;

  /// Restaurant actions dialog title
  ///
  /// In en, this message translates to:
  /// **'Restaurant Actions'**
  String get restaurantActions;

  /// Manage restaurants page subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage Restaurants'**
  String get manageRestaurants;

  /// Admin manage restaurants page subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage Restaurants'**
  String get adminManageRestaurants;

  /// Add restaurant button text
  ///
  /// In en, this message translates to:
  /// **'Add Restaurant'**
  String get addRestaurant;

  /// Welcome message for restaurant management page
  ///
  /// In en, this message translates to:
  /// **'Welcome to restaurant management'**
  String get welcomeToRestaurantManagement;

  /// Filters section title
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// Admin orders page title
  ///
  /// In en, this message translates to:
  /// **'Orders Management'**
  String get adminOrders;

  /// Search orders placeholder
  ///
  /// In en, this message translates to:
  /// **'Search orders...'**
  String get adminSearchOrders;

  /// All orders filter option
  ///
  /// In en, this message translates to:
  /// **'All Orders'**
  String get adminAllOrders;

  /// Pending orders filter option
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get adminPendingOrders;

  /// Confirmed orders filter option
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get adminConfirmedOrders;

  /// Preparing orders filter option
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get adminPreparingOrders;

  /// Ready orders filter option
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get adminReadyOrders;

  /// Completed orders filter option
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get adminCompletedOrders;

  /// Cancelled orders filter option
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get adminCancelledOrders;

  /// Order number column header for admin orders table
  ///
  /// In en, this message translates to:
  /// **'Order #'**
  String get adminOrderNumber;

  /// Customer name column header for admin orders table
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get adminCustomerName;

  /// Restaurant name column header for admin orders table
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get adminRestaurantName;

  /// Order status column header for admin orders table
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get adminOrderStatus;

  /// Order total column header for admin orders table
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get adminOrderTotal;

  /// Order date column header for admin orders table
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get adminOrderDate;

  /// Actions column header for admin orders table
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get adminOrderActions;

  /// Tooltip for view order details button in admin orders table
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get adminViewDetails;

  /// Displayed when no orders are found in admin orders table
  ///
  /// In en, this message translates to:
  /// **'No orders found'**
  String get adminNoOrdersFound;

  /// Displayed while loading orders in admin orders table
  ///
  /// In en, this message translates to:
  /// **'Loading orders...'**
  String get adminLoadingOrders;

  /// Displayed when there is an error loading orders in admin orders table
  ///
  /// In en, this message translates to:
  /// **'Error loading orders'**
  String get adminErrorLoadingOrders;

  /// Export orders button label in admin orders page
  ///
  /// In en, this message translates to:
  /// **'Export Orders'**
  String get adminExportOrders;

  /// Total orders statistics label in admin dashboard
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get adminTotalOrders;

  /// Total revenue statistics label in admin dashboard
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get adminTotalRevenue;

  /// Displayed when no orders match the current filters in admin orders page
  ///
  /// In en, this message translates to:
  /// **'No orders match your current filters'**
  String get adminNoOrdersMatchFilters;

  /// Dialog title for admin order details
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get adminOrderDetails;

  /// Order created at label for admin order details dialog
  ///
  /// In en, this message translates to:
  /// **'Created At'**
  String get adminCreatedAt;

  /// Estimated delivery time label for admin order details dialog
  ///
  /// In en, this message translates to:
  /// **'Estimated Delivery'**
  String get adminEstimatedDelivery;

  /// Actual delivery time label for admin order details dialog
  ///
  /// In en, this message translates to:
  /// **'Actual Delivery'**
  String get adminActualDelivery;

  /// Customer info section title for admin order details dialog
  ///
  /// In en, this message translates to:
  /// **'Customer Information'**
  String get adminCustomerInfo;

  /// Phone number label for admin order details dialog
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get adminPhoneNumber;

  /// Restaurant info section title for admin order details dialog
  ///
  /// In en, this message translates to:
  /// **'Restaurant Information'**
  String get adminRestaurantInfo;

  /// Delivery address section title for admin order details dialog
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get adminDeliveryAddress;

  /// Order items section title for admin order details dialog
  ///
  /// In en, this message translates to:
  /// **'Order Items'**
  String get adminOrderItems;

  /// Payment info section title for admin order details dialog
  ///
  /// In en, this message translates to:
  /// **'Payment Information'**
  String get adminPaymentInfo;

  /// Subtotal label for admin order details dialog
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get adminSubtotal;

  /// Delivery fee label for admin order details dialog
  ///
  /// In en, this message translates to:
  /// **'Delivery Fee'**
  String get adminDeliveryFee;

  /// Tax label for admin order details dialog
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get adminTax;

  /// Total amount label for admin order details dialog
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get adminTotalAmount;

  /// Payment method label for admin order details dialog
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get adminPaymentMethod;

  /// Payment status label for admin order details dialog
  ///
  /// In en, this message translates to:
  /// **'Payment Status'**
  String get adminPaymentStatus;

  /// Order notes label for admin order details dialog
  ///
  /// In en, this message translates to:
  /// **'Order Notes'**
  String get adminOrderNotes;

  /// Label for on the way orders in admin dashboard
  ///
  /// In en, this message translates to:
  /// **'On The Way'**
  String get adminOnTheWayOrders;

  /// Button label to refresh orders in admin orders page
  ///
  /// In en, this message translates to:
  /// **'Refresh Orders'**
  String get adminRefreshOrders;

  /// Quantity column header in admin orders table
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get adminQuantity;

  /// Unit price column header in admin orders table
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get adminUnitPrice;

  /// Special notes column header in admin orders table
  ///
  /// In en, this message translates to:
  /// **'Special Notes'**
  String get adminSpecialNotes;

  /// Order group number column header in admin orders table
  ///
  /// In en, this message translates to:
  /// **'Group Number'**
  String get adminGroupNumber;

  /// Orders count column header in admin orders table
  ///
  /// In en, this message translates to:
  /// **'Orders Count'**
  String get adminOrdersCount;

  /// Restaurants count column header in admin orders table
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get adminRestaurantsCount;

  /// Final amount column header in admin orders table
  ///
  /// In en, this message translates to:
  /// **'Final Amount'**
  String get adminFinalAmount;

  /// Cross zone indicator label
  ///
  /// In en, this message translates to:
  /// **'Cross Zone'**
  String get adminCrossZone;

  /// Same zone indicator label
  ///
  /// In en, this message translates to:
  /// **'Same Zone'**
  String get adminSameZone;

  /// Individual orders section title in order group
  ///
  /// In en, this message translates to:
  /// **'Individual Orders in this Group:'**
  String get adminIndividualOrdersInGroup;

  /// Total individual orders count statistics label
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get adminTotalOrdersIndividual;

  /// Average order group value statistics label
  ///
  /// In en, this message translates to:
  /// **'Avg Group Value'**
  String get adminAvgGroupValue;

  /// Average orders per group statistics label
  ///
  /// In en, this message translates to:
  /// **'Avg Orders/Group'**
  String get adminAvgOrdersPerGroup;

  /// Orders plural word
  ///
  /// In en, this message translates to:
  /// **'orders'**
  String get adminOrdersPlural;

  /// Restaurants plural word
  ///
  /// In en, this message translates to:
  /// **'restaurants'**
  String get adminRestaurantsPlural;

  /// Customer label prefix
  ///
  /// In en, this message translates to:
  /// **'Customer:'**
  String get adminCustomerLabel;

  /// Restaurant label prefix
  ///
  /// In en, this message translates to:
  /// **'Restaurant:'**
  String get adminRestaurantLabel;

  /// Total label prefix
  ///
  /// In en, this message translates to:
  /// **'Total:'**
  String get adminTotalLabel;

  /// Date label prefix
  ///
  /// In en, this message translates to:
  /// **'Date:'**
  String get adminDateLabel;

  /// Refund order group only button tooltip
  ///
  /// In en, this message translates to:
  /// **'Refund Order Group Only'**
  String get adminRefundOrderGroupOnly;

  /// Refund and deactivate customer button tooltip
  ///
  /// In en, this message translates to:
  /// **'Refund Order Group & Deactivate Customer'**
  String get adminRefundAndDeactivate;

  /// Refund only button label
  ///
  /// In en, this message translates to:
  /// **'Refund Only'**
  String get adminRefundOnly;

  /// Refund and deactivate button short label
  ///
  /// In en, this message translates to:
  /// **'Refund & Deactivate'**
  String get adminRefundAndDeactivateShort;

  /// Processing refund message
  ///
  /// In en, this message translates to:
  /// **'Processing refund and deactivating customer account...'**
  String get adminProcessingRefund;

  /// Processing refund only message
  ///
  /// In en, this message translates to:
  /// **'Processing refund only (customer account stays active)...'**
  String get adminProcessingRefundOnly;

  /// Zone management page title
  ///
  /// In en, this message translates to:
  /// **'Zone Management'**
  String get zoneManagementTitle;

  /// Zone management page subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage delivery zones and boundaries'**
  String get zoneManagementSubtitle;

  /// Add zone button text
  ///
  /// In en, this message translates to:
  /// **'Add Zone'**
  String get addZone;

  /// Edit zone button text
  ///
  /// In en, this message translates to:
  /// **'Edit Zone'**
  String get editZone;

  /// Delete zone button text
  ///
  /// In en, this message translates to:
  /// **'Delete Zone'**
  String get deleteZone;

  /// Zone name field label
  ///
  /// In en, this message translates to:
  /// **'Zone Name'**
  String get zoneName;

  /// Zone level field label
  ///
  /// In en, this message translates to:
  /// **'Zone Level'**
  String get zoneLevel;

  /// Parent zone field label
  ///
  /// In en, this message translates to:
  /// **'Parent Zone'**
  String get parentZone;

  /// Distance from center field label
  ///
  /// In en, this message translates to:
  /// **'Distance from Center'**
  String get distanceFromCenter;

  /// Zone active status field label
  ///
  /// In en, this message translates to:
  /// **'Zone Active'**
  String get zoneActive;

  /// Zone boundaries field label
  ///
  /// In en, this message translates to:
  /// **'Zone Boundaries'**
  String get zoneBoundaries;

  /// Message shown when no zones are found
  ///
  /// In en, this message translates to:
  /// **'No zones found'**
  String get noZonesFound;

  /// Loading message for zones
  ///
  /// In en, this message translates to:
  /// **'Loading zones...'**
  String get loadingZones;

  /// Zone details dialog title
  ///
  /// In en, this message translates to:
  /// **'Zone Details'**
  String get zoneDetails;

  /// Success message when zone is created
  ///
  /// In en, this message translates to:
  /// **'Zone created successfully'**
  String get zoneCreated;

  /// Success message when zone is updated
  ///
  /// In en, this message translates to:
  /// **'Zone updated successfully'**
  String get zoneUpdated;

  /// Success message when zone is deleted
  ///
  /// In en, this message translates to:
  /// **'Zone deleted successfully'**
  String get zoneDeleted;

  /// Confirm zone deletion dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this zone?'**
  String get confirmDeleteZone;

  /// Error message when zone cannot be deleted
  ///
  /// In en, this message translates to:
  /// **'Cannot delete zone'**
  String get cannotDeleteZone;

  /// Error message when zone has related data
  ///
  /// In en, this message translates to:
  /// **'This zone has related data and cannot be deleted'**
  String get zoneHasRelatedData;

  /// Related restaurants count label
  ///
  /// In en, this message translates to:
  /// **'Related Restaurants'**
  String get relatedRestaurants;

  /// Related data section title
  ///
  /// In en, this message translates to:
  /// **'Related Data'**
  String get relatedData;

  /// Related customer addresses count label
  ///
  /// In en, this message translates to:
  /// **'Related Customer Addresses'**
  String get relatedCustomerAddresses;

  /// Related marts count label
  ///
  /// In en, this message translates to:
  /// **'Related Marts'**
  String get relatedMarts;

  /// Related sub-zones count label
  ///
  /// In en, this message translates to:
  /// **'Related Sub-zones'**
  String get relatedSubZones;

  /// Total related records count label
  ///
  /// In en, this message translates to:
  /// **'Total Related Records'**
  String get totalRelatedRecords;

  /// Filter by zone type label
  ///
  /// In en, this message translates to:
  /// **'Filter by Zone Type'**
  String get filterByZoneType;

  /// Filter by zone level label
  ///
  /// In en, this message translates to:
  /// **'Filter by Zone Level'**
  String get filterByZoneLevel;

  /// All zone types filter option
  ///
  /// In en, this message translates to:
  /// **'All Zone Types'**
  String get allZoneTypes;

  /// All zone levels filter option
  ///
  /// In en, this message translates to:
  /// **'All Zone Levels'**
  String get allZoneLevels;

  /// Government zone type
  ///
  /// In en, this message translates to:
  /// **'Government'**
  String get government;

  /// District zone type
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// Neighborhood zone type
  ///
  /// In en, this message translates to:
  /// **'Neighborhood'**
  String get neighborhood;

  /// Area zone type
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get area;

  /// Zone level 1
  ///
  /// In en, this message translates to:
  /// **'Level 1'**
  String get level1;

  /// Zone level 2
  ///
  /// In en, this message translates to:
  /// **'Level 2'**
  String get level2;

  /// Zone level 3
  ///
  /// In en, this message translates to:
  /// **'Level 3'**
  String get level3;

  /// Zone level 4
  ///
  /// In en, this message translates to:
  /// **'Level 4'**
  String get level4;

  /// Zone level 5
  ///
  /// In en, this message translates to:
  /// **'Level 5'**
  String get level5;

  /// Select parent zone placeholder
  ///
  /// In en, this message translates to:
  /// **'Select Parent Zone'**
  String get selectParentZone;

  /// No parent zone option
  ///
  /// In en, this message translates to:
  /// **'No Parent Zone'**
  String get noParentZone;

  /// Zone hierarchy section title
  ///
  /// In en, this message translates to:
  /// **'Zone Hierarchy'**
  String get zoneHierarchy;

  /// View zone hierarchy button text
  ///
  /// In en, this message translates to:
  /// **'View Zone Hierarchy'**
  String get viewZoneHierarchy;

  /// Zone created at field label
  ///
  /// In en, this message translates to:
  /// **'Created At'**
  String get zoneCreatedAt;

  /// Zone updated at field label
  ///
  /// In en, this message translates to:
  /// **'Updated At'**
  String get zoneUpdatedAt;

  /// Zone name validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter zone name'**
  String get pleaseEnterZoneName;

  /// Zone code validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter zone code'**
  String get pleaseEnterZoneCode;

  /// Zone type validation error
  ///
  /// In en, this message translates to:
  /// **'Please select zone type'**
  String get pleaseSelectZoneType;

  /// Zone level validation error
  ///
  /// In en, this message translates to:
  /// **'Please select zone level'**
  String get pleaseSelectZoneLevel;

  /// Delivery fee validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter delivery fee'**
  String get pleaseEnterDeliveryFee;

  /// Valid delivery fee validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter valid delivery fee'**
  String get pleaseEnterValidDeliveryFee;

  /// Distance validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter distance'**
  String get pleaseEnterDistance;

  /// Valid distance validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter valid distance'**
  String get pleaseEnterValidDistance;

  /// Zone code already exists error
  ///
  /// In en, this message translates to:
  /// **'Zone code already exists'**
  String get zoneCodeAlreadyExists;

  /// Error creating zone message
  ///
  /// In en, this message translates to:
  /// **'Error creating zone'**
  String get errorCreatingZone;

  /// Error updating zone message
  ///
  /// In en, this message translates to:
  /// **'Error updating zone'**
  String get errorUpdatingZone;

  /// Error deleting zone message
  ///
  /// In en, this message translates to:
  /// **'Error deleting zone'**
  String get errorDeletingZone;

  /// Error loading zones message
  ///
  /// In en, this message translates to:
  /// **'Error loading zones'**
  String get errorLoadingZones;

  /// Error loading zone details message
  ///
  /// In en, this message translates to:
  /// **'Error loading zone details'**
  String get errorLoadingZoneDetails;

  /// Retry loading zones button text
  ///
  /// In en, this message translates to:
  /// **'Retry Loading Zones'**
  String get retryLoadingZones;

  /// Zone management help text
  ///
  /// In en, this message translates to:
  /// **'Manage delivery zones to organize your service areas'**
  String get zoneManagementHelp;

  /// Export zones button text
  ///
  /// In en, this message translates to:
  /// **'Export Zones'**
  String get exportZones;

  /// Import zones button text
  ///
  /// In en, this message translates to:
  /// **'Import Zones'**
  String get importZones;

  /// Zone export success message
  ///
  /// In en, this message translates to:
  /// **'Zones exported successfully'**
  String get zoneExportSuccess;

  /// Zone import success message
  ///
  /// In en, this message translates to:
  /// **'Zones imported successfully'**
  String get zoneImportSuccess;

  /// Invalid zone file error message
  ///
  /// In en, this message translates to:
  /// **'Invalid zone file'**
  String get invalidZoneFile;

  /// Error exporting zones message
  ///
  /// In en, this message translates to:
  /// **'Error exporting zones'**
  String get errorExportingZones;

  /// Error importing zones message
  ///
  /// In en, this message translates to:
  /// **'Error importing zones'**
  String get errorImportingZones;

  /// Current zone section title
  ///
  /// In en, this message translates to:
  /// **'Current Zone'**
  String get currentZone;

  /// Sub zones section title
  ///
  /// In en, this message translates to:
  /// **'Sub Zones'**
  String get subZones;

  /// No sub zones message
  ///
  /// In en, this message translates to:
  /// **'This zone has no sub-zones'**
  String get noSubZones;

  /// Zone level label
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// Kilometer unit
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get km;

  /// Update button text
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// Create button text
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Customer addresses label
  ///
  /// In en, this message translates to:
  /// **'Customer Addresses'**
  String get customerAddresses;

  /// Marts label
  ///
  /// In en, this message translates to:
  /// **'Marts'**
  String get marts;

  /// Mart admin dashboard title
  ///
  /// In en, this message translates to:
  /// **'Mart Dashboard'**
  String get martAdminDashboard;

  /// Mart point of sale title
  ///
  /// In en, this message translates to:
  /// **'Point of Sale'**
  String get martPos;

  /// Mart products title
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get martProducts;

  /// Add mart product title
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get martAddProduct;

  /// Mart inventory title
  ///
  /// In en, this message translates to:
  /// **'Inventory Management'**
  String get martInventory;

  /// Mart orders title
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get martOrders;

  /// Mart reports title
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get martReports;

  /// Mart profile title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get martProfile;

  /// Warning message for zones that cannot be deleted
  ///
  /// In en, this message translates to:
  /// **'This zone cannot be deleted because it has related data or sub-zones'**
  String get cannotDeleteZoneWithDependencies;

  /// Zone delivery rules title
  ///
  /// In en, this message translates to:
  /// **'Zone Delivery Rules'**
  String get zoneDeliveryRules;

  /// Zone delivery rules subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage delivery rules between zones'**
  String get manageZoneDeliveryRules;

  /// Add delivery rule button
  ///
  /// In en, this message translates to:
  /// **'Add Delivery Rule'**
  String get addDeliveryRule;

  /// Edit delivery rule button
  ///
  /// In en, this message translates to:
  /// **'Edit Delivery Rule'**
  String get editDeliveryRule;

  /// Delete delivery rule button
  ///
  /// In en, this message translates to:
  /// **'Delete Delivery Rule'**
  String get deleteDeliveryRule;

  /// Confirm delete delivery rule message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this delivery rule?'**
  String get confirmDeleteDeliveryRule;

  /// Delivery rule created success message
  ///
  /// In en, this message translates to:
  /// **'Delivery rule created successfully'**
  String get deliveryRuleCreated;

  /// Delivery rule updated success message
  ///
  /// In en, this message translates to:
  /// **'Delivery rule updated successfully'**
  String get deliveryRuleUpdated;

  /// Delivery rule deleted success message
  ///
  /// In en, this message translates to:
  /// **'Delivery rule deleted successfully'**
  String get deliveryRuleDeleted;

  /// Error loading delivery rules message
  ///
  /// In en, this message translates to:
  /// **'Error loading delivery rules'**
  String get errorLoadingDeliveryRules;

  /// Retry loading delivery rules button
  ///
  /// In en, this message translates to:
  /// **'Retry Loading Rules'**
  String get retryLoadingDeliveryRules;

  /// No delivery rules found message
  ///
  /// In en, this message translates to:
  /// **'No delivery rules found'**
  String get noDeliveryRulesFound;

  /// Delivery rules help text
  ///
  /// In en, this message translates to:
  /// **'Create delivery rules to manage cross-zone deliveries'**
  String get deliveryRulesHelp;

  /// From zone label
  ///
  /// In en, this message translates to:
  /// **'From Zone'**
  String get fromZone;

  /// To zone label
  ///
  /// In en, this message translates to:
  /// **'To Zone'**
  String get toZone;

  /// Select from zone placeholder
  ///
  /// In en, this message translates to:
  /// **'Select from zone'**
  String get selectFromZone;

  /// Select to zone placeholder
  ///
  /// In en, this message translates to:
  /// **'Select to zone'**
  String get selectToZone;

  /// Can deliver label
  ///
  /// In en, this message translates to:
  /// **'Can Deliver'**
  String get canDeliver;

  /// Additional fee label
  ///
  /// In en, this message translates to:
  /// **'Additional Fee'**
  String get additionalFee;

  /// Minimum order amount label
  ///
  /// In en, this message translates to:
  /// **'Minimum Order Amount'**
  String get minimumOrderAmount;

  /// Estimated time label
  ///
  /// In en, this message translates to:
  /// **'Estimated Time (Minutes)'**
  String get estimatedTimeMinutes;

  /// Max distance label
  ///
  /// In en, this message translates to:
  /// **'Max Distance (KM)'**
  String get maxDistance;

  /// Delivery rule details title
  ///
  /// In en, this message translates to:
  /// **'Delivery Rule Details'**
  String get deliveryRuleDetails;

  /// Please select from zone validation
  ///
  /// In en, this message translates to:
  /// **'Please select a from zone'**
  String get pleaseSelectFromZone;

  /// Please select to zone validation
  ///
  /// In en, this message translates to:
  /// **'Please select a to zone'**
  String get pleaseSelectToZone;

  /// Please enter valid additional fee validation
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid additional fee'**
  String get pleaseEnterValidAdditionalFee;

  /// Please enter valid minimum amount validation
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid minimum order amount'**
  String get pleaseEnterValidMinimumAmount;

  /// Please enter valid estimated time validation
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid estimated time'**
  String get pleaseEnterValidEstimatedTime;

  /// Please enter valid max distance validation
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid max distance'**
  String get pleaseEnterValidMaxDistance;

  /// Same zone selected validation message
  ///
  /// In en, this message translates to:
  /// **'From zone and to zone cannot be the same'**
  String get sameZoneSelected;

  /// Enabled label
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// Disabled label
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// Delivery allowed label
  ///
  /// In en, this message translates to:
  /// **'Delivery Allowed'**
  String get deliveryAllowed;

  /// Delivery not allowed label
  ///
  /// In en, this message translates to:
  /// **'Delivery Not Allowed'**
  String get deliveryNotAllowed;

  /// Minutes unit
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// Minutes unit abbreviation
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutesUnit;

  /// Kilometers unit
  ///
  /// In en, this message translates to:
  /// **'KM'**
  String get kilometers;

  /// Saudi Riyal currency
  ///
  /// In en, this message translates to:
  /// **'SAR'**
  String get sar;

  /// Optional field indicator
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// Edit button
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Recent reports title
  ///
  /// In en, this message translates to:
  /// **'Recent Reports'**
  String get recentReports;

  /// Weekly report title
  ///
  /// In en, this message translates to:
  /// **'Weekly Report'**
  String get weeklyReport;

  /// Current week title
  ///
  /// In en, this message translates to:
  /// **'Current Week'**
  String get currentWeek;

  /// Previous week title
  ///
  /// In en, this message translates to:
  /// **'Previous Week'**
  String get previousWeek;

  /// Profit margin title
  ///
  /// In en, this message translates to:
  /// **'Profit Margin'**
  String get profitMargin;

  /// Earnings title
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings;

  /// Total earnings title
  ///
  /// In en, this message translates to:
  /// **'Total Earnings'**
  String get totalEarnings;

  /// Net earnings title
  ///
  /// In en, this message translates to:
  /// **'Net Earnings'**
  String get netEarnings;

  /// Total products title
  ///
  /// In en, this message translates to:
  /// **'Total Products'**
  String get totalProducts;

  /// Total stock title
  ///
  /// In en, this message translates to:
  /// **'Total Stock'**
  String get totalStock;

  /// Low stock products title
  ///
  /// In en, this message translates to:
  /// **'Low Stock Products'**
  String get lowStockProducts;

  /// Low stock title
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get lowStock;

  /// Inventory summary title
  ///
  /// In en, this message translates to:
  /// **'Inventory Summary'**
  String get inventorySummary;

  /// Confirmed status
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// Disputed status
  ///
  /// In en, this message translates to:
  /// **'Disputed'**
  String get disputed;

  /// Pending confirmation status
  ///
  /// In en, this message translates to:
  /// **'Pending Confirmation'**
  String get pendingConfirmation;

  /// Report status title
  ///
  /// In en, this message translates to:
  /// **'Report Status'**
  String get reportStatus;

  /// Confirm report button
  ///
  /// In en, this message translates to:
  /// **'Confirm Report'**
  String get confirmReport;

  /// Dispute report button
  ///
  /// In en, this message translates to:
  /// **'Dispute Report'**
  String get disputeReport;

  /// Report details title
  ///
  /// In en, this message translates to:
  /// **'Report Details'**
  String get reportDetails;

  /// Week start title
  ///
  /// In en, this message translates to:
  /// **'Week Start'**
  String get weekStart;

  /// Week end title
  ///
  /// In en, this message translates to:
  /// **'Week End'**
  String get weekEnd;

  /// Commission title
  ///
  /// In en, this message translates to:
  /// **'Commission'**
  String get commission;

  /// Commission rate title
  ///
  /// In en, this message translates to:
  /// **'Commission Rate'**
  String get commissionRate;

  /// Delivery fees title
  ///
  /// In en, this message translates to:
  /// **'Delivery Fees'**
  String get deliveryFees;

  /// Cross zone fees title
  ///
  /// In en, this message translates to:
  /// **'Cross Zone Fees'**
  String get crossZoneFees;

  /// Order value title
  ///
  /// In en, this message translates to:
  /// **'Order Value'**
  String get orderValue;

  /// Total orders value title
  ///
  /// In en, this message translates to:
  /// **'Total Orders Value'**
  String get totalOrdersValue;

  /// Order count title
  ///
  /// In en, this message translates to:
  /// **'Order Count'**
  String get orderCount;

  /// Union orders title
  ///
  /// In en, this message translates to:
  /// **'Union Orders'**
  String get unionOrders;

  /// Individual orders title
  ///
  /// In en, this message translates to:
  /// **'Individual Orders'**
  String get individualOrders;

  /// Top selling items title
  ///
  /// In en, this message translates to:
  /// **'Top Selling Items'**
  String get topSellingItems;

  /// Items sold title
  ///
  /// In en, this message translates to:
  /// **'Items Sold'**
  String get itemsSold;

  /// Report generated message
  ///
  /// In en, this message translates to:
  /// **'Report Generated'**
  String get reportGenerated;

  /// Report confirmed message
  ///
  /// In en, this message translates to:
  /// **'Report Confirmed'**
  String get reportConfirmed;

  /// Report disputed message
  ///
  /// In en, this message translates to:
  /// **'Report Disputed'**
  String get reportDisputed;

  /// Union order label
  ///
  /// In en, this message translates to:
  /// **'Union Order'**
  String get unionOrder;

  /// Individual order label
  ///
  /// In en, this message translates to:
  /// **'Individual Order'**
  String get individualOrder;

  /// Union group label
  ///
  /// In en, this message translates to:
  /// **'Union Group'**
  String get unionGroup;

  /// Report information section title
  ///
  /// In en, this message translates to:
  /// **'Report Information'**
  String get reportInfo;

  /// Report period label
  ///
  /// In en, this message translates to:
  /// **'Report Period'**
  String get reportPeriod;

  /// Report type label
  ///
  /// In en, this message translates to:
  /// **'Report Type'**
  String get reportType;

  /// Financial summary section title
  ///
  /// In en, this message translates to:
  /// **'Financial Summary'**
  String get financialSummary;

  /// Orders summary section title
  ///
  /// In en, this message translates to:
  /// **'Orders Summary'**
  String get ordersSummary;

  /// Order items details section title
  ///
  /// In en, this message translates to:
  /// **'Order Items Details'**
  String get orderItemsDetails;

  /// Item name label
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get itemName;

  /// Unit price label
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get unitPrice;

  /// Order date label
  ///
  /// In en, this message translates to:
  /// **'Order Date'**
  String get orderDate;

  /// Delivery date label
  ///
  /// In en, this message translates to:
  /// **'Delivery Date'**
  String get deliveryDate;

  /// Confirmed by label
  ///
  /// In en, this message translates to:
  /// **'Confirmed By'**
  String get confirmedBy;

  /// Confirmed at label
  ///
  /// In en, this message translates to:
  /// **'Confirmed At'**
  String get confirmedAt;

  /// Generated at label
  ///
  /// In en, this message translates to:
  /// **'Generated At'**
  String get generatedAt;

  /// Title for mart reports page
  ///
  /// In en, this message translates to:
  /// **'Mart Reports'**
  String get martReportsTitle;

  /// Tooltip for refresh button
  ///
  /// In en, this message translates to:
  /// **'Refresh All Data'**
  String get refreshAllData;

  /// Tooltip for filter button
  ///
  /// In en, this message translates to:
  /// **'Filter Reports'**
  String get filterReports;

  /// Message when no dashboard data available
  ///
  /// In en, this message translates to:
  /// **'No dashboard data'**
  String get noDashboardData;

  /// Message when no analytics data available
  ///
  /// In en, this message translates to:
  /// **'No analytics data'**
  String get noAnalyticsData;

  /// Message when no performance data available
  ///
  /// In en, this message translates to:
  /// **'No performance data'**
  String get noPerformanceData;

  /// Message when no reports data available
  ///
  /// In en, this message translates to:
  /// **'No reports data'**
  String get noReportsData;

  /// Dashboard summary section title
  ///
  /// In en, this message translates to:
  /// **'Dashboard Summary'**
  String get dashboardSummary;

  /// Analytics data section title
  ///
  /// In en, this message translates to:
  /// **'Analytics Data'**
  String get analyticsData;

  /// Product performance section title
  ///
  /// In en, this message translates to:
  /// **'Product Performance'**
  String get productPerformance;

  /// Reports data section title
  ///
  /// In en, this message translates to:
  /// **'Reports Data'**
  String get reportsData;

  /// Total sales label
  ///
  /// In en, this message translates to:
  /// **'Total Sales'**
  String get totalSales;

  /// Total profit label
  ///
  /// In en, this message translates to:
  /// **'Total Profit'**
  String get totalProfit;

  /// Pending confirmations label
  ///
  /// In en, this message translates to:
  /// **'Pending Confirmations'**
  String get pendingConfirmations;

  /// Average order value label
  ///
  /// In en, this message translates to:
  /// **'Avg Order Value'**
  String get avgOrderValue;

  /// Revenue by period chart title
  ///
  /// In en, this message translates to:
  /// **'Revenue by Period'**
  String get revenueByPeriod;

  /// Top products section title
  ///
  /// In en, this message translates to:
  /// **'Top Products'**
  String get topProducts;

  /// Sales trend chart title
  ///
  /// In en, this message translates to:
  /// **'Sales Trend'**
  String get salesTrend;

  /// Product name column header
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productName;

  /// Units sold column header
  ///
  /// In en, this message translates to:
  /// **'Units Sold'**
  String get unitsSold;

  /// Profit column header
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get profit;

  /// Report date column header
  ///
  /// In en, this message translates to:
  /// **'Report Date'**
  String get reportDate;

  /// Period label
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// Amount label
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// Egyptian Pound currency symbol
  ///
  /// In en, this message translates to:
  /// **'LE'**
  String get leEgp;

  /// Loading message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Revised status
  ///
  /// In en, this message translates to:
  /// **'Revised'**
  String get revised;

  /// Rejected status
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// Apply button text
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// Analytics tab label
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// Performance tab label
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get performance;

  /// Report information section title
  ///
  /// In en, this message translates to:
  /// **'Report Information'**
  String get reportInformation;

  /// Total deliveries label
  ///
  /// In en, this message translates to:
  /// **'Total Deliveries'**
  String get totalDeliveries;

  /// Report ID label
  ///
  /// In en, this message translates to:
  /// **'Report ID'**
  String get reportId;

  /// Yes confirmation text
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// Sold units label
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get sold;

  /// Rating label
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// Clear filter button text
  ///
  /// In en, this message translates to:
  /// **'Clear Filter'**
  String get clearFilter;

  /// All reports filter option
  ///
  /// In en, this message translates to:
  /// **'All Reports'**
  String get allReports;

  /// No reports available message
  ///
  /// In en, this message translates to:
  /// **'No reports available'**
  String get noReportsAvailable;

  /// No product performance data message
  ///
  /// In en, this message translates to:
  /// **'No product performance data available'**
  String get noProductPerformanceData;

  /// Product performance section title
  ///
  /// In en, this message translates to:
  /// **'Product Performance'**
  String get productPerformanceTitle;

  /// Reports list section title
  ///
  /// In en, this message translates to:
  /// **'Reports List'**
  String get reportsListTitle;

  /// Reports summary section title
  ///
  /// In en, this message translates to:
  /// **'Reports Summary'**
  String get reportsSummary;

  /// Units suffix
  ///
  /// In en, this message translates to:
  /// **'units'**
  String get units;

  /// Mart information section title
  ///
  /// In en, this message translates to:
  /// **'Mart Information'**
  String get martInfo;

  /// Mart name field label
  ///
  /// In en, this message translates to:
  /// **'Mart Name'**
  String get martName;

  /// Editable data section title
  ///
  /// In en, this message translates to:
  /// **'Editable Data'**
  String get editableData;

  /// Name field validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterName;

  /// Phone number field validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get pleaseEnterPhoneNumber;

  /// Update data button text
  ///
  /// In en, this message translates to:
  /// **'Update Data'**
  String get updateData;

  /// Personal info update subtitle
  ///
  /// In en, this message translates to:
  /// **'Update your personal information'**
  String get updateYourPersonalInfo;

  /// Profile page title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Enter placeholder prefix
  ///
  /// In en, this message translates to:
  /// **'Enter'**
  String get enter;

  /// Admin reports page title
  ///
  /// In en, this message translates to:
  /// **'Admin Reports'**
  String get adminReports;

  /// Entity type filter label
  ///
  /// In en, this message translates to:
  /// **'Entity Type'**
  String get entityType;

  /// Start date filter label
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// End date filter label
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// Generate weekly reports title
  ///
  /// In en, this message translates to:
  /// **'Generate Weekly Reports'**
  String get generateWeeklyReports;

  /// Automated report generation subtitle
  ///
  /// In en, this message translates to:
  /// **'Automated Report Generation'**
  String get automatedReportGeneration;

  /// Generate current week button
  ///
  /// In en, this message translates to:
  /// **'Generate Current Week'**
  String get generateCurrentWeek;

  /// Custom date range button
  ///
  /// In en, this message translates to:
  /// **'Custom Date Range'**
  String get customDateRange;

  /// Recent generation jobs title
  ///
  /// In en, this message translates to:
  /// **'Recent Generation Jobs'**
  String get recentGenerationJobs;

  /// Report type breakdown title
  ///
  /// In en, this message translates to:
  /// **'Report Type Breakdown'**
  String get reportTypeBreakdown;

  /// No recent reports message
  ///
  /// In en, this message translates to:
  /// **'No recent reports available'**
  String get noRecentReportsAvailable;

  /// Resolve button text
  ///
  /// In en, this message translates to:
  /// **'Resolve'**
  String get resolve;

  /// Weekly reports generated notification title
  ///
  /// In en, this message translates to:
  /// **'Weekly Reports Generated'**
  String get weeklyReportsGenerated;

  /// All entities processed message
  ///
  /// In en, this message translates to:
  /// **'All entities processed'**
  String get allEntitiesProcessed;

  /// Started generating reports message
  ///
  /// In en, this message translates to:
  /// **'Started generating reports for current week...'**
  String get startedGeneratingReports;

  /// Generate reports dialog title
  ///
  /// In en, this message translates to:
  /// **'Generate Reports'**
  String get generateReports;

  /// Top restaurants section
  ///
  /// In en, this message translates to:
  /// **'Top Restaurants'**
  String get topRestaurants;

  /// Revenue breakdown section
  ///
  /// In en, this message translates to:
  /// **'Revenue Breakdown'**
  String get revenueBreakdown;

  /// Orders by status section
  ///
  /// In en, this message translates to:
  /// **'Orders by Status'**
  String get ordersByStatus;

  /// Hourly breakdown section
  ///
  /// In en, this message translates to:
  /// **'Hourly Breakdown'**
  String get hourlyBreakdown;

  /// Restaurants summary section
  ///
  /// In en, this message translates to:
  /// **'Restaurants Summary'**
  String get restaurantsSummary;

  /// Top performers section
  ///
  /// In en, this message translates to:
  /// **'Top Performers'**
  String get topPerformers;

  /// Category performance section
  ///
  /// In en, this message translates to:
  /// **'Category Performance'**
  String get categoryPerformance;

  /// Customers summary section
  ///
  /// In en, this message translates to:
  /// **'Customers Summary'**
  String get customersSummary;

  /// Top customers section
  ///
  /// In en, this message translates to:
  /// **'Top Customers'**
  String get topCustomers;

  /// New customers metric
  ///
  /// In en, this message translates to:
  /// **'New Customers'**
  String get newCustomers;

  /// Active customers metric
  ///
  /// In en, this message translates to:
  /// **'Active Customers'**
  String get activeCustomers;

  /// Total customers metric
  ///
  /// In en, this message translates to:
  /// **'Total Customers'**
  String get totalCustomers;

  /// Reports count with placeholder
  ///
  /// In en, this message translates to:
  /// **'{count} reports'**
  String reportsCount(int count);

  /// Generate tab title
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generate;

  /// Restaurant entity type
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get restaurant;

  /// Mart entity type
  ///
  /// In en, this message translates to:
  /// **'Mart'**
  String get mart;

  /// Delivery entity type
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// Empty reports message title
  ///
  /// In en, this message translates to:
  /// **'No reports found'**
  String get noReportsFound;

  /// Empty reports message subtitle
  ///
  /// In en, this message translates to:
  /// **'No weekly reports available for the selected criteria'**
  String get noWeeklyReportsAvailable;

  /// Platform earnings title
  ///
  /// In en, this message translates to:
  /// **'Platform Earnings'**
  String get platformEarnings;

  /// Business earnings title
  ///
  /// In en, this message translates to:
  /// **'Business Earnings'**
  String get businessEarnings;

  /// Pending reports title
  ///
  /// In en, this message translates to:
  /// **'Pending Reports'**
  String get pendingReports;

  /// Total reports title
  ///
  /// In en, this message translates to:
  /// **'Total Reports'**
  String get totalReports;

  /// Confirmed reports title
  ///
  /// In en, this message translates to:
  /// **'Confirmed Reports'**
  String get confirmedReports;

  /// Disputed reports title
  ///
  /// In en, this message translates to:
  /// **'Disputed Reports'**
  String get disputedReports;

  /// Running jobs title
  ///
  /// In en, this message translates to:
  /// **'Running Jobs'**
  String get runningJobs;

  /// Automated reports explanation
  ///
  /// In en, this message translates to:
  /// **'Reports are automatically generated every Monday for the previous week. You can also manually trigger generation for specific date ranges.'**
  String get reportsAutomaticallyGenerated;

  /// Dashboard error message
  ///
  /// In en, this message translates to:
  /// **'Error loading dashboard'**
  String get errorLoadingDashboard;

  /// Week label
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No recent reports title
  ///
  /// In en, this message translates to:
  /// **'No recent reports'**
  String get noRecentReports;

  /// No recent reports subtitle
  ///
  /// In en, this message translates to:
  /// **'Reports will appear here once generated'**
  String get reportsWillAppearHere;

  /// Week of label
  ///
  /// In en, this message translates to:
  /// **'Week of'**
  String get weekOf;

  /// Week start date selection instruction
  ///
  /// In en, this message translates to:
  /// **'Select week start date for report generation:'**
  String get selectWeekStartDate;

  /// Select date placeholder
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// Date selection required message
  ///
  /// In en, this message translates to:
  /// **'Please select a date first'**
  String get pleaseSelectDateFirst;

  /// Tab title for profit and loss report
  ///
  /// In en, this message translates to:
  /// **'Profit & Loss'**
  String get profitAndLoss;

  /// Card title for profit and loss summary
  ///
  /// In en, this message translates to:
  /// **'Profit & Loss Summary'**
  String get profitAndLossSummary;

  /// Label for profit and loss reporting period
  ///
  /// In en, this message translates to:
  /// **'Reporting Period'**
  String get reportingPeriod;

  /// Total discount applied to delivered orders
  ///
  /// In en, this message translates to:
  /// **'Discount Given'**
  String get discountGiven;

  /// Cost of goods sold label
  ///
  /// In en, this message translates to:
  /// **'Cost of Goods Sold'**
  String get costOfGoodsSold;

  /// Gross profit label
  ///
  /// In en, this message translates to:
  /// **'Gross Profit'**
  String get grossProfit;

  /// Inventory purchases total label
  ///
  /// In en, this message translates to:
  /// **'Inventory Purchases'**
  String get inventoryPurchases;

  /// Purchase invoice total value label
  ///
  /// In en, this message translates to:
  /// **'Purchase Value'**
  String get purchaseValue;

  /// Net profit label
  ///
  /// In en, this message translates to:
  /// **'Net Profit'**
  String get netProfit;

  /// Average margin percentage label
  ///
  /// In en, this message translates to:
  /// **'Average Order Margin'**
  String get averageOrderMargin;

  /// Number of invoices included in profit and loss
  ///
  /// In en, this message translates to:
  /// **'Invoice Count'**
  String get invoiceCount;

  /// Number of delivered items included in profit and loss
  ///
  /// In en, this message translates to:
  /// **'Delivered Item Count'**
  String get deliveredItemCount;

  /// Section title for sales breakdown in profit and loss
  ///
  /// In en, this message translates to:
  /// **'Sales Breakdown'**
  String get salesBreakdown;

  /// Sales channel label for online orders
  ///
  /// In en, this message translates to:
  /// **'Orders Channel'**
  String get ordersChannel;

  /// Sales channel label for cashier orders
  ///
  /// In en, this message translates to:
  /// **'Cashier Channel'**
  String get cashierChannel;

  /// Report generation started message with date
  ///
  /// In en, this message translates to:
  /// **'Started generating reports for week of {date}...'**
  String startedGeneratingReportsForWeek(String date);

  /// No description provided for @topPerformingRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Top Performing Restaurants'**
  String get topPerformingRestaurants;

  /// No description provided for @recentReportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Dec 2-8, 2024 • All entities processed'**
  String get recentReportSubtitle;

  /// No description provided for @revenueAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Revenue Analytics'**
  String get revenueAnalytics;

  /// No description provided for @orderAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Order Analytics'**
  String get orderAnalytics;

  /// No description provided for @restaurantPerformance.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Performance'**
  String get restaurantPerformance;

  /// No description provided for @customerAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Customer Analytics'**
  String get customerAnalytics;

  /// Mart management page title
  ///
  /// In en, this message translates to:
  /// **'Mart Management'**
  String get martManagement;

  /// Mart management page subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage marts, staff, and operations across zones'**
  String get martManagementSubtitle;

  /// Add mart button text
  ///
  /// In en, this message translates to:
  /// **'Add Mart'**
  String get addMart;

  /// Edit mart button text
  ///
  /// In en, this message translates to:
  /// **'Edit Mart'**
  String get editMart;

  /// Delete mart button text
  ///
  /// In en, this message translates to:
  /// **'Delete Mart'**
  String get deleteMart;

  /// Search marts placeholder
  ///
  /// In en, this message translates to:
  /// **'Search marts...'**
  String get searchMarts;

  /// Filter marts by zone label
  ///
  /// In en, this message translates to:
  /// **'Filter by Zone'**
  String get filterMartsByZone;

  /// Filter marts by status label
  ///
  /// In en, this message translates to:
  /// **'Filter by Status'**
  String get filterMartsByStatus;

  /// Active marts filter option
  ///
  /// In en, this message translates to:
  /// **'Active Marts'**
  String get activeMarts;

  /// Inactive marts filter option
  ///
  /// In en, this message translates to:
  /// **'Inactive Marts'**
  String get inactiveMarts;

  /// All mart statuses filter option
  ///
  /// In en, this message translates to:
  /// **'All Statuses'**
  String get allMartStatuses;

  /// No marts found message
  ///
  /// In en, this message translates to:
  /// **'No marts found'**
  String get noMartsFound;

  /// Loading marts message
  ///
  /// In en, this message translates to:
  /// **'Loading marts...'**
  String get loadingMarts;

  /// Error loading marts message
  ///
  /// In en, this message translates to:
  /// **'Error loading marts'**
  String get errorLoadingMarts;

  /// Mart details dialog title
  ///
  /// In en, this message translates to:
  /// **'Mart Details'**
  String get martDetails;

  /// Mart information section
  ///
  /// In en, this message translates to:
  /// **'Mart Information'**
  String get martInformation;

  /// Mart name field placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter mart name'**
  String get enterMartName;

  /// Mart name validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter mart name'**
  String get pleaseEnterMartName;

  /// Mart location field label
  ///
  /// In en, this message translates to:
  /// **'Mart Location'**
  String get martLocation;

  /// Mart location field placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter mart location'**
  String get enterMartLocation;

  /// Mart location validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter mart location'**
  String get pleaseEnterMartLocation;

  /// Mart phone field label
  ///
  /// In en, this message translates to:
  /// **'Mart Phone'**
  String get martPhone;

  /// Mart phone field placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter mart phone'**
  String get enterMartPhone;

  /// Mart phone validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter mart phone'**
  String get pleaseEnterMartPhone;

  /// Mart email field label
  ///
  /// In en, this message translates to:
  /// **'Mart Email'**
  String get martEmail;

  /// Mart email field placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter mart email'**
  String get enterMartEmail;

  /// Mart email validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter mart email'**
  String get pleaseEnterMartEmail;

  /// Mart email format validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidMartEmail;

  /// Mart zone field label
  ///
  /// In en, this message translates to:
  /// **'Mart Zone'**
  String get martZone;

  /// Mart zone field placeholder
  ///
  /// In en, this message translates to:
  /// **'Select mart zone'**
  String get selectMartZone;

  /// Mart zone validation error
  ///
  /// In en, this message translates to:
  /// **'Please select a zone'**
  String get pleaseSelectMartZone;

  /// Mart description field label
  ///
  /// In en, this message translates to:
  /// **'Mart Description'**
  String get martDescription;

  /// Mart description field placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter mart description'**
  String get enterMartDescription;

  /// Mart coordinates section
  ///
  /// In en, this message translates to:
  /// **'Mart Coordinates'**
  String get martCoordinates;

  /// Mart latitude field placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter latitude'**
  String get enterMartLatitude;

  /// Mart longitude field placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter longitude'**
  String get enterMartLongitude;

  /// Mart latitude validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid latitude'**
  String get pleaseEnterValidLatitude;

  /// Mart longitude validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid longitude'**
  String get pleaseEnterValidLongitude;

  /// Mart operating hours section
  ///
  /// In en, this message translates to:
  /// **'Operating Hours'**
  String get martOperatingHours;

  /// Open all day option
  ///
  /// In en, this message translates to:
  /// **'Open 24/7'**
  String get openAllDay;

  /// Custom hours option
  ///
  /// In en, this message translates to:
  /// **'Custom Hours'**
  String get customHours;

  /// Monday to Friday label
  ///
  /// In en, this message translates to:
  /// **'Monday to Friday'**
  String get mondayToFriday;

  /// Weekends label
  ///
  /// In en, this message translates to:
  /// **'Weekends'**
  String get weekends;

  /// Monday day name
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// Tuesday day name
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// Wednesday day name
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// Thursday day name
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// Friday day name
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// Saturday day name
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// Sunday day name
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// Closed status
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// Create mart button text
  ///
  /// In en, this message translates to:
  /// **'Create Mart'**
  String get createMart;

  /// Update mart button text
  ///
  /// In en, this message translates to:
  /// **'Update Mart'**
  String get updateMart;

  /// Mart created success message
  ///
  /// In en, this message translates to:
  /// **'Mart created successfully'**
  String get martCreatedSuccessfully;

  /// Mart updated success message
  ///
  /// In en, this message translates to:
  /// **'Mart updated successfully'**
  String get martUpdatedSuccessfully;

  /// Mart deleted success message
  ///
  /// In en, this message translates to:
  /// **'Mart deleted successfully'**
  String get martDeletedSuccessfully;

  /// Confirm delete mart message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this mart?'**
  String get confirmDeleteMart;

  /// Cannot delete mart error message
  ///
  /// In en, this message translates to:
  /// **'Cannot delete mart with existing orders'**
  String get cannotDeleteMartWithOrders;

  /// Toggle mart status button text
  ///
  /// In en, this message translates to:
  /// **'Toggle Mart Status'**
  String get toggleMartStatus;

  /// Activate mart button text
  ///
  /// In en, this message translates to:
  /// **'Activate Mart'**
  String get activateMart;

  /// Deactivate mart button text
  ///
  /// In en, this message translates to:
  /// **'Deactivate Mart'**
  String get deactivateMart;

  /// Mart status updated success message
  ///
  /// In en, this message translates to:
  /// **'Mart status updated successfully'**
  String get martStatusUpdated;

  /// Mart staff management section
  ///
  /// In en, this message translates to:
  /// **'Staff Management'**
  String get martStaffManagement;

  /// Add mart staff button text
  ///
  /// In en, this message translates to:
  /// **'Add Staff'**
  String get addMartStaff;

  /// Manage mart staff button text
  ///
  /// In en, this message translates to:
  /// **'Manage Staff'**
  String get manageMartStaff;

  /// Mart staff section title
  ///
  /// In en, this message translates to:
  /// **'Mart Staff'**
  String get martStaff;

  /// No mart staff found message
  ///
  /// In en, this message translates to:
  /// **'No staff found'**
  String get noMartStaffFound;

  /// Staff name field label
  ///
  /// In en, this message translates to:
  /// **'Staff Name'**
  String get staffName;

  /// Staff name field placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter staff name'**
  String get enterStaffName;

  /// Staff name validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter staff name'**
  String get pleaseEnterStaffName;

  /// Staff email field label
  ///
  /// In en, this message translates to:
  /// **'Staff Email'**
  String get staffEmail;

  /// Staff email field placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter staff email'**
  String get enterStaffEmail;

  /// Staff email validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter staff email'**
  String get pleaseEnterStaffEmail;

  /// Staff email format validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidStaffEmail;

  /// Staff phone field label
  ///
  /// In en, this message translates to:
  /// **'Staff Phone'**
  String get staffPhone;

  /// Staff phone field placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter staff phone'**
  String get enterStaffPhone;

  /// Staff phone validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter staff phone'**
  String get pleaseEnterStaffPhone;

  /// Staff password field label
  ///
  /// In en, this message translates to:
  /// **'Staff Password'**
  String get staffPassword;

  /// Staff password field placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter staff password'**
  String get enterStaffPassword;

  /// Staff password validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter staff password'**
  String get pleaseEnterStaffPassword;

  /// Staff role field label
  ///
  /// In en, this message translates to:
  /// **'Staff Role'**
  String get staffRole;

  /// Staff role field placeholder
  ///
  /// In en, this message translates to:
  /// **'Select staff role'**
  String get selectStaffRole;

  /// Staff role validation error
  ///
  /// In en, this message translates to:
  /// **'Please select a staff role'**
  String get pleaseSelectStaffRole;

  /// Mart admin role
  ///
  /// In en, this message translates to:
  /// **'Mart Admin'**
  String get martAdmin;

  /// Mart operator role
  ///
  /// In en, this message translates to:
  /// **'Mart Operator'**
  String get martOperator;

  /// Create staff button text
  ///
  /// In en, this message translates to:
  /// **'Create Staff'**
  String get createStaff;

  /// Staff created success message
  ///
  /// In en, this message translates to:
  /// **'Staff created successfully'**
  String get staffCreatedSuccessfully;

  /// Staff removed success message
  ///
  /// In en, this message translates to:
  /// **'Staff removed successfully'**
  String get staffRemovedSuccessfully;

  /// Confirm remove staff message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this staff member?'**
  String get confirmRemoveStaff;

  /// Remove staff button text
  ///
  /// In en, this message translates to:
  /// **'Remove Staff'**
  String get removeStaff;

  /// Toggle staff status button text
  ///
  /// In en, this message translates to:
  /// **'Toggle Status'**
  String get toggleStaffStatus;

  /// Staff status updated success message
  ///
  /// In en, this message translates to:
  /// **'Staff status updated successfully'**
  String get staffStatusUpdated;

  /// Last login label
  ///
  /// In en, this message translates to:
  /// **'Last Login'**
  String get lastLogin;

  /// Never logged in status
  ///
  /// In en, this message translates to:
  /// **'Never logged in'**
  String get neverLoggedIn;

  /// Mart performance section
  ///
  /// In en, this message translates to:
  /// **'Mart Performance'**
  String get martPerformance;

  /// View mart performance button text
  ///
  /// In en, this message translates to:
  /// **'View Performance'**
  String get viewMartPerformance;

  /// Mart analytics section
  ///
  /// In en, this message translates to:
  /// **'Mart Analytics'**
  String get martAnalytics;

  /// Total mart revenue label
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get totalMartRevenue;

  /// Total mart orders label
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get totalMartOrders;

  /// Total mart products label
  ///
  /// In en, this message translates to:
  /// **'Total Products'**
  String get totalMartProducts;

  /// Active mart products label
  ///
  /// In en, this message translates to:
  /// **'Active Products'**
  String get activeMartProducts;

  /// Total mart staff label
  ///
  /// In en, this message translates to:
  /// **'Total Staff'**
  String get totalMartStaff;

  /// Average mart order value label
  ///
  /// In en, this message translates to:
  /// **'Average Order Value'**
  String get averageMartOrderValue;

  /// Today's orders label
  ///
  /// In en, this message translates to:
  /// **'Today\'s Orders'**
  String get todayOrders;

  /// Today's revenue label
  ///
  /// In en, this message translates to:
  /// **'Today\'s Revenue'**
  String get todayRevenue;

  /// Top mart products section
  ///
  /// In en, this message translates to:
  /// **'Top Products'**
  String get topMartProducts;

  /// Sold quantity label
  ///
  /// In en, this message translates to:
  /// **'Sold Quantity'**
  String get soldQuantity;

  /// Product revenue label
  ///
  /// In en, this message translates to:
  /// **'Product Revenue'**
  String get productRevenue;

  /// Marts by zone section
  ///
  /// In en, this message translates to:
  /// **'Marts by Zone'**
  String get martsByZone;

  /// View marts by zone button text
  ///
  /// In en, this message translates to:
  /// **'View by Zone'**
  String get viewMartsByZone;

  /// Top performing marts section
  ///
  /// In en, this message translates to:
  /// **'Top Performing Marts'**
  String get topPerformingMarts;

  /// View top marts button text
  ///
  /// In en, this message translates to:
  /// **'View Top Marts'**
  String get viewTopMarts;

  /// Daily performance label
  ///
  /// In en, this message translates to:
  /// **'Daily Performance'**
  String get dailyPerformance;

  /// Weekly performance label
  ///
  /// In en, this message translates to:
  /// **'Weekly Performance'**
  String get weeklyPerformance;

  /// Monthly performance label
  ///
  /// In en, this message translates to:
  /// **'Monthly Performance'**
  String get monthlyPerformance;

  /// Select performance period placeholder
  ///
  /// In en, this message translates to:
  /// **'Select period'**
  String get selectPerformancePeriod;

  /// Performance chart title
  ///
  /// In en, this message translates to:
  /// **'Performance Chart'**
  String get performanceChart;

  /// Revenue chart title
  ///
  /// In en, this message translates to:
  /// **'Revenue Chart'**
  String get revenueChart;

  /// Orders chart title
  ///
  /// In en, this message translates to:
  /// **'Orders Chart'**
  String get ordersChart;

  /// Export mart data button text
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportMartData;

  /// Refresh mart data button text
  ///
  /// In en, this message translates to:
  /// **'Refresh Data'**
  String get refreshMartData;

  /// Mart settings section
  ///
  /// In en, this message translates to:
  /// **'Mart Settings'**
  String get martSettings;

  /// Operating status label
  ///
  /// In en, this message translates to:
  /// **'Operating Status'**
  String get operatingStatus;

  /// Mart active status description
  ///
  /// In en, this message translates to:
  /// **'Mart is active and accepting orders'**
  String get martIsActive;

  /// Mart inactive status description
  ///
  /// In en, this message translates to:
  /// **'Mart is inactive and not accepting orders'**
  String get martIsInactive;

  /// Created on label
  ///
  /// In en, this message translates to:
  /// **'Created On'**
  String get createdOn;

  /// Last updated on label
  ///
  /// In en, this message translates to:
  /// **'Last Updated On'**
  String get lastUpdatedOn;

  /// Clear mart filters button text
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearMartFilters;

  /// Apply mart filters button text
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyMartFilters;

  /// Select date range label
  ///
  /// In en, this message translates to:
  /// **'Select Date Range'**
  String get selectDateRange;

  /// From date label
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// To date label
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// Error creating mart message
  ///
  /// In en, this message translates to:
  /// **'Error creating mart'**
  String get errorCreatingMart;

  /// Error updating mart message
  ///
  /// In en, this message translates to:
  /// **'Error updating mart'**
  String get errorUpdatingMart;

  /// Error deleting mart message
  ///
  /// In en, this message translates to:
  /// **'Error deleting mart'**
  String get errorDeletingMart;

  /// Error loading mart staff message
  ///
  /// In en, this message translates to:
  /// **'Error loading mart staff'**
  String get errorLoadingMartStaff;

  /// Error creating staff message
  ///
  /// In en, this message translates to:
  /// **'Error creating staff'**
  String get errorCreatingStaff;

  /// Error removing staff message
  ///
  /// In en, this message translates to:
  /// **'Error removing staff'**
  String get errorRemovingStaff;

  /// Error loading mart performance message
  ///
  /// In en, this message translates to:
  /// **'Error loading mart performance'**
  String get errorLoadingMartPerformance;

  /// Retry loading marts button text
  ///
  /// In en, this message translates to:
  /// **'Retry Loading Marts'**
  String get retryLoadingMarts;

  /// Showing marts pagination text
  ///
  /// In en, this message translates to:
  /// **'Showing {current} of {total} marts'**
  String showingMarts(int current, int total);

  /// Basic information section title
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// Contact information section title
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// Email validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter email address'**
  String get pleaseEnterEmail;

  /// Email format validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterValidEmail;

  /// Address validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter address'**
  String get pleaseEnterAddress;

  /// Zones tab title
  ///
  /// In en, this message translates to:
  /// **'Zones'**
  String get zones;

  /// Vehicle table header
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get vehicle;

  /// Delivery man table header
  ///
  /// In en, this message translates to:
  /// **'Delivery Man'**
  String get deliveryMan;

  /// Online status
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// Offline status
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No zone assigned text
  ///
  /// In en, this message translates to:
  /// **'No zone'**
  String get noZone;

  /// Not available abbreviation
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// Assign zone menu item
  ///
  /// In en, this message translates to:
  /// **'Assign Zone'**
  String get assignZone;

  /// View analytics menu item
  ///
  /// In en, this message translates to:
  /// **'View Analytics'**
  String get viewAnalytics;

  /// Pagination showing text
  ///
  /// In en, this message translates to:
  /// **'Showing {count} of {total} delivery men'**
  String showingDeliveryMen(int count, int total);

  /// Settlement management page title
  ///
  /// In en, this message translates to:
  /// **'Settlement Management'**
  String get settlementManagement;

  /// Settlement management page subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage and download individual settlement reports'**
  String get settlementManagementSubtitle;

  /// Download all settlement reports button
  ///
  /// In en, this message translates to:
  /// **'Download All Reports'**
  String get downloadAllReports;

  /// Download individual settlement reports button
  ///
  /// In en, this message translates to:
  /// **'Download Individual Reports'**
  String get downloadIndividualReports;

  /// Select date label for settlements
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get settlementSelectDate;

  /// Today's reports button
  ///
  /// In en, this message translates to:
  /// **'Today\'s Reports'**
  String get todaysReports;

  /// Vendor reports section title
  ///
  /// In en, this message translates to:
  /// **'Vendor Reports'**
  String get vendorReports;

  /// Delivery man reports section title
  ///
  /// In en, this message translates to:
  /// **'Delivery Man Reports'**
  String get deliveryManReports;

  /// System revenue report section title
  ///
  /// In en, this message translates to:
  /// **'System Revenue Report'**
  String get systemRevenueReport;

  /// Downloading reports loading message
  ///
  /// In en, this message translates to:
  /// **'Downloading Reports...'**
  String get downloadingReports;

  /// Reports download success message
  ///
  /// In en, this message translates to:
  /// **'Reports downloaded successfully'**
  String get reportsDownloadSuccess;

  /// Reports download error message
  ///
  /// In en, this message translates to:
  /// **'Error downloading reports'**
  String get reportsDownloadError;

  /// Generate settlement reports button
  ///
  /// In en, this message translates to:
  /// **'Generate Reports'**
  String get settlementGenerateReports;

  /// Settlement date label
  ///
  /// In en, this message translates to:
  /// **'Settlement Date'**
  String get settlementDate;

  /// Total vendors count label
  ///
  /// In en, this message translates to:
  /// **'Total Vendors'**
  String get totalVendors;

  /// Total delivery men count label
  ///
  /// In en, this message translates to:
  /// **'Total Delivery Men'**
  String get totalDeliveryMen;

  /// Total transactions count label
  ///
  /// In en, this message translates to:
  /// **'Total Transactions'**
  String get totalTransactions;

  /// System commission label
  ///
  /// In en, this message translates to:
  /// **'System Commission'**
  String get systemCommission;

  /// Settlement summary section title
  ///
  /// In en, this message translates to:
  /// **'Settlement Summary'**
  String get settlementSummary;

  /// Overall summary section title
  ///
  /// In en, this message translates to:
  /// **'Overall Summary'**
  String get overallSummary;

  /// Marts summary section title
  ///
  /// In en, this message translates to:
  /// **'Marts Summary'**
  String get martsSummary;

  /// Total subtotal label
  ///
  /// In en, this message translates to:
  /// **'Total Subtotal'**
  String get totalSubtotal;

  /// Message when no settlement date is selected
  ///
  /// In en, this message translates to:
  /// **'Select a date to view settlement information'**
  String get selectDateToViewSettlement;

  /// Description for download all reports button
  ///
  /// In en, this message translates to:
  /// **'Download comprehensive settlement reports for all entities'**
  String get downloadComprehensiveReports;

  /// More button text for navigation dropdown
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
