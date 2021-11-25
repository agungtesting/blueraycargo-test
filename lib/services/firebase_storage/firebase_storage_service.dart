import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart';
import 'package:test_blueraycargo/utilities/exceptions/general_exception.dart';

class FirebaseStorageService {
  final _storage = firebase_storage.FirebaseStorage.instance;

  FirebaseStorageService._privateConstructor();
  static final FirebaseStorageService _instance = FirebaseStorageService._privateConstructor();
  static FirebaseStorageService get instance => _instance; // singleton access

  Future<String> uploadProductImage({
    required File productImageFile,
    required String productID,
  }) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      final productImageRef = _storage.ref("product_image/$userId/$productID");
      await productImageRef.putFile(productImageFile);
      final downloadURL = await productImageRef.getDownloadURL();
      return downloadURL;
    } catch (error) {
      debugPrint(error.toString());
      throw GeneralException("Gagal mengunggah foto");
    }
  }
}
