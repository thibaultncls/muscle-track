class WorkoutDetailModel {
  String exerciseName;
  int setCount;

  WorkoutDetailModel({required this.exerciseName, required this.setCount});

  factory WorkoutDetailModel.fromMap(Map<String, dynamic> map) {
    return WorkoutDetailModel(
        exerciseName: map['ExerciseName'], setCount: map['SetCount']);
  }
}
