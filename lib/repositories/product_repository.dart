import 'package:hive_flutter/hive_flutter.dart';
import 'package:test_blueraycargo/models/product.dart';
import 'package:test_blueraycargo/services/firebase_firestore/firestore_products_service.dart';
import 'package:test_blueraycargo/utilities/constants/hive/hive_box_name.dart';
import 'package:test_blueraycargo/utilities/constants/hive/hive_key.dart';
import 'package:test_blueraycargo/utilities/helper_functions/hive_helper.dart';
import 'package:test_blueraycargo/utilities/mixins/connectivity_checker.dart';

class ProductRepository with ConnectivityChecker {
  final _firestoreProductService = FirestoreProductsService.instance;
  final productBox = Hive.box(HiveBoxName.products);

  ProductRepository._privateConstructor();
  static final ProductRepository _instance = ProductRepository._privateConstructor();
  static ProductRepository get instance => _instance; // singleton access

  Future<List<Product>> getAvailableProducts({
    required int limit,
    required List<Product> currentProducts,
    required bool hasExceededTheTimeLimit,
    required bool forceGettingDataFromServer,
  }) async {
    final connectedToTheInternet = await hasConnectivity();

    if ((!connectedToTheInternet || !hasExceededTheTimeLimit) && !forceGettingDataFromServer) {
      final productsFromHive = productBox.get(
        HiveKey.availableProducts,
        defaultValue: [],
      )?.cast<Product>();

      return productsFromHive;
    }

    final Product? lastDocument = currentProducts.isEmpty ? null : currentProducts.last;
    final productsFromFirestore = await _firestoreProductService.getProducts(
      limit: limit,
      lastProductDocument: lastDocument,
    );

    final productsToBeSavedLocally = currentProducts + productsFromFirestore;
    productBox.put(HiveKey.availableProducts, productsToBeSavedLocally);
    HiveHelper.instance.saveTimestamp(timeStampHiveKey: HiveKey.timestampFetchingAvailableProducts);

    return productsFromFirestore;
  }
}
