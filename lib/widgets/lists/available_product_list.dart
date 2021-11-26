import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_blueraycargo/shared_providers/product_list_controller_provider.dart';
import 'package:test_blueraycargo/utilities/custom_classes/my_scroll_behaviour.dart';
import 'package:test_blueraycargo/widgets/empty_result/empty_product_result.dart';
import 'package:test_blueraycargo/widgets/error/try_again_layout.dart';
import 'package:test_blueraycargo/widgets/list_items/product_item.dart';
import 'package:test_blueraycargo/widgets/loading/loading_footer.dart';
import 'package:test_blueraycargo/widgets/loading/loading_shimmer_product.dart';

class AvailableProductList extends ConsumerWidget {
  final Function(String value) onDeleteClicked;
  final Function(String value) onEditClicked;
  const AvailableProductList({
    Key? key,
    required this.onDeleteClicked,
    required this.onEditClicked,
  }) : super(key: key);

  @override
  Widget build(context, ref) {
    final availableProductListController = ref.watch(availableProductListControllerProvider);
    return _buildLayout(availableProductListController);
  }

  Widget _buildLayout(AvailableProductListController productListController) {
    if (productListController.isLoading && productListController.items.isEmpty) {
      return const ProductShimmerLoading();
    }

    if (productListController.errorMessage != null && productListController.items.isEmpty) {
      return Column(
        children: [
          const SizedBox(height: 64),
          TryAgainLayout(
            onButtonClicked: () => productListController.getItems(),
            showBackButton: false,
          ),
        ],
      );
    }

    if (!productListController.isLoading && productListController.items.isEmpty && !productListController.hasMoreData) {
      return Column(
        children: [
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 220,
            child: EmptyProductResult(
              textMessage: "Belum ada produk disimpan.",
            ),
          ),
        ],
      );
    }

    return ScrollConfiguration(
      behavior: MyScrollBehavior(),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: productListController.items.length + 1,
        itemBuilder: (context, index) {
          if (index < productListController.items.length) {
            final product = productListController.items[index];
            return ProductItem(
              ValueKey(product.id),
              product: product,
              onDeleteClicked: (productId) => onDeleteClicked(productId),
              onEditClicked: (productId) => onEditClicked(productId),
            );
          } else if (productListController.hasMoreData & productListController.items.isNotEmpty) {
            return const LoadingFooter();
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
