import 'package:flutter/material.dart';

class NavigationHelper extends ChangeNotifier {
  int _currentIndex = 1;
  int get currentIndex => _currentIndex;

  void updateIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
