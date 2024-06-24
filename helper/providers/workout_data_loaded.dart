import 'package:flutter/material.dart';

// A class to change the widget if the data are loaded or not
class WorkoutDataLoaded extends ChangeNotifier {
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  set isLoaded(bool value) {
    _isLoaded = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _isLoaded = false;
    super.dispose();
  }
}
