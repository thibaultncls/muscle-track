import 'package:flutter/material.dart';
import 'package:workout_app/helper/providers/database_helper.dart';
import 'package:workout_app/model/abstarct_class/exercises.dart';

class AddExercise extends ChangeNotifier {
  final _db = DatabaseHelper.instance;

// bool to check if the exercise is already added in the current workout
  final Map<int, bool> _addedExercises = {};
  Map<int, bool> get addedExercises => Map.unmodifiable(_addedExercises);

  final List<Exercises> _newAddedExercise = [];
  List<Exercises> get newAddedExercise => _newAddedExercise;

  // To see the total of exercises in the workout
  final List<Exercises> _totalExercise = [];
  List<Exercises> get totalExercise => _totalExercise;

  final List<Exercises> _exercises = [];
  List<Exercises> get exercises => _exercises;

  // check if the exercises are already in the current workout
  void initAddedExercises() {
    for (var exercise in _db.exercisesWorkout) {
      _addedExercises[exercise.exerciseID] = true;
      _totalExercise.add(exercise);
      _exercises.add(exercise);
    }
  }

  bool isAdded(int exerciseID) {
    return _addedExercises[exerciseID] ?? false;
  }

  void addExerciseToList(Exercises exercise) {
    _addedExercises.addAll({exercise.exerciseID: true});
    _newAddedExercise.add(exercise);
    _totalExercise.add(exercise);
    _exercises.add(exercise);
    notifyListeners();
  }

  void removeExerciseFromList(Exercises exercise) {
    _addedExercises.remove(exercise.exerciseID);

    newAddedExercise
        .removeWhere((element) => element.exerciseID == exercise.exerciseID);
    _totalExercise
        .removeWhere((element) => element.exerciseID == exercise.exerciseID);
    notifyListeners();
  }

  void clearLists() {
    _totalExercise.clear();
    _newAddedExercise.clear();
    _addedExercises.clear();
    _exercises.clear();
  }
}
