import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_blueraycargo/models/product.dart';
import 'package:test_blueraycargo/services/firebase_authentication/firebase_auth_service.dart';
import 'package:test_blueraycargo/services/firebase_firestore/firestore_products_service.dart';
import 'package:test_blueraycargo/services/firebase_storage/firebase_storage_service.dart';
import 'package:test_blueraycargo/shared_providers/product_list_controller_provider.dart';
import 'package:test_blueraycargo/utilities/constants/hive/hive_key.dart';
import 'package:test_blueraycargo/utilities/helper_functions/hive_helper.dart';
import 'package:test_blueraycargo/utilities/mixins/connectivity_checker.dart';
import 'package:uuid/uuid.dart';

final productsPageControllerProvider = ChangeNotifierProvider.autoDispose<ProductsPageController>((ref) {
  final availableProductListController = ref.watch(availableProductListControllerProvider);
  return ProductsPageController(
    FirebaseAuthService.instance,
    GoogleSignIn(),
    FirebaseStorageService.instance,
    FirestoreProductsService.instance,
    HiveHelper.instance,
    availableProductListController,
  );
});

class ProductsPageController with ChangeNotifier, ConnectivityChecker {
  final FirebaseAuthService _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseStorageService _firebaseStorageService;
  final FirestoreProductsService _firestoreProductsService;
  final HiveHelper _hiveHelper;
  final AvailableProductListController _availableProductListController;

  ProductsPageController(
    this._firebaseAuth,
    this._googleSignIn,
    this._firebaseStorageService,
    this._firestoreProductsService,
    this._hiveHelper,
    this._availableProductListController,
  );

  bool isEditing = false;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  File? _productImageFile;
  File? get productImageFile => _productImageFile;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _selectedProductName = "";
  String get selectedProductName => _selectedProductName;
  set selectedProductName(String newProductName) => _selectedProductName = newProductName.trim();

  String editedImageURL = "";
  String editedProductId = "";

  int _selectedProductQuantity = 0;
  int get selectedProductQuantity => _selectedProductQuantity;

  void updateSelectedProductQuantity(String newQuantity) {
    if (newQuantity.isEmpty) return;
    final newValue = newQuantity.replaceAll(".", "");
    _selectedProductQuantity = int.tryParse(newValue) ?? 0;
    notifyListeners();
  }

  void restartState() {
    _errorMessage = null;
    _productImageFile = null;
    _selectedProductName = "";
    _selectedProductQuantity = 0;
    _isLoading = false;
    isEditing = false;
    editedImageURL = "";
    editedProductId = "";
    notifyListeners();
  }

  void _startLoading() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
  }

  void _stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  void performEditingAction(String productId) {
    isEditing = true;
    final editedProduct = _availableProductListController.getProductOnTheList(productId);
    _selectedProductQuantity = editedProduct.quantity;
    _selectedProductName = editedProduct.name;
    editedImageURL = editedProduct.imageURL;
    editedProductId = editedProduct.id;

    notifyListeners();
  }

  Future<void> pickAndProcessTheImage(BuildContext context) async {
    _startLoading();

    try {
      final ImagePicker picker = ImagePicker();

      // Pick Image From Gallery
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) {
        _stopLoading();
        return;
      }

      // compress image
      final compressedFile = await _compressImage(File(pickedFile.path));

      if (compressedFile == null) {
        _stopLoading();
        return;
      }

      // if all is good then it's okay to show it to user
      _productImageFile = compressedFile;
      _errorMessage = null;
    } catch (error) {
      debugPrint(error.toString());
      _errorMessage = error.toString().replaceAll("Exception: ", "");
    } finally {
      _stopLoading();
    }
  }

  Future<File?> _compressImage(File imageFile) async {
    final compressedDestinationPath = imageFile.path + "product.jpeg";
    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      imageFile.path,
      compressedDestinationPath,
      quality: 80,
    );

    return compressedFile;
  }

  bool checkIfProductImageIsAvailable() {
    if (_productImageFile == null) {
      _errorMessage = "Gambar produk tidak boleh kosong";
      notifyListeners();
      return false;
    } else {
      return true;
    }
  }

  String? validateTitle() {
    if (_selectedProductName.isEmpty) {
      return "Nama tidak boleh kosong.";
    }

    return null;
  }

  String? validateProductImage() {
    if (_productImageFile == null) {
      return "Anda belum memilih gambar produk!";
    }

    return null;
  }

  Future<void> deleteProductFromServer(String productID) async {
    _startLoading();

    try {
      await _firestoreProductsService.deleteProduct(productID);
      _hiveHelper.clearTimestamp(timeStampHiveKey: HiveKey.timestampFetchingAvailableProducts);
      _availableProductListController.removeAnItemFromList(productID);
    } catch (error) {
      rethrow;
    } finally {
      _stopLoading();
    }
  }

  Future<void> editProductInServer(String productId) async {
    _startLoading();

    try {
      final productImageIsChanged = (isEditing && (_productImageFile != null));

      if (productImageIsChanged) {
        editedImageURL = await _firebaseStorageService.uploadProductImage(
          productImageFile: _productImageFile!,
          productID: productId,
        );
      }

      await _firestoreProductsService.editProduct(
        productId: productId,
        name: _selectedProductName,
        quantity: _selectedProductQuantity,
        imageURL: editedImageURL,
      );

      _availableProductListController.editItemOfTheList(productId: productId, imageURL: editedImageURL, name: _selectedProductName, quantity: _selectedProductQuantity);
      _hiveHelper.clearTimestamp(timeStampHiveKey: HiveKey.timestampFetchingAvailableProducts);

      restartState();
    } catch (error) {
      debugPrint(error.toString());
      _errorMessage = error.toString();
      rethrow;
    } finally {
      _stopLoading();
    }
  }

  Future<void> uploadProductToServer() async {
    _startLoading();

    try {
      final productID = const Uuid().v4();
      final productImageURL = await _firebaseStorageService.uploadProductImage(
        productImageFile: _productImageFile!,
        productID: productID,
      );

      final createdAt = DateTime.now();
      final newProduct = Product(
        id: productID,
        quantity: _selectedProductQuantity,
        imageURL: productImageURL,
        name: _selectedProductName,
        createdAt: createdAt,
      );

      final productData = newProduct.toMap();
      await _firestoreProductsService.createProduct(productData);
      _availableProductListController.addItemAtTheBeginningOfTheList(newProduct);
      _hiveHelper.clearTimestamp(timeStampHiveKey: HiveKey.timestampFetchingAvailableProducts);

      restartState();
    } catch (error) {
      debugPrint(error.toString());
      _errorMessage = error.toString();
      rethrow;
    } finally {
      _stopLoading();
    }
  }

  Future<void> performLogOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool("hasLoggedIn", false);

      await _hiveHelper.clearBoxesWhenSignOut();
      await _googleSignIn.signOut();
      await _firebaseAuth.logOut();
    } catch (error) {
      debugPrint(error.toString());
    }
  }
}
