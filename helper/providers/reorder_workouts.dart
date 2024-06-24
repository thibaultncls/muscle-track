import 'package:flutter/material.dart';

class ReorderWorkouts extends ChangeNotifier {
  bool _isReordered = false;

  bool get isReordered => _isReordered;

  set isReordered(bool value) {
    _isReordered = value;
    notifyListeners();
  }
}
