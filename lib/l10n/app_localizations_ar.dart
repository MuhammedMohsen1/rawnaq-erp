// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'بوابة بين إيديك';

  @override
  String get welcomeBack => 'أهلاً بعودتك!';

  @override
  String get signInToRestaurantPortal => 'سجل دخولك إلى بوابة المطعم';

  @override
  String get emailAddress => 'البريد الإلكتروني';

  @override
  String get enterYourEmail => 'أدخل بريدك الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get enterYourPassword => 'أدخل كلمة المرور';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get needHelp => 'تحتاج مساعدة؟ تواصل مع مدير النظام';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirmLogout => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get dashboardOverview => 'نظرة عامة على لوحة التحكم';

  @override
  String get dashboardWelcomeMessage =>
      'أهلاً بعودتك! إليك ما يحدث في مطعمك اليوم.';

  @override
  String get todaysOrders => 'طلبات اليوم';

  @override
  String get revenue => 'الإيرادات';

  @override
  String get pendingOrders => 'الطلبات المعلقة';

  @override
  String get menuItems => 'عناصر القائمة';

  @override
  String get revenueTrend => 'اتجاه الإيرادات';

  @override
  String get ordersOverview => 'نظرة عامة على الطلبات';

  @override
  String get recentActivities => 'الأنشطة الحديثة';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String newOrderReceived(String orderId) {
    return 'تم استلام طلب جديد رقم $orderId';
  }

  @override
  String menuItemUpdated(String itemName) {
    return 'تم تحديث عنصر القائمة \"$itemName\"';
  }

  @override
  String orderCompleted(String orderId) {
    return 'تم إكمال الطلب رقم $orderId';
  }

  @override
  String newReviewReceived(int stars) {
    return 'تم استلام تقييم جديد ($stars نجوم)';
  }

  @override
  String paymentReceived(String orderId) {
    return 'تم استلام الدفع للطلب رقم $orderId';
  }

  @override
  String get foodManagement => 'إدارة الطعام';

  @override
  String get categories => 'التصنيفات';

  @override
  String get orders => 'الطلبات';

  @override
  String get pickupManagement => 'إدارة الاستلام';

  @override
  String get reviews => 'التقييمات';

  @override
  String get workingHours => 'ساعات العمل';

  @override
  String get restaurantProfile => 'ملف المطعم';

  @override
  String get userAccess => 'صلاحيات المستخدمين';

  @override
  String get reports => 'التقارير';

  @override
  String get deactivateRestaurant => 'إلغاء تفعيل المطعم';

  @override
  String get restaurantPortal => 'بوابة المطعم';

  @override
  String get managementSystem => 'نظام الإدارة';

  @override
  String get menuManagement => 'إدارة عناصر الطعام وقائمة الطعام الخاصة بمطعمك';

  @override
  String get orderManagement => 'إدارة الطلبات';

  @override
  String get orderManagementSubtitle => 'تتبع وادارة جميع طلبات العملاء';

  @override
  String get categoryManagement => 'إدارة التصنيفات';

  @override
  String get advertisementManagement => 'إدارة الإعلانات';

  @override
  String get pendingApproval => 'في انتظار الموافقة';

  @override
  String get pricingTiers => 'طبقات التسعير';

  @override
  String get noPendingAdvertisements => 'لا توجد إعلانات معلقة';

  @override
  String get vendor => 'البائع';

  @override
  String get approve => 'موافقة';

  @override
  String get approveAdvertisement => 'الموافقة على الإعلان';

  @override
  String get rejectAdvertisement => 'رفض الإعلان';

  @override
  String get approveConfirmation => 'هل أنت متأكد من الموافقة على هذا الإعلان؟';

  @override
  String get rejectionReasonPrompt => 'يرجى تقديم سبب الرفض:';

  @override
  String get rejectionReason => 'سبب الرفض';

  @override
  String get rejectionReasonHint => 'أدخل سبب الرفض';

  @override
  String get pricingTiersManagement => 'إدارة طبقات التسعير';

  @override
  String get configurePricingTiers => 'تكوين طبقات تسعير الإعلانات';

  @override
  String get loadPricingTiers => 'تحميل طبقات التسعير';

  @override
  String get advertisementAnalytics => 'تحليلات الإعلانات';

  @override
  String get performanceMetrics => 'عرض مقاييس الأداء والرؤى';

  @override
  String get loadAnalytics => 'تحميل التحليلات';

  @override
  String get createPricingTier => 'إنشاء مستوى تسعير';

  @override
  String get noPricingTiers => 'لم يتم تكوين مستويات تسعير';

  @override
  String get createFirstPricingTier => 'أنشئ مستوى التسعير الأول للبدء';

  @override
  String get basePrice => 'السعر الأساسي';

  @override
  String get duration => 'المدة';

  @override
  String get multiplier => 'المضاعف';

  @override
  String get createPricingTierTitle => 'إنشاء مستوى تسعير جديد';

  @override
  String get updatePricingTierTitle => 'تحديث مستوى التسعير';

  @override
  String get advertisementType => 'نوع الإعلان';

  @override
  String get selectAdvertisementType => 'اختر نوع الإعلان';

  @override
  String get selectPosition => 'اختر الموضع';

  @override
  String get basePriceHint => 'أدخل السعر الأساسي';

  @override
  String get durationType => 'نوع المدة';

  @override
  String get selectDurationType => 'اختر نوع المدة';

  @override
  String get multiplierHint => 'أدخل المضاعف (افتراضي: 1.0)';

  @override
  String get deletePricingTierTitle => 'حذف مستوى التسعير';

  @override
  String get deletePricingTierConfirmation =>
      'هل أنت متأكد من أنك تريد حذف مستوى التسعير هذا؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get createAdvertisement => 'إنشاء إعلان';

  @override
  String get createNewAdvertisement => 'إنشاء إعلان جديد';

  @override
  String get advertisementTitle => 'عنوان الإعلان';

  @override
  String get enterAdvertisementTitle => 'أدخل عنوان الإعلان';

  @override
  String get advertisementDescription => 'وصف الإعلان';

  @override
  String get enterAdvertisementDescription => 'أدخل وصف الإعلان';

  @override
  String get advertisementImageUrl => 'رابط صورة الإعلان';

  @override
  String get enterAdvertisementImageUrl => 'أدخل رابط صورة الإعلان';

  @override
  String get targetUrl => 'الرابط المستهدف';

  @override
  String get enterTargetUrl => 'أدخل الرابط المستهدف';

  @override
  String get adStartDate => 'تاريخ البداية';

  @override
  String get adEndDate => 'تاريخ النهاية';

  @override
  String get selectAdStartDate => 'اختر تاريخ البداية';

  @override
  String get selectAdEndDate => 'اختر تاريخ النهاية';

  @override
  String get totalCost => 'التكلفة الإجمالية';

  @override
  String get createAdvertisementButton => 'إنشاء الإعلان';

  @override
  String get advertisementDetails => 'تفاصيل الإعلان';

  @override
  String get placementConfiguration => 'إعداد الموضع';

  @override
  String get campaignDuration => 'مدة الحملة';

  @override
  String get costCalculation => 'حساب التكلفة';

  @override
  String get advertisementTitleRequired => 'عنوان الإعلان مطلوب';

  @override
  String get advertisementDescriptionRequired => 'وصف الإعلان مطلوب';

  @override
  String get imageUrlRequired => 'رابط الصورة مطلوب';

  @override
  String get validImageUrlRequired => 'يرجى إدخال رابط صورة صحيح';

  @override
  String get targetUrlRequired => 'الرابط المستهدف مطلوب';

  @override
  String get validTargetUrlRequired => 'يرجى إدخال رابط مستهدف صحيح';

  @override
  String get adStartDateRequired => 'تاريخ البداية مطلوب';

  @override
  String get adEndDateRequired => 'تاريخ النهاية مطلوب';

  @override
  String get endDateMustBeAfterStartDate =>
      'يجب أن يكون تاريخ النهاية بعد تاريخ البداية';

  @override
  String get calculatedCost => 'التكلفة المحسوبة';

  @override
  String get previewAdvertisement => 'معاينة الإعلان';

  @override
  String get advertisementPreview => 'معاينة الإعلان';

  @override
  String get adType => 'نوع الإعلان';

  @override
  String get position => 'الموضع';

  @override
  String get save => 'حفظ';

  @override
  String get no => 'لا';

  @override
  String get noDataAvailable => 'لا توجد بيانات متاحة';

  @override
  String get noOrders => 'لا توجد طلبات';

  @override
  String get noOrdersSubtitle => 'ستظهر الطلبات هنا عند قيام العملاء بطلبها';

  @override
  String get noOrdersFound => 'لا توجد طلبات';

  @override
  String get noPickupOrdersFound => 'لا توجد طلبات استلام';

  @override
  String get noPickupOrdersFoundForSearch => 'لا توجد طلبات استلام لبحثك';

  @override
  String get noPickupOrdersFoundForFilter => 'لا توجد طلبات استلام لهذا المرشح';

  @override
  String get pickupOrdersWillAppearHere => 'ستظهر طلبات الاستلام هنا';

  @override
  String get rejectOrder => 'رفض الطلب';

  @override
  String get estimatedReady => 'الوقت المتوقع للجاهزية';

  @override
  String get itemsText => 'عناصر';

  @override
  String get close => 'إغلاق';

  @override
  String get rejectOrderConfirmation =>
      'هل أنت متأكد من رغبتك في رفض هذا الطلب؟';

  @override
  String get orderID => 'رقم الطلب';

  @override
  String get customer => 'العميل';

  @override
  String get items => 'العناصر';

  @override
  String get total => 'المجموع';

  @override
  String get status => 'الحالة';

  @override
  String get time => 'الوقت';

  @override
  String get actions => 'الإجراءات';

  @override
  String get view => 'عرض';

  @override
  String get viewDetails => 'عرض التفاصيل';

  @override
  String get unauthorized => 'غير مصرح به';

  @override
  String get unauthorizedMessage =>
      'ليس لديك إذن للوصول إلى هذه الصفحة.\nيرجى التواصل مع المدير إذا كنت بحاجة للوصول.';

  @override
  String get goBack => 'العودة';

  @override
  String get searchFoodItems => 'ابحث عن عناصر الطعام...';

  @override
  String get mainCourse => 'الطبق الرئيسي';

  @override
  String get appetizers => 'المقبلات';

  @override
  String get desserts => 'الحلويات';

  @override
  String get beverages => 'المشروبات';

  @override
  String get workingHoursTitle => 'ساعات العمل';

  @override
  String get workingHoursSubtitle => 'إدارة ساعات عمل مطعمك';

  @override
  String get openingTime => 'وقت الافتتاح';

  @override
  String get closingTime => 'وقت الإغلاق';

  @override
  String get selectOpeningTime => 'حدد وقت الافتتاح';

  @override
  String get selectClosingTime => 'حدد وقت الإغلاق';

  @override
  String get updateWorkingHours => 'تحديث ساعات العمل';

  @override
  String get workingHoursUpdated => 'تم تحديث ساعات العمل بنجاح';

  @override
  String get invalidTimeRange => 'يجب أن يكون وقت الإغلاق بعد وقت الافتتاح';

  @override
  String get currentWorkingHours => 'ساعات العمل الحالية';

  @override
  String get restaurantProfileSubtitle => 'إدارة معلومات مطعمك وإعداداته';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get cancelEdit => 'إلغاء';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get restaurantInformation => 'معلومات المطعم';

  @override
  String get basicRestaurantInfo => 'المعلومات الأساسية عن مطعمك';

  @override
  String get restaurantName => 'اسم المطعم';

  @override
  String get enterRestaurantName => 'أدخل اسم المطعم';

  @override
  String get restaurantDescription => 'الوصف';

  @override
  String get pleaseEnterRestaurantName => 'يرجى إدخال اسم المطعم';

  @override
  String get pleaseEnterDescription => 'يرجى إدخال وصف المطعم';

  @override
  String get notSet => 'غير محدد';

  @override
  String get noDescriptionAvailable => 'لا يوجد وصف متاح';

  @override
  String get locationInformation => 'معلومات الموقع';

  @override
  String get restaurantLocationZone => 'موقع المطعم وتفاصيل المنطقة';

  @override
  String get latitude => 'خط العرض';

  @override
  String get longitude => 'خط الطول';

  @override
  String get enterLatitude => 'أدخل خط العرض';

  @override
  String get enterLongitude => 'أدخل خط الطول';

  @override
  String get pleaseEnterLatitude => 'يرجى إدخال خط العرض';

  @override
  String get pleaseEnterLongitude => 'يرجى إدخال خط الطول';

  @override
  String get invalidLatitude => 'خط عرض غير صحيح';

  @override
  String get invalidLongitude => 'خط طول غير صحيح';

  @override
  String get zone => 'المنطقة';

  @override
  String get selectZone => 'اختر المنطقة';

  @override
  String get pleaseSelectZone => 'يرجى اختيار منطقة';

  @override
  String get coordinates => 'الإحداثيات';

  @override
  String get notSelected => 'غير مختار';

  @override
  String get unknownZone => 'منطقة غير معروفة';

  @override
  String get viewOnMap => 'عرض على الخريطة';

  @override
  String get clickToViewLocation => 'انقر لعرض موقع المطعم على الخريطة';

  @override
  String get mapIntegrationComingSoon => 'تكامل الخريطة قريباً!';

  @override
  String get operatingHours => 'ساعات التشغيل';

  @override
  String get restaurantWorkingHours => 'ساعات عمل المطعم';

  @override
  String get opensAt => 'يفتح';

  @override
  String get closesAt => 'يغلق';

  @override
  String get currentlyOpen => 'مفتوح حالياً';

  @override
  String get currentlyClosed => 'مغلق حالياً';

  @override
  String get pleaseSelectOpeningTime => 'يرجى اختيار وقت الافتتاح';

  @override
  String get pleaseSelectClosingTime => 'يرجى اختيار وقت الإغلاق';

  @override
  String get restaurantStatus => 'حالة المطعم';

  @override
  String get statusAccountInfo => 'معلومات الحالة والحساب';

  @override
  String get active => 'نشط';

  @override
  String get inactive => 'غير نشط';

  @override
  String get restaurantInactiveWarning =>
      'المطعم غير نشط حالياً. لا يمكن للعملاء تقديم الطلبات.';

  @override
  String get customerRating => 'تقييم العملاء';

  @override
  String get excellent => 'ممتاز';

  @override
  String get veryGood => 'جيد جداً';

  @override
  String get good => 'جيد';

  @override
  String get fair => 'مقبول';

  @override
  String get poor => 'ضعيف';

  @override
  String get created => 'تم الإنشاء';

  @override
  String get lastUpdated => 'آخر تحديث';

  @override
  String get today => 'اليوم';

  @override
  String get yesterday => 'أمس';

  @override
  String daysAgo(int count) {
    return 'منذ $count أيام';
  }

  @override
  String get unknown => 'غير معروف';

  @override
  String get downtown => 'وسط المدينة';

  @override
  String get mallArea => 'منطقة المولات';

  @override
  String get businessDistrict => 'الحي التجاري';

  @override
  String get residentialArea => 'المنطقة السكنية';

  @override
  String get profileUpdatedSuccessfully => 'تم التحديث بنجاح';

  @override
  String errorUpdatingProfile(String error) {
    return 'خطأ في تحديث الملف الشخصي: $error';
  }

  @override
  String get errorLoadingProfile => 'خطأ في تحميل ملف المطعم';

  @override
  String get pageNotFound => 'الصفحة غير موجودة';

  @override
  String get pageNotFoundDescription => 'الصفحة التي تبحث عنها غير موجودة.';

  @override
  String get goToDashboard => 'الذهاب إلى لوحة التحكم';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get ordersChartPlaceholder => 'مساحة مؤقتة لمخطط الطلبات';

  @override
  String get revenueChartPlaceholder => 'مساحة مؤقتة لمخطط الإيرادات';

  @override
  String get accessDenied => 'تم رفض الوصول';

  @override
  String get all => 'الكل';

  @override
  String get newCategory => 'جديد';

  @override
  String get preparing => 'قيد التحضير';

  @override
  String get ready => 'جاهز';

  @override
  String get pending => 'معلق';

  @override
  String get completed => 'مكتمل';

  @override
  String get cancelled => 'ملغي';

  @override
  String get filterByStatus => 'تصفية حسب الحالة';

  @override
  String get orderDetails => 'تفاصيل الطلب';

  @override
  String get orderStatusUpdated => 'تم تحديث حالة الطلب بنجاح';

  @override
  String get orderNotFound => 'الطلب غير موجود';

  @override
  String get orderNumber => 'رقم الطلب';

  @override
  String get estimatedDelivery => 'وقت التسليم المقدر';

  @override
  String get customerInfo => 'معلومات العميل';

  @override
  String get customerName => 'اسم العميل';

  @override
  String get phone => 'الهاتف';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get deliveryAddress => 'عنوان التسليم';

  @override
  String get orderItems => 'عناصر الطلب';

  @override
  String get quantity => 'الكمية';

  @override
  String get notes => 'ملاحظات';

  @override
  String get currency => 'ج.م';

  @override
  String get orderSummary => 'ملخص الطلب';

  @override
  String get subtotal => 'المجموع الفرعي';

  @override
  String get deliveryFee => 'رسوم التوصيل';

  @override
  String get tax => 'الضريبة';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get paymentStatus => 'حالة الدفع';

  @override
  String get acceptOrder => 'قبول الطلب';

  @override
  String get cancelOrder => 'إلغاء الطلب';

  @override
  String get markAsCompleted => 'وضع علامة كمكتمل';

  @override
  String get customerInformation => 'معلومات العميل';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get customerId => 'رقم العميل';

  @override
  String get address => 'العنوان';

  @override
  String get addressLine1 => 'العنوان الأول';

  @override
  String get addressLine2 => 'العنوان الثاني';

  @override
  String get city => 'المدينة';

  @override
  String get specialInstructions => 'تعليمات خاصة';

  @override
  String get restaurantPickups => 'استلام المطعم';

  @override
  String get restaurantId => 'رقم المطعم';

  @override
  String get estimatedTime => 'الوقت المتوقع';

  @override
  String get pickedUpAt => 'تم الاستلام في';

  @override
  String get actualTime => 'الوقت الفعلي';

  @override
  String get preparationTime => 'وقت التحضير';

  @override
  String get specialNotes => 'ملاحظات خاصة';

  @override
  String get customizations => 'التخصيصات';

  @override
  String get am => 'ص';

  @override
  String get pm => 'م';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'عناصر',
      one: 'عنصر',
    );
    return '$count $_temp0';
  }

  @override
  String minutesAgo(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'دقائق',
      one: 'دقيقة',
    );
    return 'منذ $minutes $_temp0';
  }

  @override
  String hoursAgo(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'ساعات',
      one: 'ساعة',
    );
    return 'منذ $hours $_temp0';
  }

  @override
  String get startPreparing => 'بدء التحضير';

  @override
  String get markAsPickedUp => 'تأكيد الاستلام';

  @override
  String get accept => 'قبول';

  @override
  String get reject => 'رفض';

  @override
  String get markReadyForPickup => 'جاهز للاستلام';

  @override
  String get readyForPickup => 'جاهز للاستلام';

  @override
  String get searchOrdersPlaceholder => 'البحث في الطلبات...';

  @override
  String get search => 'بحث';

  @override
  String get refresh => 'تحديث';

  @override
  String get error => 'خطأ';

  @override
  String get available => 'متاح';

  @override
  String get unavailable => 'غير متاح';

  @override
  String get busy => 'مشغول';

  @override
  String get showing => 'عرض';

  @override
  String get totalItems => 'إجمالي العناصر';

  @override
  String get required => 'مطلوب';

  @override
  String get addFood => 'إضافة طعام';

  @override
  String get updateFood => 'تحديث الطعام';

  @override
  String get addNewFoodItem => 'إضافة عنصر طعام جديد';

  @override
  String get editFoodItem => 'تعديل عنصر الطعام';

  @override
  String get foodDetails => 'تفاصيل الطعام';

  @override
  String get foodName => 'اسم الطعام';

  @override
  String get enterFoodName => 'أدخل اسم الطعام';

  @override
  String get pleaseEnterFoodName => 'يرجى إدخال اسم الطعام';

  @override
  String get nameMinLength => 'يجب أن يكون الاسم على الأقل حرفين';

  @override
  String get nameMaxLength => 'لا يمكن أن يتجاوز الاسم 50 حرفاً';

  @override
  String get description => 'الوصف';

  @override
  String get enterFoodDescription => 'أدخل وصف الطعام';

  @override
  String get pleaseEnterFoodDescription => 'يرجى إدخال وصف الطعام';

  @override
  String get descriptionMinLength => 'يجب أن يكون الوصف على الأقل 10 أحرف';

  @override
  String get descriptionMaxLength => 'لا يمكن أن يتجاوز الوصف 500 حرف';

  @override
  String get price => 'السعر';

  @override
  String get enterPrice => 'أدخل السعر';

  @override
  String get pleaseEnterPrice => 'يرجى إدخال السعر';

  @override
  String get pleaseEnterValidPrice => 'يرجى إدخال سعر صحيح';

  @override
  String get priceMinValue => 'يجب أن يكون السعر أكبر من 0';

  @override
  String get category => 'الفئة';

  @override
  String get selectCategory => 'اختر الفئة';

  @override
  String get pleaseSelectCategory => 'يرجى اختيار فئة';

  @override
  String get imageUrl => 'رابط الصورة';

  @override
  String get enterImageUrl => 'أدخل رابط الصورة';

  @override
  String get pleaseEnterImageUrl => 'يرجى إدخال رابط الصورة';

  @override
  String get invalidImageUrl => 'يرجى إدخال رابط صورة صحيح';

  @override
  String get foodRequirements => 'متطلبات الطعام';

  @override
  String get addRequirement => 'إضافة متطلب';

  @override
  String get requirement => 'متطلب';

  @override
  String get requirementName => 'اسم المتطلب';

  @override
  String get requirementNameHint => 'مثل: الحجم، مستوى الحرارة';

  @override
  String get pleaseEnterRequirementName => 'يرجى إدخال اسم المتطلب';

  @override
  String get requirementNameMinLength =>
      'يجب أن يكون اسم المتطلب على الأقل حرفين';

  @override
  String get requirementNameMaxLength =>
      'لا يمكن أن يتجاوز اسم المتطلب 30 حرفاً';

  @override
  String get requirementType => 'نوع المتطلب';

  @override
  String get singleChoice => 'اختيار واحد';

  @override
  String get multiChoice => 'اختيارات متعددة';

  @override
  String get requiredRequirementInfo => 'مطلوب: يجب على العميل اختيار خيار';

  @override
  String get multiChoiceInfo =>
      'اختيارات متعددة: يمكن للعميل اختيار خيارات متعددة';

  @override
  String get options => 'الخيارات';

  @override
  String get optionName => 'اسم الخيار';

  @override
  String get optionNameHint => 'مثل: صغير، متوسط، كبير';

  @override
  String get pleaseEnterOptionName => 'يرجى إدخال اسم الخيار';

  @override
  String get optionNameMinLength => 'يجب أن يكون اسم الخيار على الأقل حرف واحد';

  @override
  String get optionNameMaxLength => 'لا يمكن أن يتجاوز اسم الخيار 20 حرفاً';

  @override
  String get additionalPrice => 'السعر الإضافي';

  @override
  String get additionalPriceMinValue => 'لا يمكن أن يكون السعر الإضافي سالباً';

  @override
  String get addOption => 'إضافة خيار';

  @override
  String get minimumOneRequirement => 'يحتاج على الأقل متطلب واحد';

  @override
  String get minimumTwoOptions => 'يحتاج على الأقل خيارين';

  @override
  String get atLeastOneRequiredSingleChoice =>
      'يجب أن يكون متطلب الاختيار الواحد مطلوباً على الأقل';

  @override
  String get multiChoiceCannotBeRequired =>
      'لا يمكن أن تكون متطلبات الاختيارات المتعددة مطلوبة';

  @override
  String get noRequirementsAdded => 'لم يتم إضافة متطلبات بعد';

  @override
  String get foodItemAddedSuccessfully => 'تم إضافة عنصر الطعام بنجاح';

  @override
  String get foodItemUpdatedSuccessfully => 'تم تحديث عنصر الطعام بنجاح';

  @override
  String get toggleAvailability => 'تبديل التوفر';

  @override
  String get errorTogglingAvailability => 'خطأ في تبديل التوفر';

  @override
  String get restaurantAvailability => 'توفر المطعم';

  @override
  String get availabilityStatus => 'حالة التوفر';

  @override
  String get availabilityToggleDescription => 'التبديل بين حالة متاح ومشغول';

  @override
  String get currentStatus => 'الحالة الحالية';

  @override
  String get statusDescription => 'وصف الحالة';

  @override
  String get availabilityInfoAvailable => 'المطعم يقبل الطلبات';

  @override
  String get availabilityInfoBusy => 'المطعم مشغول مؤقتاً';

  @override
  String get restaurantIsAvailable => 'المطعم متاح';

  @override
  String get restaurantIsBusy => 'المطعم مشغول';

  @override
  String get setToAvailable => 'تعيين متاح';

  @override
  String get setToBusy => 'تعيين مشغول';

  @override
  String get availabilityUpdated => 'تم تحديث التوفر بنجاح';

  @override
  String get restaurantPickup => 'استلام من المطعم';

  @override
  String get addNewItem => 'إضافة عنصر جديد';

  @override
  String get enterRestaurantDescription => 'أدخل وصف المطعم';

  @override
  String get manageOrdersForPickupAndDelivery =>
      'إدارة طلبات الاستلام والتوصيل';

  @override
  String get adminDashboard => 'لوحة التحكم الإدارية';

  @override
  String get adminDashboardSubtitle => 'إدارة وتحليلات شاملة للمنصة';

  @override
  String get platformOverview => 'نظرة عامة على المنصة';

  @override
  String get keyMetrics => 'المؤشرات الرئيسية';

  @override
  String get realtimeUpdates => 'تحديثات لحظية';

  @override
  String get managementSections => 'أقسام الإدارة';

  @override
  String get restaurantManagement => 'إدارة المطاعم';

  @override
  String get searchRestaurantsToSeeResults => 'ابحث عن المطاعم لرؤية النتائج';

  @override
  String get ofText => 'من';

  @override
  String get restaurants => 'مطاعم';

  @override
  String get page => 'صفحة';

  @override
  String get systemReports => 'تقارير النظام';

  @override
  String get totalOrders => 'إجمالي الطلبات';

  @override
  String get totalRevenue => 'إجمالي الإيرادات';

  @override
  String get averageOrderValue => 'متوسط قيمة الطلب';

  @override
  String get userManagement => 'إدارة المستخدمين';

  @override
  String get loadingUsers => 'جاري تحميل المستخدمين...';

  @override
  String get errorLoadingUsers => 'خطأ في تحميل المستخدمين';

  @override
  String get noUsersFound => 'لم يتم العثور على مستخدمين';

  @override
  String get searchUsers => 'البحث عن المستخدمين...';

  @override
  String get userType => 'نوع المستخدم';

  @override
  String get allUserTypes => 'جميع أنواع المستخدمين';

  @override
  String get customers => 'المعملاء';

  @override
  String get deliveryPersonnel => 'موظفو التوصيل';

  @override
  String get deliveryPersonnelManagement => 'إدارة موظفي التوصيل';

  @override
  String get manageDeliveryMenTrackPerformanceAssignZones =>
      'إدارة موظفي التوصيل، تتبع الأداء، وتعيين المناطق';

  @override
  String get addDeliveryMan => 'إضافة موظف توصيل';

  @override
  String get searchByNameEmailOrPhone =>
      'البحث بالاسم أو البريد الإلكتروني أو الهاتف...';

  @override
  String deliveryMenSelected(int count) {
    return 'تم اختيار $count من موظفي التوصيل';
  }

  @override
  String get clearSelection => 'مسح التحديد';

  @override
  String get deliveryManCreatedSuccessfully => 'تم إنشاء موظف التوصيل بنجاح';

  @override
  String get deliveryManUpdatedSuccessfully => 'تم تحديث موظف التوصيل بنجاح';

  @override
  String get deliveryManDeletedSuccessfully => 'تم حذف موظف التوصيل بنجاح';

  @override
  String get loadingDeliveryPersonnel => 'جاري تحميل موظفي التوصيل...';

  @override
  String get errorLoadingDeliveryPersonnel => 'خطأ في تحميل موظفي التوصيل';

  @override
  String get noDeliveryPersonnelFound => 'لم يتم العثور على موظفي توصيل';

  @override
  String get addDeliveryPersonnelToStartManagingDeliveries =>
      'أضف موظفي التوصيل لبدء إدارة عمليات التوصيل';

  @override
  String get deleteDeliveryMan => 'حذف موظف التوصيل';

  @override
  String get areYouSureDeleteDeliveryMan =>
      'هل أنت متأكد من حذف موظف التوصيل هذا؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get analyticsFeatureComingSoon => 'ميزة التحليلات قريباً';

  @override
  String get zoneAssignmentFeatureComingSoon => 'ميزة تعيين المناطق قريباً';

  @override
  String get activateSelectedDeliveryMen => 'تفعيل موظفي التوصيل المحددين';

  @override
  String get deactivateSelectedDeliveryMen =>
      'إلغاء تفعيل موظفي التوصيل المحددين';

  @override
  String areYouSureBulkActivate(int count) {
    return 'هل أنت متأكد من تفعيل $count من موظفي التوصيل؟';
  }

  @override
  String areYouSureBulkDeactivate(int count) {
    return 'هل أنت متأكد من إلغاء تفعيل $count من موظفي التوصيل؟';
  }

  @override
  String get editDeliveryMan => 'تعديل موظف التوصيل';

  @override
  String get personalInformation => 'المعلومات الشخصية';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get nameIsRequired => 'الاسم مطلوب';

  @override
  String get emailIsRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get enterValidEmail => 'أدخل بريد إلكتروني صحيح';

  @override
  String get phoneNumberIsRequired => 'رقم الهاتف مطلوب';

  @override
  String get vehicleInformation => 'معلومات المركبة';

  @override
  String get vehicleType => 'نوع المركبة';

  @override
  String get pleaseSelectVehicleType => 'يرجى اختيار نوع المركبة';

  @override
  String get licenseIdNumber => 'رقم الرخصة/الهوية';

  @override
  String get motorcycle => 'دراجة نارية';

  @override
  String get bicycle => 'دراجة هوائية';

  @override
  String get car => 'سيارة';

  @override
  String get scooter => 'سكوتر';

  @override
  String get licenseNumberIsRequired => 'رقم الرخصة مطلوب';

  @override
  String get zoneAssignment => 'تعيين المنطقة';

  @override
  String get accountSecurity => 'أمان الحساب';

  @override
  String get passwordIsRequired => 'كلمة المرور مطلوبة';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get pleaseConfirmPassword => 'يرجى تأكيد كلمة المرور';

  @override
  String get passwordsDoNotMatch => 'كلمات المرور غير متطابقة';

  @override
  String get updateDeliveryMan => 'تحديث موظف التوصيل';

  @override
  String get allStatuses => 'جميع الحالات';

  @override
  String get suspended => 'معلق';

  @override
  String get name => 'الاسم';

  @override
  String get joinedDate => 'تاريخ الانضمام';

  @override
  String get activate => 'تفعيل';

  @override
  String get deactivate => 'إلغاء التفعيل';

  @override
  String showingResults(int current, int total) {
    return 'عرض $current من $total نتيجة';
  }

  @override
  String pageOfPages(int current, int total) {
    return 'الصفحة $current من $total';
  }

  @override
  String get assignedZoneOptional => 'المنطقة المعينة (اختيارية)';

  @override
  String get noZoneAssigned => 'لا توجد منطقة معينة';

  @override
  String get restaurantsByZones => 'المطاعم حسب المناطق';

  @override
  String get zoneManagement => 'إدارة المناطق';

  @override
  String get allZones => 'جميع المناطق';

  @override
  String get activeRestaurants => 'المطاعم النشطة';

  @override
  String get inactiveRestaurants => 'المطاعم غير النشطة';

  @override
  String get totalZones => 'إجمالي المناطق';

  @override
  String get totalRestaurants => 'إجمالي المطاعم';

  @override
  String get averageRating => 'متوسط التقييم';

  @override
  String get totalMenuItems => 'إجمالي عناصر القائمة';

  @override
  String get baseDeliveryFee => 'رسوم التوصيل الأساسية';

  @override
  String get restaurantOperatingHours => 'ساعات العمل';

  @override
  String get verified => 'موثق';

  @override
  String get notVerified => 'غير موثق';

  @override
  String get zoneCode => 'رمز المنطقة';

  @override
  String get zoneType => 'نوع المنطقة';

  @override
  String get averageRestaurantsPerZone => 'متوسط المطاعم لكل منطقة';

  @override
  String get includeStatistics => 'تضمين الإحصائيات';

  @override
  String get zoneBreakdown => 'تفصيل المناطق';

  @override
  String get overallStatistics => 'الإحصائيات العامة';

  @override
  String get loadingRestaurants => 'جاري تحميل المطاعم...';

  @override
  String get noRestaurantsFound => 'لا توجد مطاعم';

  @override
  String get errorLoadingRestaurants => 'خطأ في تحميل المطاعم';

  @override
  String get refreshRestaurants => 'تحديث المطاعم';

  @override
  String get loadMore => 'تحميل المزيد';

  @override
  String get filterByZone => 'تصفية حسب المنطقة';

  @override
  String get filterRestaurantsByStatus => 'تصفية حسب الحالة';

  @override
  String get viewRestaurantDetails => 'عرض تفاصيل المطعم';

  @override
  String get restaurantActions => 'إجراءات المطعم';

  @override
  String get manageRestaurants => 'إدارة المطاعم';

  @override
  String get adminManageRestaurants => 'إدارة المطاعم';

  @override
  String get addRestaurant => 'إضافة مطعم';

  @override
  String get welcomeToRestaurantManagement => 'مرحباً بك في إدارة المطاعم';

  @override
  String get filters => 'المرشحات';

  @override
  String get adminOrders => 'إدارة الطلبات';

  @override
  String get adminSearchOrders => 'البحث في الطلبات...';

  @override
  String get adminAllOrders => 'جميع الطلبات';

  @override
  String get adminPendingOrders => 'في الانتظار';

  @override
  String get adminConfirmedOrders => 'مؤكدة';

  @override
  String get adminPreparingOrders => 'قيد التحضير';

  @override
  String get adminReadyOrders => 'جاهزة';

  @override
  String get adminCompletedOrders => 'مكتملة';

  @override
  String get adminCancelledOrders => 'ملغية';

  @override
  String get adminOrderNumber => 'رقم الطلب';

  @override
  String get adminCustomerName => 'العميل';

  @override
  String get adminRestaurantName => 'المطعم';

  @override
  String get adminOrderStatus => 'الحالة';

  @override
  String get adminOrderTotal => 'الإجمالي';

  @override
  String get adminOrderDate => 'التاريخ';

  @override
  String get adminOrderActions => 'الإجراءات';

  @override
  String get adminViewDetails => 'عرض التفاصيل';

  @override
  String get adminNoOrdersFound => 'لا توجد طلبات';

  @override
  String get adminLoadingOrders => 'جاري تحميل الطلبات...';

  @override
  String get adminErrorLoadingOrders => 'حدث خطأ أثناء تحميل الطلبات';

  @override
  String get adminExportOrders => 'تصدير الطلبات';

  @override
  String get adminTotalOrders => 'إجمالي الطلبات';

  @override
  String get adminTotalRevenue => 'إجمالي الإيرادات';

  @override
  String get adminNoOrdersMatchFilters =>
      'لا توجد طلبات تطابق المرشحات الحالية';

  @override
  String get adminOrderDetails => 'تفاصيل الطلب';

  @override
  String get adminCreatedAt => 'تاريخ الإنشاء';

  @override
  String get adminEstimatedDelivery => 'وقت التوصيل المقدر';

  @override
  String get adminActualDelivery => 'وقت التوصيل الفعلي';

  @override
  String get adminCustomerInfo => 'معلومات العميل';

  @override
  String get adminPhoneNumber => 'رقم الهاتف';

  @override
  String get adminRestaurantInfo => 'معلومات المطعم';

  @override
  String get adminDeliveryAddress => 'عنوان التوصيل';

  @override
  String get adminOrderItems => 'عناصر الطلب';

  @override
  String get adminPaymentInfo => 'معلومات الدفع';

  @override
  String get adminSubtotal => 'المجموع الفرعي';

  @override
  String get adminDeliveryFee => 'رسوم التوصيل';

  @override
  String get adminTax => 'الضريبة';

  @override
  String get adminTotalAmount => 'المبلغ الإجمالي';

  @override
  String get adminPaymentMethod => 'طريقة الدفع';

  @override
  String get adminPaymentStatus => 'حالة الدفع';

  @override
  String get adminOrderNotes => 'ملاحظات الطلب';

  @override
  String get adminOnTheWayOrders => 'في الطريق';

  @override
  String get adminRefreshOrders => 'تحديث الطلبات';

  @override
  String get adminQuantity => 'الكمية';

  @override
  String get adminUnitPrice => 'سعر الوحدة';

  @override
  String get adminSpecialNotes => 'ملاحظات خاصة';

  @override
  String get adminGroupNumber => 'رقم المجموعة';

  @override
  String get adminOrdersCount => 'عدد الطلبات';

  @override
  String get adminRestaurantsCount => 'المطاعم';

  @override
  String get adminFinalAmount => 'المبلغ النهائي';

  @override
  String get adminCrossZone => 'عبر المناطق';

  @override
  String get adminSameZone => 'نفس المنطقة';

  @override
  String get adminIndividualOrdersInGroup => 'الطلبات الفردية في هذه المجموعة:';

  @override
  String get adminTotalOrdersIndividual => 'إجمالي الطلبات';

  @override
  String get adminAvgGroupValue => 'متوسط قيمة المجموعة';

  @override
  String get adminAvgOrdersPerGroup => 'متوسط الطلبات/المجموعة';

  @override
  String get adminOrdersPlural => 'طلبات';

  @override
  String get adminRestaurantsPlural => 'مطاعم';

  @override
  String get adminCustomerLabel => 'العميل:';

  @override
  String get adminRestaurantLabel => 'المطعم:';

  @override
  String get adminTotalLabel => 'الإجمالي:';

  @override
  String get adminDateLabel => 'التاريخ:';

  @override
  String get adminRefundOrderGroupOnly => 'استرداد مجموعة الطلبات فقط';

  @override
  String get adminRefundAndDeactivate =>
      'استرداد مجموعة الطلبات وإلغاء تفعيل حساب العميل';

  @override
  String get adminRefundOnly => 'استرداد فقط';

  @override
  String get adminRefundAndDeactivateShort => 'استرداد وإلغاء التفعيل';

  @override
  String get adminProcessingRefund =>
      'جاري معالجة الاسترداد وإلغاء تفعيل حساب العميل...';

  @override
  String get adminProcessingRefundOnly =>
      'جاري معالجة الاسترداد فقط (سيظل حساب العميل نشطاً)...';

  @override
  String get zoneManagementTitle => 'Zone Management';

  @override
  String get zoneManagementSubtitle => 'إدارة مناطق التوصيل والتوزيع';

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
  String get filterByZoneLevel => 'تصفية حسب مستوى المنطقة';

  @override
  String get allZoneTypes => 'جميع أنواع المناطق';

  @override
  String get allZoneLevels => 'جميع مستويات المناطق';

  @override
  String get government => 'محافظة';

  @override
  String get district => 'منطقة';

  @override
  String get neighborhood => 'حي';

  @override
  String get area => 'المنطقة';

  @override
  String get level1 => 'المستوى 1';

  @override
  String get level2 => 'المستوى 2';

  @override
  String get level3 => 'المستوى 3';

  @override
  String get level4 => 'المستوى 4';

  @override
  String get level5 => 'المستوى 5';

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
  String get martAdminDashboard => 'لوحة تحكم المتجر';

  @override
  String get martPos => 'نقطة البيع';

  @override
  String get martProducts => 'المنتجات';

  @override
  String get martAddProduct => 'إضافة منتج';

  @override
  String get martInventory => 'إدارة المخزون';

  @override
  String get martOrders => 'الطلبات';

  @override
  String get martReports => 'التقارير';

  @override
  String get martProfile => 'الملف الشخصي';

  @override
  String get cannotDeleteZoneWithDependencies =>
      'This zone cannot be deleted because it has related data or sub-zones';

  @override
  String get zoneDeliveryRules => 'قواعد التوصيل بين المناطق';

  @override
  String get manageZoneDeliveryRules =>
      'إدارة قواعد التوصيل بين المناطق المختلفة';

  @override
  String get addDeliveryRule => 'إضافة قاعدة توصيل';

  @override
  String get editDeliveryRule => 'تعديل قاعدة التوصيل';

  @override
  String get deleteDeliveryRule => 'حذف قاعدة التوصيل';

  @override
  String get confirmDeleteDeliveryRule =>
      'هل أنت متأكد من حذف قاعدة التوصيل هذه؟';

  @override
  String get deliveryRuleCreated => 'تم إنشاء قاعدة التوصيل بنجاح';

  @override
  String get deliveryRuleUpdated => 'تم تحديث قاعدة التوصيل بنجاح';

  @override
  String get deliveryRuleDeleted => 'تم حذف قاعدة التوصيل بنجاح';

  @override
  String get errorLoadingDeliveryRules => 'خطأ في تحميل قواعد التوصيل';

  @override
  String get retryLoadingDeliveryRules => 'إعادة تحميل القواعد';

  @override
  String get noDeliveryRulesFound => 'لم يتم العثور على قواعد توصيل';

  @override
  String get deliveryRulesHelp =>
      'قم بإنشاء قواعد التوصيل لإدارة التوصيل بين المناطق المختلفة';

  @override
  String get fromZone => 'من المنطقة';

  @override
  String get toZone => 'إلى المنطقة';

  @override
  String get selectFromZone => 'اختر المنطقة المرسلة';

  @override
  String get selectToZone => 'اختر المنطقة المستقبلة';

  @override
  String get canDeliver => 'يمكن التوصيل';

  @override
  String get additionalFee => 'رسوم إضافية';

  @override
  String get minimumOrderAmount => 'الحد الأدنى لقيمة الطلب';

  @override
  String get estimatedTimeMinutes => 'الوقت المقدر (بالدقائق)';

  @override
  String get maxDistance => 'المسافة القصوى (كم)';

  @override
  String get deliveryRuleDetails => 'تفاصيل قاعدة التوصيل';

  @override
  String get pleaseSelectFromZone => 'يرجى اختيار المنطقة المرسلة';

  @override
  String get pleaseSelectToZone => 'يرجى اختيار المنطقة المستقبلة';

  @override
  String get pleaseEnterValidAdditionalFee => 'يرجى إدخال رسوم إضافية صحيحة';

  @override
  String get pleaseEnterValidMinimumAmount =>
      'يرجى إدخال حد أدنى صحيح لقيمة الطلب';

  @override
  String get pleaseEnterValidEstimatedTime => 'يرجى إدخال وقت مقدر صحيح';

  @override
  String get pleaseEnterValidMaxDistance => 'يرجى إدخال مسافة قصوى صحيحة';

  @override
  String get sameZoneSelected =>
      'لا يمكن أن تكون المنطقة المرسلة والمستقبلة نفسها';

  @override
  String get enabled => 'مُفعل';

  @override
  String get disabled => 'مُعطل';

  @override
  String get deliveryAllowed => 'التوصيل مسموح';

  @override
  String get deliveryNotAllowed => 'التوصيل غير مسموح';

  @override
  String get minutes => 'دقائق';

  @override
  String get minutesUnit => 'دقيقة';

  @override
  String get kilometers => 'كم';

  @override
  String get sar => 'جنيه';

  @override
  String get optional => 'اختياري';

  @override
  String get edit => 'تعديل';

  @override
  String get delete => 'حذف';

  @override
  String get recentReports => 'التقارير الأخيرة';

  @override
  String get weeklyReport => 'التقرير الأسبوعي';

  @override
  String get currentWeek => 'الأسبوع الحالي';

  @override
  String get previousWeek => 'الأسبوع السابق';

  @override
  String get profitMargin => 'هامش الربح';

  @override
  String get earnings => 'الأرباح';

  @override
  String get totalEarnings => 'إجمالي الأرباح';

  @override
  String get netEarnings => 'الأرباح الصافية';

  @override
  String get totalProducts => 'إجمالي المنتجات';

  @override
  String get totalStock => 'إجمالي المخزون';

  @override
  String get lowStockProducts => 'منتجات قليلة المخزون';

  @override
  String get lowStock => 'مخزون قليل';

  @override
  String get inventorySummary => 'ملخص المخزون';

  @override
  String get confirmed => 'مؤكد';

  @override
  String get disputed => 'متنازع عليه';

  @override
  String get pendingConfirmation => 'في انتظار التأكيد';

  @override
  String get reportStatus => 'حالة التقرير';

  @override
  String get confirmReport => 'تأكيد التقرير';

  @override
  String get disputeReport => 'النزاع على التقرير';

  @override
  String get reportDetails => 'تفاصيل التقرير';

  @override
  String get weekStart => 'بداية الأسبوع';

  @override
  String get weekEnd => 'نهاية الأسبوع';

  @override
  String get commission => 'العمولة';

  @override
  String get commissionRate => 'معدل العمولة';

  @override
  String get deliveryFees => 'رسوم التوصيل';

  @override
  String get crossZoneFees => 'رسوم المناطق العابرة';

  @override
  String get orderValue => 'قيمة الطلب';

  @override
  String get totalOrdersValue => 'إجمالي قيمة الطلبات';

  @override
  String get orderCount => 'عدد الطلبات';

  @override
  String get unionOrders => 'طلبات الاتحاد';

  @override
  String get individualOrders => 'الطلبات الفردية';

  @override
  String get topSellingItems => 'العناصر الأكثر مبيعًا';

  @override
  String get itemsSold => 'العناصر المباعة';

  @override
  String get reportGenerated => 'تم إنشاء التقرير';

  @override
  String get reportConfirmed => 'تم تأكيد التقرير';

  @override
  String get reportDisputed => 'تم النزاع على التقرير';

  @override
  String get unionOrder => 'طلب اتحاد';

  @override
  String get individualOrder => 'طلب فردي';

  @override
  String get unionGroup => 'مجموعة الاتحاد';

  @override
  String get reportInfo => 'معلومات التقرير';

  @override
  String get reportPeriod => 'فترة التقرير';

  @override
  String get reportType => 'نوع التقرير';

  @override
  String get financialSummary => 'الملخص المالي';

  @override
  String get ordersSummary => 'ملخص الطلبات';

  @override
  String get orderItemsDetails => 'تفاصيل عناصر الطلبات';

  @override
  String get itemName => 'اسم العنصر';

  @override
  String get unitPrice => 'سعر الوحدة';

  @override
  String get orderDate => 'تاريخ الطلب';

  @override
  String get deliveryDate => 'تاريخ التسليم';

  @override
  String get confirmedBy => 'تأكيد من قبل';

  @override
  String get confirmedAt => 'تأكيد في';

  @override
  String get generatedAt => 'تم إنشاؤه في';

  @override
  String get martReportsTitle => 'تقارير المارت';

  @override
  String get refreshAllData => 'تحديث جميع البيانات';

  @override
  String get filterReports => 'تصفية التقارير';

  @override
  String get noDashboardData => 'لا توجد بيانات لوحة القيادة';

  @override
  String get noAnalyticsData => 'لا توجد بيانات تحليلية';

  @override
  String get noPerformanceData => 'لا توجد بيانات الأداء';

  @override
  String get noReportsData => 'لا توجد بيانات التقارير';

  @override
  String get dashboardSummary => 'ملخص لوحة القيادة';

  @override
  String get analyticsData => 'البيانات التحليلية';

  @override
  String get productPerformance => 'أداء المنتجات';

  @override
  String get reportsData => 'بيانات التقارير';

  @override
  String get totalSales => 'إجمالي المبيعات';

  @override
  String get totalProfit => 'إجمالي الربح';

  @override
  String get pendingConfirmations => 'التأكيدات المعلقة';

  @override
  String get avgOrderValue => 'متوسط قيمة الطلب';

  @override
  String get revenueByPeriod => 'الإيرادات حسب الفترة';

  @override
  String get topProducts => 'أهم المنتجات';

  @override
  String get salesTrend => 'اتجاه المبيعات';

  @override
  String get productName => 'اسم المنتج';

  @override
  String get unitsSold => 'الوحدات المباعة';

  @override
  String get profit => 'الربح';

  @override
  String get reportDate => 'تاريخ التقرير';

  @override
  String get period => 'الفترة';

  @override
  String get amount => 'المبلغ';

  @override
  String get leEgp => 'ج.م';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get revised => 'مُراجع';

  @override
  String get rejected => 'مرفوض';

  @override
  String get apply => 'تطبيق';

  @override
  String get analytics => 'التحليلات';

  @override
  String get performance => 'الأداء';

  @override
  String get reportInformation => 'معلومات التقرير';

  @override
  String get totalDeliveries => 'إجمالي التوصيلات';

  @override
  String get reportId => 'رقم التقرير';

  @override
  String get yes => 'نعم';

  @override
  String get sold => 'مباع';

  @override
  String get rating => 'التقييم';

  @override
  String get clearFilter => 'مسح الفلتر';

  @override
  String get allReports => 'جميع التقارير';

  @override
  String get noReportsAvailable => 'لا توجد تقارير متاحة';

  @override
  String get noProductPerformanceData => 'لا توجد بيانات أداء منتجات متاحة';

  @override
  String get productPerformanceTitle => 'أداء المنتجات';

  @override
  String get reportsListTitle => 'قائمة التقارير';

  @override
  String get reportsSummary => 'ملخص التقارير';

  @override
  String get units => 'وحدة';

  @override
  String get martInfo => 'معلومات المتجر';

  @override
  String get martName => 'اسم المتجر';

  @override
  String get editableData => 'البيانات القابلة للتعديل';

  @override
  String get pleaseEnterName => 'يرجى إدخال الاسم';

  @override
  String get pleaseEnterPhoneNumber => 'يرجى إدخال رقم الهاتف';

  @override
  String get updateData => 'تحديث البيانات';

  @override
  String get updateYourPersonalInfo => 'تحديث بياناتك الشخصية';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get enter => 'أدخل';

  @override
  String get adminReports => 'تقارير الإدارة';

  @override
  String get entityType => 'نوع الكيان';

  @override
  String get startDate => 'تاريخ البداية';

  @override
  String get endDate => 'تاريخ النهاية';

  @override
  String get generateWeeklyReports => 'إنشاء التقارير الأسبوعية';

  @override
  String get automatedReportGeneration => 'إنشاء التقارير الآلي';

  @override
  String get generateCurrentWeek => 'إنشاء الأسبوع الحالي';

  @override
  String get customDateRange => 'نطاق تاريخ مخصص';

  @override
  String get recentGenerationJobs => 'مهام الإنشاء الحديثة';

  @override
  String get reportTypeBreakdown => 'تفصيل أنواع التقارير';

  @override
  String get noRecentReportsAvailable => 'لا توجد تقارير حديثة متاحة';

  @override
  String get resolve => 'حل';

  @override
  String get weeklyReportsGenerated => 'تم إنشاء التقارير الأسبوعية';

  @override
  String get allEntitiesProcessed => 'تمت معالجة جميع الكيانات';

  @override
  String get startedGeneratingReports => 'بدأ إنشاء التقارير للأسبوع الحالي...';

  @override
  String get generateReports => 'إنشاء التقارير';

  @override
  String get topRestaurants => 'أفضل المطاعم';

  @override
  String get revenueBreakdown => 'تفصيل الإيرادات';

  @override
  String get ordersByStatus => 'الطلبات حسب الحالة';

  @override
  String get hourlyBreakdown => 'التفصيل الساعي';

  @override
  String get restaurantsSummary => 'ملخص المطاعم';

  @override
  String get topPerformers => 'أفضل المؤدين';

  @override
  String get categoryPerformance => 'أداء الفئات';

  @override
  String get customersSummary => 'ملخص العملاء';

  @override
  String get topCustomers => 'أفضل العملاء';

  @override
  String get newCustomers => 'عملاء جدد';

  @override
  String get activeCustomers => 'عملاء نشطون';

  @override
  String get totalCustomers => 'إجمالي العملاء';

  @override
  String reportsCount(int count) {
    return '$count تقرير';
  }

  @override
  String get generate => 'إنشاء';

  @override
  String get restaurant => 'مطعم';

  @override
  String get mart => 'متجر';

  @override
  String get delivery => 'توصيل';

  @override
  String get noReportsFound => 'لا توجد تقارير';

  @override
  String get noWeeklyReportsAvailable =>
      'لا توجد تقارير أسبوعية متاحة للمعايير المختارة';

  @override
  String get platformEarnings => 'أرباح المنصة';

  @override
  String get businessEarnings => 'أرباح الأعمال';

  @override
  String get pendingReports => 'التقارير المعلقة';

  @override
  String get totalReports => 'إجمالي التقارير';

  @override
  String get confirmedReports => 'التقارير المؤكدة';

  @override
  String get disputedReports => 'التقارير المتنازع عليها';

  @override
  String get runningJobs => 'المهام الجارية';

  @override
  String get reportsAutomaticallyGenerated =>
      'يتم إنشاء التقارير تلقائياً كل يوم اثنين للأسبوع السابق. يمكنك أيضاً تشغيل الإنشاء يدوياً لنطاقات تاريخية محددة.';

  @override
  String get errorLoadingDashboard => 'حدث خطأ أثناء تحميل بيانات لوحة التحكم';

  @override
  String get week => 'أسبوع';

  @override
  String get noRecentReports => 'لا توجد تقارير حديثة';

  @override
  String get reportsWillAppearHere => 'ستظهر التقارير هنا بمجرد إنشائها';

  @override
  String get weekOf => 'أسبوع';

  @override
  String get selectWeekStartDate => 'اختر تاريخ بداية الأسبوع لإنشاء التقرير:';

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get pleaseSelectDateFirst => 'يرجى اختيار التاريخ أولاً';

  @override
  String get profitAndLoss => 'الربح والخسارة';

  @override
  String get profitAndLossSummary => 'ملخص الربح والخسارة';

  @override
  String get reportingPeriod => 'الفترة المحاسبية';

  @override
  String get discountGiven => 'الخصومات المقدمة';

  @override
  String get costOfGoodsSold => 'تكلفة البضائع المباعة';

  @override
  String get grossProfit => 'الربح الإجمالي';

  @override
  String get inventoryPurchases => 'مشتريات المخزون';

  @override
  String get purchaseValue => 'قيمة المشتريات';

  @override
  String get netProfit => 'صافي الربح';

  @override
  String get averageOrderMargin => 'متوسط هامش الطلب';

  @override
  String get invoiceCount => 'عدد الفواتير';

  @override
  String get deliveredItemCount => 'عدد العناصر المسلّمة';

  @override
  String get salesBreakdown => 'تفصيل المبيعات';

  @override
  String get ordersChannel => 'قناة الطلبات';

  @override
  String get cashierChannel => 'قناة الكاشير';

  @override
  String startedGeneratingReportsForWeek(String date) {
    return 'بدأ إنشاء التقارير لأسبوع $date...';
  }

  @override
  String get topPerformingRestaurants => 'أفضل المطاعم أداءً';

  @override
  String get recentReportSubtitle =>
      '2-8 ديسمبر 2024 • تم معالجة جميع الكيانات';

  @override
  String get revenueAnalytics => 'تحليلات الإيرادات';

  @override
  String get orderAnalytics => 'تحليلات الطلبات';

  @override
  String get restaurantPerformance => 'أداء المطاعم';

  @override
  String get customerAnalytics => 'تحليلات العملاء';

  @override
  String get martManagement => 'إدارة المارت';

  @override
  String get martManagementSubtitle =>
      'إدارة المارت والموظفين والعمليات عبر المناطق';

  @override
  String get addMart => 'إضافة مارت';

  @override
  String get editMart => 'تعديل المارت';

  @override
  String get deleteMart => 'حذف المارت';

  @override
  String get searchMarts => 'البحث في المارت...';

  @override
  String get filterMartsByZone => 'تصفية حسب المنطقة';

  @override
  String get filterMartsByStatus => 'تصفية حسب الحالة';

  @override
  String get activeMarts => 'المارت النشطة';

  @override
  String get inactiveMarts => 'المارت غير النشطة';

  @override
  String get allMartStatuses => 'جميع الحالات';

  @override
  String get noMartsFound => 'لم يتم العثور على مارت';

  @override
  String get loadingMarts => 'تحميل المارت...';

  @override
  String get errorLoadingMarts => 'خطأ في تحميل المارت';

  @override
  String get martDetails => 'تفاصيل المارت';

  @override
  String get martInformation => 'معلومات المارت';

  @override
  String get enterMartName => 'أدخل اسم المارت';

  @override
  String get pleaseEnterMartName => 'يرجى إدخال اسم المارت';

  @override
  String get martLocation => 'موقع المارت';

  @override
  String get enterMartLocation => 'أدخل موقع المارت';

  @override
  String get pleaseEnterMartLocation => 'يرجى إدخال موقع المارت';

  @override
  String get martPhone => 'هاتف المارت';

  @override
  String get enterMartPhone => 'أدخل هاتف المارت';

  @override
  String get pleaseEnterMartPhone => 'يرجى إدخال هاتف المارت';

  @override
  String get martEmail => 'بريد المارت الإلكتروني';

  @override
  String get enterMartEmail => 'أدخل بريد المارت الإلكتروني';

  @override
  String get pleaseEnterMartEmail => 'يرجى إدخال بريد المارت الإلكتروني';

  @override
  String get pleaseEnterValidMartEmail => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String get martZone => 'منطقة المارت';

  @override
  String get selectMartZone => 'اختر منطقة المارت';

  @override
  String get pleaseSelectMartZone => 'يرجى اختيار منطقة';

  @override
  String get martDescription => 'وصف المارت';

  @override
  String get enterMartDescription => 'أدخل وصف المارت';

  @override
  String get martCoordinates => 'إحداثيات المارت';

  @override
  String get enterMartLatitude => 'أدخل خط العرض';

  @override
  String get enterMartLongitude => 'أدخل خط الطول';

  @override
  String get pleaseEnterValidLatitude => 'يرجى إدخال خط عرض صحيح';

  @override
  String get pleaseEnterValidLongitude => 'يرجى إدخال خط طول صحيح';

  @override
  String get martOperatingHours => 'ساعات العمل';

  @override
  String get openAllDay => 'مفتوح 24/7';

  @override
  String get customHours => 'ساعات مخصصة';

  @override
  String get mondayToFriday => 'الاثنين إلى الجمعة';

  @override
  String get weekends => 'عطل نهاية الأسبوع';

  @override
  String get monday => 'الاثنين';

  @override
  String get tuesday => 'الثلاثاء';

  @override
  String get wednesday => 'الأربعاء';

  @override
  String get thursday => 'الخميس';

  @override
  String get friday => 'الجمعة';

  @override
  String get saturday => 'السبت';

  @override
  String get sunday => 'الأحد';

  @override
  String get closed => 'مغلق';

  @override
  String get createMart => 'إنشاء مارت';

  @override
  String get updateMart => 'تحديث المارت';

  @override
  String get martCreatedSuccessfully => 'تم إنشاء المارت بنجاح';

  @override
  String get martUpdatedSuccessfully => 'تم تحديث المارت بنجاح';

  @override
  String get martDeletedSuccessfully => 'تم حذف المارت بنجاح';

  @override
  String get confirmDeleteMart => 'هل أنت متأكد من حذف هذا المارت؟';

  @override
  String get cannotDeleteMartWithOrders =>
      'لا يمكن حذف المارت التي تحتوي على طلبات';

  @override
  String get toggleMartStatus => 'تبديل حالة المارت';

  @override
  String get activateMart => 'تفعيل المارت';

  @override
  String get deactivateMart => 'إلغاء تفعيل المارت';

  @override
  String get martStatusUpdated => 'تم تحديث حالة المارت بنجاح';

  @override
  String get martStaffManagement => 'إدارة الموظفين';

  @override
  String get addMartStaff => 'إضافة موظف';

  @override
  String get manageMartStaff => 'إدارة الموظفين';

  @override
  String get martStaff => 'موظفو المارت';

  @override
  String get noMartStaffFound => 'لم يتم العثور على موظفين';

  @override
  String get staffName => 'اسم الموظف';

  @override
  String get enterStaffName => 'أدخل اسم الموظف';

  @override
  String get pleaseEnterStaffName => 'يرجى إدخال اسم الموظف';

  @override
  String get staffEmail => 'بريد الموظف الإلكتروني';

  @override
  String get enterStaffEmail => 'أدخل بريد الموظف الإلكتروني';

  @override
  String get pleaseEnterStaffEmail => 'يرجى إدخال بريد الموظف الإلكتروني';

  @override
  String get pleaseEnterValidStaffEmail => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String get staffPhone => 'هاتف الموظف';

  @override
  String get enterStaffPhone => 'أدخل هاتف الموظف';

  @override
  String get pleaseEnterStaffPhone => 'يرجى إدخال هاتف الموظف';

  @override
  String get staffPassword => 'كلمة مرور الموظف';

  @override
  String get enterStaffPassword => 'أدخل كلمة مرور الموظف';

  @override
  String get pleaseEnterStaffPassword => 'يرجى إدخال كلمة مرور الموظف';

  @override
  String get staffRole => 'دور الموظف';

  @override
  String get selectStaffRole => 'اختر دور الموظف';

  @override
  String get pleaseSelectStaffRole => 'يرجى اختيار دور الموظف';

  @override
  String get martAdmin => 'مدير المارت';

  @override
  String get martOperator => 'مشغل المارت';

  @override
  String get createStaff => 'إنشاء موظف';

  @override
  String get staffCreatedSuccessfully => 'تم إنشاء الموظف بنجاح';

  @override
  String get staffRemovedSuccessfully => 'تم إزالة الموظف بنجاح';

  @override
  String get confirmRemoveStaff => 'هل أنت متأكد من إزالة هذا الموظف؟';

  @override
  String get removeStaff => 'إزالة الموظف';

  @override
  String get toggleStaffStatus => 'تبديل الحالة';

  @override
  String get staffStatusUpdated => 'تم تحديث حالة الموظف بنجاح';

  @override
  String get lastLogin => 'آخر تسجيل دخول';

  @override
  String get neverLoggedIn => 'لم يسجل دخول مطلقاً';

  @override
  String get martPerformance => 'أداء المارت';

  @override
  String get viewMartPerformance => 'عرض الأداء';

  @override
  String get martAnalytics => 'تحليلات المارت';

  @override
  String get totalMartRevenue => 'إجمالي الإيرادات';

  @override
  String get totalMartOrders => 'إجمالي الطلبات';

  @override
  String get totalMartProducts => 'إجمالي المنتجات';

  @override
  String get activeMartProducts => 'المنتجات النشطة';

  @override
  String get totalMartStaff => 'إجمالي الموظفين';

  @override
  String get averageMartOrderValue => 'متوسط قيمة الطلب';

  @override
  String get todayOrders => 'طلبات اليوم';

  @override
  String get todayRevenue => 'إيرادات اليوم';

  @override
  String get topMartProducts => 'أفضل المنتجات';

  @override
  String get soldQuantity => 'الكمية المباعة';

  @override
  String get productRevenue => 'إيرادات المنتج';

  @override
  String get martsByZone => 'المارت حسب المنطقة';

  @override
  String get viewMartsByZone => 'عرض حسب المنطقة';

  @override
  String get topPerformingMarts => 'أفضل المارت أداءً';

  @override
  String get viewTopMarts => 'عرض أفضل المارت';

  @override
  String get dailyPerformance => 'الأداء اليومي';

  @override
  String get weeklyPerformance => 'الأداء الأسبوعي';

  @override
  String get monthlyPerformance => 'الأداء الشهري';

  @override
  String get selectPerformancePeriod => 'اختر الفترة';

  @override
  String get performanceChart => 'مخطط الأداء';

  @override
  String get revenueChart => 'مخطط الإيرادات';

  @override
  String get ordersChart => 'مخطط الطلبات';

  @override
  String get exportMartData => 'تصدير البيانات';

  @override
  String get refreshMartData => 'تحديث البيانات';

  @override
  String get martSettings => 'إعدادات المارت';

  @override
  String get operatingStatus => 'حالة التشغيل';

  @override
  String get martIsActive => 'المارت نشط ويقبل الطلبات';

  @override
  String get martIsInactive => 'المارت غير نشط ولا يقبل الطلبات';

  @override
  String get createdOn => 'تم الإنشاء في';

  @override
  String get lastUpdatedOn => 'آخر تحديث في';

  @override
  String get clearMartFilters => 'مسح المرشحات';

  @override
  String get applyMartFilters => 'تطبيق المرشحات';

  @override
  String get selectDateRange => 'اختر نطاق التاريخ';

  @override
  String get from => 'من';

  @override
  String get to => 'إلى';

  @override
  String get errorCreatingMart => 'خطأ في إنشاء المارت';

  @override
  String get errorUpdatingMart => 'خطأ في تحديث المارت';

  @override
  String get errorDeletingMart => 'خطأ في حذف المارت';

  @override
  String get errorLoadingMartStaff => 'خطأ في تحميل موظفي المارت';

  @override
  String get errorCreatingStaff => 'خطأ في إنشاء الموظف';

  @override
  String get errorRemovingStaff => 'خطأ في إزالة الموظف';

  @override
  String get errorLoadingMartPerformance => 'خطأ في تحميل أداء المارت';

  @override
  String get retryLoadingMarts => 'إعادة تحميل المارت';

  @override
  String showingMarts(int current, int total) {
    return 'عرض $current من $total مارت';
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
  String get zones => 'المناطق';

  @override
  String get vehicle => 'المركبة';

  @override
  String get deliveryMan => 'موظف التوصيل';

  @override
  String get online => 'متصل';

  @override
  String get offline => 'غير متصل';

  @override
  String get noZone => 'لا توجد منطقة';

  @override
  String get notAvailable => 'غير متاح';

  @override
  String get assignZone => 'تعيين منطقة';

  @override
  String get viewAnalytics => 'عرض التحليلات';

  @override
  String showingDeliveryMen(int count, int total) {
    return 'عرض $count من $total موظف توصيل';
  }

  @override
  String get settlementManagement => 'إدارة التسويات';

  @override
  String get settlementManagementSubtitle =>
      'إدارة وتحميل تقارير التسويات الفردية';

  @override
  String get downloadAllReports => 'تحميل جميع التقارير';

  @override
  String get downloadIndividualReports => 'تحميل التقارير الفردية';

  @override
  String get settlementSelectDate => 'اختر التاريخ';

  @override
  String get todaysReports => 'تقارير اليوم';

  @override
  String get vendorReports => 'تقارير البائعين';

  @override
  String get deliveryManReports => 'تقارير موظفي التوصيل';

  @override
  String get systemRevenueReport => 'تقرير إيرادات النظام';

  @override
  String get downloadingReports => 'جاري تحميل التقارير...';

  @override
  String get reportsDownloadSuccess => 'تم تحميل التقارير بنجاح';

  @override
  String get reportsDownloadError => 'خطأ في تحميل التقارير';

  @override
  String get settlementGenerateReports => 'إنشاء التقارير';

  @override
  String get settlementDate => 'تاريخ التسوية';

  @override
  String get totalVendors => 'إجمالي البائعين';

  @override
  String get totalDeliveryMen => 'إجمالي موظفي التوصيل';

  @override
  String get totalTransactions => 'إجمالي المعاملات';

  @override
  String get systemCommission => 'عمولة النظام';

  @override
  String get settlementSummary => 'ملخص التسوية';

  @override
  String get overallSummary => 'الملخص العام';

  @override
  String get martsSummary => 'ملخص المتاجر';

  @override
  String get totalSubtotal => 'إجمالي المبلغ الفرعي';

  @override
  String get selectDateToViewSettlement => 'اختر تاريخًا لعرض معلومات التسوية';

  @override
  String get downloadComprehensiveReports =>
      'تحميل تقارير التسوية الشاملة لجميع الكيانات';

  @override
  String get more => 'المزيد';
}
