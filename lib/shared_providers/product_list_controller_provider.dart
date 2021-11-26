import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_blueraycargo/list_controllers/product_list_controller.dart';
import 'package:test_blueraycargo/models/product.dart';
import 'package:test_blueraycargo/repositories/product_repository.dart';
import 'package:test_blueraycargo/utilities/constants/hive/hive_key.dart';
import 'package:test_blueraycargo/utilities/helper_functions/hive_helper.dart';

final availableProductListControllerProvider = ChangeNotifierProvider<AvailableProductListController>((ref) {
  return AvailableProductListController(HiveHelper.instance);
});

class AvailableProductListController extends ProductListController {
  final HiveHelper _hiveHelper;

  AvailableProductListController(this._hiveHelper);

  void checkIfHasExceededTheTimeLimit() {
    hasExceededTheTimeLimit = _hiveHelper.checkIfItHasExceededTimeLimit(
      timeStampHiveKey: HiveKey.timestampFetchingAvailableProducts,
      timeIntervalInHours: intervalToReFetchItems,
    );

    if (hasExceededTheTimeLimit) restartState();
  }

  void addProductToList(Product product) {
    items.add(product);
    items.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    notifyListeners();
  }

  @override
  Future<void> getItems({bool forceGettingDataFromServer = false}) async {
    if (isLoading) return;

    try {
      startLoading();

      final productRepository = ProductRepository.instance;
      final productFromRepository = await productRepository.getAvailableProducts(
        limit: numberOfItemPerPage,
        currentProducts: items,
        hasExceededTheTimeLimit: hasExceededTheTimeLimit,
        forceGettingDataFromServer: forceGettingDataFromServer,
      );
      addNewItemsToCurrentList(productFromRepository);
      checkIfHasMoreData(productFromRepository);
    } catch (error) {
      debugPrint(error.toString());
      errorMessage = "Mohon maaf terjadi error";
    } finally {
      stopLoading();
    }
  }
}
