import 'package:workout_app/model/abstarct_class/workouts.dart';
import 'package:workout_app/model/workout_detail_model.dart';

class WorkoutHistoryModel extends Workout {
  @override
  int id;
  int workoutID;
  @override
  int date;
  @override
  int duration;
  @override
  String workoutName;
  @override
  List<WorkoutDetailModel>? details;

  WorkoutHistoryModel(
      {required this.id,
      required this.workoutID,
      required this.date,
      required this.duration,
      required this.workoutName,
      this.details});

  factory WorkoutHistoryModel.fromMap(
      Map<String, dynamic> map, List<WorkoutDetailModel> workoutDetailHistory) {
    return WorkoutHistoryModel(
        id: map['HistoryID'],
        workoutID: map['WorkoutID'],
        date: map['Date'],
        duration: map['Duration'],
        workoutName: map['WorkoutName'],
        details: workoutDetailHistory);
  }

  Map<String, dynamic> toMap() {
    return {
      'WorkoutID': workoutID,
      'Date': date,
      'Duration': duration,
      'WorkoutName': workoutName
    };
  }
}
