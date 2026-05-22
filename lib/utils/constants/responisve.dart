import 'package:flutter/widgets.dart';

extension ScreenSizeExtension on BuildContext {
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;
  bool get isPortrait =>
      MediaQuery.of(this).orientation == Orientation.portrait;
  bool get isTablet => MediaQuery.of(this).size.shortestSide >= 600;
}

class Responsive {
  Responsive._();
  static double width(BuildContext context, double percent) =>
      MediaQuery.of(context).size.width * percent;
  static double height(BuildContext context, double percent) =>
      MediaQuery.of(context).size.height * percent;
}
