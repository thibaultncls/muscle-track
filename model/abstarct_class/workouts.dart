import 'package:workout_app/model/workout_detail_model.dart';

abstract class Workout {
  int get id;
  int get date;
  int? get duration;
  String get workoutName;
  List<WorkoutDetailModel>? get details;
}
