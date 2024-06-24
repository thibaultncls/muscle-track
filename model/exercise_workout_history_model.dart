import 'package:workout_app/model/abstarct_class/exercises.dart';
import 'package:workout_app/model/sets_history_model.dart';

class ExerciseWorkoutHistoryModel implements Exercises {
  final int exerciseWorkoutHistoryID;
  final int? historyID;
  @override
  final int exerciseID;
  final int orderInList;
  @override
  final String exerciseName;
  @override
  final String bodyPart;
  @override
  final String? description;
  @override
  final String? setup;

  List<SetsHistoryModel>? setsHistory;

  ExerciseWorkoutHistoryModel(
      {required this.exerciseWorkoutHistoryID,
      this.historyID,
      required this.exerciseID,
      required this.exerciseName,
      required this.orderInList,
      this.setsHistory,
      required this.bodyPart,
      this.description,
      this.setup});

  factory ExerciseWorkoutHistoryModel.fromMap(Map<String, dynamic> map,
      String? effectiveSetup, List<SetsHistoryModel> setsHistory) {
    return ExerciseWorkoutHistoryModel(
        bodyPart: map['BodyPart'],
        description: map['Description'],
        exerciseWorkoutHistoryID: map['ExerciseWorkoutHistoryID'],
        exerciseID: map['ExerciseID'],
        exerciseName: map['ExerciseName'],
        orderInList: map['OrderInList'],
        setup: effectiveSetup,
        setsHistory: setsHistory);
  }

  Map<String, dynamic> toMap() {
    return {
      'HistoryID': historyID,
      'ExerciseID': exerciseID,
      'ExerciseName': exerciseName,
      'OrderInList': orderInList
    };
  }
}
