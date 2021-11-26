import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:test_blueraycargo/models/product.dart';
import 'package:test_blueraycargo/utilities/constants/hive/hive_box_name.dart';
import 'package:test_blueraycargo/utilities/constants/hive/hive_type_id.dart';

class HiveHelper {
  HiveHelper._privateConstructor();
  static final HiveHelper _instance = HiveHelper._privateConstructor();
  static HiveHelper get instance => _instance;

  /// 1. Init Hive Flutter
  /// 2. Register Adapters
  /// 3. Open Hive Boxes
  Future<void> setUpHive() async {
    try {
      await Hive.initFlutter();

      // register the adapters
      if (!Hive.isAdapterRegistered(HiveTypeId.product)) {
        Hive.registerAdapter<Product>(ProductAdapter());
      }
      // open the boxes
      await safelyOpenTheBox(HiveBoxName.products);
      await safelyOpenTheBox(HiveBoxName.timestamps);
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<void> safelyOpenTheBox(String boxName) async {
    try {
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox(boxName);
      }
    } catch (error) {
      await Hive.deleteBoxFromDisk(boxName);
      await Hive.openBox(boxName);
    }
  }

  Future<void> clearBoxesWhenSignOut() async {
    try {
      HiveBoxName.boxesThatShouldBeDeletedWhenSigningOut.forEach((boxName) async {
        final box = Hive.box(boxName);
        await box.clear();
      });
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  bool checkIfItHasExceededTimeLimit({
    required String timeStampHiveKey,
    required double timeIntervalInHours,
  }) {
    final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
    final timestampsBox = Hive.box(HiveBoxName.timestamps);
    final int lastSavedTimestamp = timestampsBox.get(timeStampHiveKey) ?? 0;
    final timeIntervalInMilliseconds = 60 * 60 * 1000 * timeIntervalInHours;
    return (currentTimestamp - lastSavedTimestamp) > timeIntervalInMilliseconds;
  }

  void saveTimestamp({required String timeStampHiveKey}) {
    try {
      final timestampsBox = Hive.box(HiveBoxName.timestamps);
      timestampsBox.put(timeStampHiveKey, DateTime.now().millisecondsSinceEpoch);
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<void> clearTimestamp({required String timeStampHiveKey}) async {
    try {
      final timestampsBox = Hive.box(HiveBoxName.timestamps);
      await timestampsBox.put(timeStampHiveKey, 0);
    } catch (error) {
      debugPrint(error.toString());
    }
  }
}
