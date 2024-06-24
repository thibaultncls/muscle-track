import 'package:flutter/material.dart';
import 'package:workout_app/helper/dialog_helper.dart';

class NewWorkoutHelper {
  static void chooseNewExercises(
      GlobalKey<FormState> key, BuildContext context) {
    if (key.currentState!.validate()) {
      Navigator.pop(context);
      DialogHelper.showExerciseNewWorkout(context);
    }
  }
}
