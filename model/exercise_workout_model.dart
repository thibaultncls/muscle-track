import 'package:workout_app/model/abstarct_class/exercises.dart';
import 'package:workout_app/model/set_model.dart';
import 'package:workout_app/helper/app_keys.dart';

class ExerciseWorkoutModel implements Exercises {
  int exerciseWorkoutID;
  @override
  int exerciseID;
  int orderInList;
  @override
  String exerciseName;
  @override
  final String bodyPart;
  @override
  final String? description;
  @override
  String? setup;
  List<SetModel> sets;

  ExerciseWorkoutModel(
      {required this.exerciseWorkoutID,
      required this.exerciseID,
      required this.orderInList,
      required this.exerciseName,
      required this.sets,
      required this.bodyPart,
      this.description,
      this.setup});

  factory ExerciseWorkoutModel.fromMap(
      Map<String, dynamic> map, String? effectiveSetup, List<SetModel> sets) {
    return ExerciseWorkoutModel(
        bodyPart: map[Keys.bodyPart],
        description: map[Keys.description],
        exerciseWorkoutID: map[Keys.exerciseWorkoutID],
        exerciseID: map[Keys.exerciseID],
        orderInList: map[Keys.orderInList],
        exerciseName: map[Keys.exerciseName],
        setup: effectiveSetup,
        sets: sets);
  }
}
