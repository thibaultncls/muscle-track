import 'package:flutter/material.dart';

class NewWorkoutController extends ChangeNotifier {
  final _controller = TextEditingController();
  TextEditingController get controller => _controller;

  void clear() {
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
