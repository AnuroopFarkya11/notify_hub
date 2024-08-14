import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class HiveService<T> {
  final String boxName;
  static bool _isInitialized = false;

  HiveService(this.boxName);

  // Initialize hive
  static Future<void> init() async {
    if (_isInitialized) return;

    // Get the directory to store the Hive boxes
    final directory = await getApplicationDocumentsDirectory();
    Hive.init(directory.path);

    // Indicate that Hive has been initialized
    _isInitialized = true;
  }

  // Open the box
  Future<Box> openBox() async {
    await init();
    return await Hive.openBox<T>(boxName);
  }

  // Store data in the box
  Future<void> storeData<T>(String key, [T? value]) async {
    var box = await openBox();
    await box.put(key, value);
  }

  Future<void> addData<T>(T data) async {
    var box = await openBox();
    await box.add(data);
  }

  Future<List<T>> getDataList<T>() async {
    var box = await openBox();
    return box.values.toList().cast<T>();
  }

  // Retrieve data from the box
  Future<dynamic> retrieveData<T>(String key, [T? defaultValue]) async {
    var box = await openBox();
    return await box.get(key, defaultValue: defaultValue);
  }

  Future<void> deleteData<T>(T key) async {
    var box = await openBox();

    await box.delete(key);
  }

  // Close the box
  Future<void> closeBox() async {
    var box = await Hive.openBox(boxName);
    await box.close();
  }
}
