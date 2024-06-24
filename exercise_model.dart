import 'package:workout_app/model/abstarct_class/exercises.dart';

class ExerciseModel implements Exercises {
  @override
  int exerciseID;
  @override
  String exerciseName;
  @override
  String? description;
  @override
  String bodyPart;
  @override
  String? setup;
  String? category;
  String? imagePath;

  ExerciseModel(
      {required this.exerciseID,
      required this.exerciseName,
      required this.bodyPart,
      this.description,
      this.category,
      this.imagePath,
      this.setup});

  factory ExerciseModel.fromMap(Map<String, dynamic> map) {
    return ExerciseModel(
        exerciseID: map['ExerciseID'],
        exerciseName: map['ExerciseName'],
        bodyPart: map['BodyPart'],
        description: map['Description'],
        category: map['Category'],
        imagePath: map['ImagePath'],
        setup: map['Setup']);
  }
}
