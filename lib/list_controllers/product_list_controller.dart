import 'package:test_blueraycargo/list_controllers/list_controller.dart';
import 'package:test_blueraycargo/models/product.dart';

abstract class ProductListController extends ListController<Product> {
  @override
  void removeAnItemFromList(String id) {
    items.removeWhere((item) => item.id == id);
  }

  void addItemAtTheBeginningOfTheList(Product product) {
    items.insert(0, product);
  }

  void editItemOfTheList({
    required String productId,
    required String imageURL,
    required String name,
    required int quantity,
  }) {
    final index = items.indexWhere((element) => element.id == productId);
    final oldProductData = items[index];
    final newEditedProduct = Product(
      id: productId,
      quantity: quantity,
      imageURL: imageURL,
      name: name,
      createdAt: oldProductData.createdAt,
    );
    items.insert(index, newEditedProduct);
  }

  Product getProductOnTheList(String productId) {
    final product = items.firstWhere((element) => element.id == productId);
    return product;
  }

  /// add new list of products to current list
  @override
  void addNewItemsToCurrentList(List<Product> newItems) {
    if (items.isEmpty) {
      items = newItems;
    } else {
      // if item list is not empty then we only add the item that is not on the list yet.
      // we check if a product is on the list or not

      newItems.forEach((newItem) {
        Iterable contain = [];
        contain = items.where((currentItem) => newItem.id == currentItem.id);

        if (contain.isNotEmpty) return; // it means there is no new Event that need to be add, so we return it.

        items.add(newItem);
      });
    }
  }
}
