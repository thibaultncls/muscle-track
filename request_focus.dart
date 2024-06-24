import 'package:flutter/material.dart';

class RequestFocus extends ChangeNotifier {
  bool _isWeightTaped = false;
  bool get isWeightTaped => _isWeightTaped;

  bool _isRepsTaped = false;
  bool get isRepsTaped => _isRepsTaped;

  bool _isPerfsTaped = false;
  bool get isPerfsTaped => _isPerfsTaped;

  void requestFocus(int index) {
    switch (index) {
      case 0:
        _isWeightTaped = true;
        _isPerfsTaped = false;
        _isRepsTaped = false;
        break;
      case 1:
        _isRepsTaped = true;
        _isWeightTaped = false;
        _isPerfsTaped = false;
        break;
      case 2:
        _isPerfsTaped = true;
        _isWeightTaped = false;
        _isRepsTaped = false;

        break;
    }
    notifyListeners();
  }
}
