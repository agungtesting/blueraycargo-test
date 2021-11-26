import 'package:hive_flutter/hive_flutter.dart';
import 'package:test_blueraycargo/utilities/constants/firestore/firestore_product_field_name.dart';
import 'package:test_blueraycargo/utilities/constants/hive/hive_type_id.dart';
import 'package:test_blueraycargo/utilities/helper_functions/map_helper.dart';

part 'product.g.dart';

@HiveType(typeId: HiveTypeId.product)
class Product {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int quantity;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String imageURL;

  @HiveField(4)
  final DateTime createdAt;

  const Product({
    required this.id,
    required this.quantity,
    required this.imageURL,
    required this.name,
    required this.createdAt,
  });

  factory Product.fromMap(Map<String, dynamic> documentData) {
    return Product(
      id: MapHelper.getStringOrDefault(data: documentData[FirestoreProductField.id]),
      quantity: MapHelper.getIntOrDefault(data: documentData[FirestoreProductField.quantity]),
      imageURL: MapHelper.getStringOrDefault(data: documentData[FirestoreProductField.imageULR]),
      name: MapHelper.getStringOrDefault(data: documentData[FirestoreProductField.name]),
      createdAt: MapHelper.getDateTimeOrDefault(data: documentData[FirestoreProductField.createdAt]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirestoreProductField.id: id,
      FirestoreProductField.quantity: quantity,
      FirestoreProductField.name: name,
      FirestoreProductField.imageULR: imageURL,
      FirestoreProductField.createdAt: createdAt,
    };
  }
}
