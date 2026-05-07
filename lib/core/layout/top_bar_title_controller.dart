import 'package:flutter/foundation.dart';

class TopBarTitleController {
  static final ValueNotifier<String?> projectDetailsTitle =
      ValueNotifier<String?>(null);
  static final ValueNotifier<String?> pricingTitle = ValueNotifier<String?>(
    null,
  );

  static void setProjectDetailsTitle(String title) {
    projectDetailsTitle.value = title;
  }

  static void clearProjectDetailsTitle() {
    projectDetailsTitle.value = null;
  }

  static void setPricingTitle(String title) {
    pricingTitle.value = title;
  }

  static void clearPricingTitle() {
    pricingTitle.value = null;
  }
}
