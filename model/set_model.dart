import 'package:workout_app/model/abstarct_class/performances.dart';

class SetModel implements PerformancesModel {
  int id;
  int exerciseWorkoutID;
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

  SetModel({
    required this.id,
    required this.exerciseWorkoutID,
    required this.setNumber,
    this.repetitions,
    this.weight,
    this.note,
    this.rir,
    this.rpe,
  });

  factory SetModel.fromMap(Map<String, dynamic> map) {
    return SetModel(
      id: map['SetID'],
      exerciseWorkoutID: map['ExerciseWorkoutID'],
      setNumber: map['SetNumber'],
      repetitions: map['Repetitions'],
      weight: map['Weight'],
      note: map['Note'],
      rir: map['RIR'],
      rpe: map['RER'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'SetID': id,
      'ExerciseWorkoutID': exerciseWorkoutID,
      'SetNumber': setNumber,
      'Repetitions': repetitions,
      'Weight': weight,
      'Note': note,
      'RIR': rir,
      'RER': rpe,
    };
  }
}
