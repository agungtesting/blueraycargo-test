import 'package:flutter/material.dart';

// this class is used to remove all glow/ripple effect on the scrollable widget
// reference: https://stackoverflow.com/a/51119796/9101876

class MyScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
