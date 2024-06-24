import 'package:workout_app/model/abstarct_class/performances.dart';

class ExercisePerformance implements PerformancesModel {
  DateTime workoutDate;
  final String exerciseName;
  final int exerciseWorkoutHistoryID;
  final int setHistoryID;
  @override
  final int setNumber;
  @override
  final double? repetitions;
  @override
  final double? weight;
  @override
  final String? note;
  @override
  final double? rir;
  @override
  final double? rpe;

  ExercisePerformance(
      {required this.setNumber,
      required this.workoutDate,
      required this.exerciseName,
      required this.exerciseWorkoutHistoryID,
      required this.setHistoryID,
      this.repetitions,
      this.weight,
      this.note,
      this.rir,
      this.rpe});

  // Method to create an instance from a Map coming from the database
  factory ExercisePerformance.fromMap(Map<String, dynamic> map) {
    return ExercisePerformance(
        setNumber: map['SetNumber'],
        workoutDate:
            DateTime.fromMillisecondsSinceEpoch(map['WorkoutDate'] * 1000),
        exerciseName: map['ExerciseName'],
        exerciseWorkoutHistoryID: map['ExerciseWorkoutHistoryID'],
        setHistoryID: map['SetHistoryID'],
        repetitions: map['Repetitions'],
        weight: map['Weight'],
        note: map['Note'],
        rir: map['RIR'],
        rpe: map['RPE']);
  }
}
