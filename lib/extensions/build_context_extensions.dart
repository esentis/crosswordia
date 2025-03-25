import 'package:flutter/material.dart';

const int mobileMaxWidth = 576;
const int tabletMaxWidth = 820;
const int desktopMaxWidth = 992;

extension ContextExtensions on BuildContext {
  bool get isMobile {
    return MediaQuery.sizeOf(this).width <= mobileMaxWidth;
  }

  bool get isTablet {
    return mobileMaxWidth < MediaQuery.sizeOf(this).width &&
        MediaQuery.sizeOf(this).width <= tabletMaxWidth;
  }

  bool get isDesktop {
    return tabletMaxWidth < MediaQuery.sizeOf(this).width &&
        MediaQuery.sizeOf(this).width <= desktopMaxWidth;
  }

  bool get isDesktopLarge {
    return desktopMaxWidth < MediaQuery.sizeOf(this).width;
  }
}
