import 'package:flutter/material.dart';
import 'package:workout_app/helper/providers/database_helper.dart';
import 'package:workout_app/model/exercise_model.dart';

class SearchExercise extends ChangeNotifier {
  final _controller = TextEditingController();
  TextEditingController get controller => _controller;

  final _db = DatabaseHelper.instance;

  void addControllerListener() {
    _controller.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    notifyListeners();
  }

  List<ExerciseModel> searchedExercises() {
    if (_controller.text.isEmpty) {
      return _db.exercises;
    } else {
      return _db.exercises.where((exercises) {
        final searchLower = controller.text.toLowerCase();
        final nameLower = exercises.exerciseName.toLowerCase();
        return nameLower.contains(searchLower);
      }).toList();
    }
  }

  void clearTextField() {
    _controller.clear();
    _onSearchChanged();
    notifyListeners();
  }

  void showNewExercise(ExerciseModel exercise) {
    _controller.text = exercise.exerciseName;
    _onSearchChanged();
    notifyListeners();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
