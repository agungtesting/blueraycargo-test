import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';

class ProductShimmerLoading extends StatelessWidget {
  const ProductShimmerLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: 8,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.white,
                  child: _ShimmerLayout(),
                ));
          },
        ),
      ),
    );
  }
}

class _ShimmerLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double containerWidth = 280;
    double containerHeight = 15;

    return Container(
      margin: const EdgeInsets.only(bottom: 7.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            // image
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            child: Container(
              height: 100,
              width: 100,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Container(
                  height: containerHeight,
                  width: containerWidth,
                  color: Colors.grey,
                ),
                const SizedBox(height: 5),
                Container(
                  height: containerHeight,
                  width: containerWidth,
                  color: Colors.grey,
                ),
                const SizedBox(height: 5),
                Container(
                  height: containerHeight,
                  width: containerWidth * 0.5,
                  color: Colors.grey,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
