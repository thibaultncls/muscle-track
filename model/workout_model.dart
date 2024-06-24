import 'package:workout_app/model/abstarct_class/workouts.dart';
import 'package:workout_app/model/workout_detail_model.dart';

class WorkoutModel extends Workout {
  @override
  int id;
  @override
  int date;
  @override
  int? duration;
  @override
  String workoutName;
  int orderInList;
  String? userID;
  @override
  List<WorkoutDetailModel>? details;

  WorkoutModel(
      {required this.id,
      required this.date,
      this.duration,
      required this.workoutName,
      required this.orderInList,
      this.userID,
      this.details});

  factory WorkoutModel.fromMapWithDetails(
      Map<String, dynamic> map, List<WorkoutDetailModel> details) {
    return WorkoutModel(
        id: map['WorkoutID'],
        date: map['Date'],
        workoutName: map['WorkoutName'],
        orderInList: map['OrderInList'],
        userID: map['UserID'],
        details: details);
  }

  factory WorkoutModel.fromMap(Map<String, dynamic> map) {
    return WorkoutModel(
      id: map['WorkoutID'],
      date: map['Date'],
      workoutName: map['WorkoutName'],
      orderInList: map['OrderInList'],
      userID: map['UserID'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'WorkoutID': id,
      'Date': date,
      'Duration': duration,
      'WorkoutName': workoutName,
      'OrderInList': orderInList,
      'UserID': userID,
    };
  }
}
