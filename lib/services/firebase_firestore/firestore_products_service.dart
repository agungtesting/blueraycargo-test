import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:test_blueraycargo/models/product.dart';
import 'package:test_blueraycargo/utilities/constants/firestore/firestore_product_field_name.dart';
import 'package:test_blueraycargo/utilities/exceptions/general_exception.dart';

class FirestoreProductsService {
  final _db = FirebaseFirestore.instance;
  final _path = "products";

  FirestoreProductsService._privateConstructor();
  static final FirestoreProductsService _instance = FirestoreProductsService._privateConstructor();
  static FirestoreProductsService get instance => _instance; // singleton access

  Future<void> createProduct(Map<String, dynamic> data) async {
    try {
      final String productId = data[FirestoreProductField.id];
      await _db.collection(_path).doc(productId).set(data);
    } catch (error) {
      debugPrint(error.toString());
      throw GeneralException("gagal membuat produk");
    }
  }

  Future<void> editProduct({
    required String productId,
    required String name,
    required int quantity,
    required String imageURL,
  }) async {
    try {
      final Map<String, dynamic> updatedData = {
        FirestoreProductField.name: name,
        FirestoreProductField.quantity: quantity,
        FirestoreProductField.imageULR: imageURL,
      };

      await _db.collection(_path).doc(productId).update(updatedData);
    } catch (error) {
      debugPrint(error.toString());
      throw GeneralException("gagal mengedit produk");
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _db.collection(_path).doc(productId).delete();
    } catch (error) {
      debugPrint(error.toString());
      throw GeneralException("gagal menghapus produk");
    }
  }

  Future<List<Product>> getProducts({
    required int limit,
    Product? lastProductDocument,
  }) async {
    try {
      Query query;
      query = _db.collection(_path).orderBy(FirestoreProductField.createdAt, descending: true).limit(limit);

      if (lastProductDocument != null) {
        query = query.startAfter([lastProductDocument.createdAt]);
      }

      final querySnapshot = await query.get();
      final products = querySnapshot.docs.map((snapshot) => Product.fromMap(snapshot.data() as Map<String, dynamic>)).toList();
      return products;
    } catch (error) {
      debugPrint(error.toString());
      throw GeneralException("gagal mendapatkan data produk");
    }
  }
}
