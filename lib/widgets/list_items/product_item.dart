import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:test_blueraycargo/models/product.dart';
import 'package:test_blueraycargo/utilities/constants/assets_name/images/image_assets_name.dart';

class ProductItem extends StatelessWidget {
  final Product product;
  const ProductItem(Key key, {required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProductImage(productImageURL: product.imageURL),
          const SizedBox(width: 16),
          Expanded(child: _ProductInfo(name: product.name, quantity: product.quantity)),
        ],
      ),
    );
  }
}

class _ProductInfo extends StatelessWidget {
  final String name;
  final int quantity;

  const _ProductInfo({
    required this.name,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, right: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            maxLines: 2,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            "Qty: $quantity",
            maxLines: 1,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String productImageURL;
  const _ProductImage({required this.productImageURL});

  Widget _buildImage() {
    if (productImageURL.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: productImageURL,
        fadeInCurve: Curves.easeIn,
        fadeInDuration: const Duration(milliseconds: 300),
      );
    } else {
      return Image.asset(ImageAssetsName.emptyPicture);
    }
  }

  Widget _buildBlurImage() {
    return ClipRRect(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaY: 4, sigmaX: 4),
        child: CachedNetworkImage(
          imageUrl: productImageURL,
          fit: BoxFit.fill,
          fadeInCurve: Curves.easeIn,
          height: double.infinity,
          width: double.infinity,
          fadeInDuration: const Duration(milliseconds: 100),
          colorBlendMode: BlendMode.colorBurn,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      elevation: 0,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: SizedBox(
        height: screenWidth * 0.25,
        width: screenWidth * 0.25,
        child: Stack(alignment: Alignment.center, children: [
          if (productImageURL.isNotEmpty) _buildBlurImage(),
          _buildImage(),
        ]),
      ),
    );
  }
}
