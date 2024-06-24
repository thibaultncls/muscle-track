import 'package:workout_app/model/abstarct_class/performances.dart';

class SetsHistoryModel implements PerformancesModel {
  int setHistoryID;
  int exerciseWorkoutHistoryID;
  @override
  int setNumber;
  @override
  double? repetitions;
  @override
  double? weight;
  @override
  String? note;
  @override
  double? rir;
  @override
  double? rpe;

  SetsHistoryModel(
      {required this.setHistoryID,
      required this.exerciseWorkoutHistoryID,
      required this.setNumber,
      this.repetitions,
      this.weight,
      this.note,
      this.rir,
      this.rpe});

  factory SetsHistoryModel.fromMap(Map<String, dynamic> map) {
    return SetsHistoryModel(
        setHistoryID: map['SetHistoryID'],
        exerciseWorkoutHistoryID: map['ExerciseWorkoutHistoryID'],
        setNumber: map['SetNumber'],
        repetitions: map['Repetitions'],
        weight: map['Weight'],
        note: map['Note'],
        rir: map['RIR'],
        rpe: map['RPE']);
  }

  Map<String, dynamic> toMap() {
    return {
      'ExerciseWorkoutHistoryID': exerciseWorkoutHistoryID,
      'SetNumber': setNumber,
      'Repetitions': repetitions,
      'Weight': weight,
      'Note': note,
      'RIR': rir,
      'RPE': rpe
    };
  }
}
