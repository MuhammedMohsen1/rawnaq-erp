import 'package:flutter/material.dart';

class TopBarAction {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const TopBarAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });
}

class TopBarTitleController {
  static final ValueNotifier<String?> projectDetailsTitle =
      ValueNotifier<String?>(null);
  static final ValueNotifier<String?> pricingTitle = ValueNotifier<String?>(
    null,
  );
  static final ValueNotifier<TopBarAction?> pricingAction =
      ValueNotifier<TopBarAction?>(null);

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

  static void setPricingAction(TopBarAction action) {
    pricingAction.value = action;
  }

  static void clearPricingAction() {
    pricingAction.value = null;
  }
}
