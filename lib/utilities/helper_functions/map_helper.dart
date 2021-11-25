import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:test_blueraycargo/models/product.dart';

/// data
/// from map can be null or undefined, so we need to set the default value if data is not available
class MapHelper {
  static String getStringOrDefault({required dynamic data, String defaultValue = ""}) {
    return data is String ? data : defaultValue;
  }

  static int getIntOrDefault({required dynamic data, int defaultValue = 0}) {
    int value = defaultValue;

    if (data is int) {
      value = data;
    } else if (data is double) {
      value = data.toInt();
    }

    return value;
  }

  static double getDoubleOrDefault({required dynamic data, double defaultValue = 0.0}) {
    double value = defaultValue;

    if (data is double) {
      value = data;
    } else if (data is int) {
      value = data.toDouble();
    }

    return value;
  }

  static bool getBoolOrDefault({required dynamic data, required bool defaultValue}) {
    bool value = defaultValue;

    if (data is bool) {
      value = data;
    } else if (data is String) {
      value = (data == "true");
    }
    return value;
  }

  static DateTime getDateTimeOrDefault({required dynamic data}) {
    DateTime dateTimeData = DateTime.now();

    if (data is Timestamp) {
      dateTimeData = data.toDate();
    } else if (data is String) {
      // ISO 8601 String format
      dateTimeData = DateTime.parse(data).toLocal();
    } else if (data is DateTime) {
      dateTimeData = data;
    }

    return dateTimeData;
  }

  static List<String> getListOfStringOrDefault({required dynamic data}) {
    List<String> listStringData = [];

    if (data is List<dynamic> && data.isNotEmpty && (data.first is String)) {
      listStringData = List.from(data);
    } else if (data is String) {
      // if data is from JSON that is Stringified

      try {
        if (data.isNotEmpty) {
          final List<String> values = List<String>.from(json.decode(data));
          listStringData = values;
        }
      } catch (error) {
        debugPrint(error.toString());
      }
    }

    return listStringData;
  }

  static List<Product> getListOfProductOrDefault({required dynamic data}) {
    List<Product> productList = [];

    if (data is List<dynamic> && data.isNotEmpty && (data.first is Map<String, dynamic>)) {
      final productListMap = List.from(data);
      productList = productListMap.map((productData) => Product.fromMap(productData)).toList();
    }

    return productList;
  }
}
