import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// Shows a product photo. The image text can be:
//  "asset:assets/images/chair1.png"  -> built-in photo
//  "b64:<base64 data>"               -> photo picked from the gallery/camera
//  ""                                -> placeholder icon
class ProductImage extends StatelessWidget {
  final String image;
  final BoxFit fit;
  final double iconSize;

  const ProductImage(this.image, {super.key, this.fit = BoxFit.contain, this.iconSize = 40});

  //decoded photos are kept here so they are not decoded on every rebuild
  static final Map<String, Uint8List> _cache = {};

  static Uint8List? bytesOf(String image) {
    if (!image.startsWith("b64:")) return null;
    if (_cache.length > 60) _cache.clear();
    return _cache.putIfAbsent(image, () => base64Decode(image.substring(4)));
  }

  @override
  Widget build(BuildContext context) {
    Widget placeholder = Center(
      child: Icon(Icons.chair_outlined, size: iconSize, color: AppColors.soft),
    );

    if (image.startsWith("asset:")) {
      return Image.asset(image.substring(6), fit: fit, errorBuilder: (c, e, s) => placeholder);
    }
    Uint8List? bytes = bytesOf(image);
    if (bytes != null) {
      return Image.memory(bytes, fit: fit, gaplessPlayback: true, errorBuilder: (c, e, s) => placeholder);
    }
    return placeholder;
  }
}
