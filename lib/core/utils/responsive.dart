import 'package:flutter/material.dart';

class Responsive {
  final double _widthScale;
  final double _heightScale;
  final double screenWidth;

  Responsive._({
    required double widthScale,
    required double heightScale,
    required this.screenWidth,
  })  : _widthScale = widthScale,
        _heightScale = heightScale;

  static const double _baseWidth = 360;
  static const double _baseHeight = 800;
  static const double _minScale = 0.85;
  static const double _maxScale = 1.3;

  factory Responsive.of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final widthScale = (size.width / _baseWidth).clamp(_minScale, _maxScale);
    final heightScale = (size.height / _baseHeight).clamp(_minScale, _maxScale);
    return Responsive._(
      widthScale: widthScale,
      heightScale: heightScale,
      screenWidth: size.width,
    );
  }

  double s(double value) => value * _widthScale;
  double sh(double value) => value * _heightScale;

  bool get isSmallPhone => screenWidth < 340;
  bool get isTablet => screenWidth >= 600;
}
