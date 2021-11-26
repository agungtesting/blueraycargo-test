import 'package:flutter/foundation.dart';

abstract class ListController<T> extends ChangeNotifier {
  List<T> items = [];
  bool hasMoreData = true;
  bool isLoading = false;
  String? errorMessage;

  @protected
  bool hasExceededTheTimeLimit = true;

  @protected
  int numberOfItemPerPage = 20;

  @protected
  double intervalToReFetchItems = 3.0;

  void startLoading() {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
  }

  void stopLoading() {
    isLoading = false;
    notifyListeners();
  }

  void restartState() {
    hasMoreData = true;
    errorMessage = null;
    items = [];
    isLoading = false;
  }

  void checkIfHasMoreData(List<T> newItems) {
    if (newItems.isEmpty) {
      hasMoreData = false;
    } else {
      hasMoreData = (items.length % numberOfItemPerPage == 0);
    }
  }

  void performInfiniteScrolling() async {
    if (!hasMoreData) return;
    await getItems(forceGettingDataFromServer: true);
  }

  void addNewItemsToCurrentList(List<T> newItems);
  void removeAnItemFromList(String id);
  Future<void> getItems({bool forceGettingDataFromServer = false});
}
