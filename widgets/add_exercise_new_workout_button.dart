import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/helper/app_color.dart';
import 'package:workout_app/helper/app_keys.dart';
import 'package:workout_app/helper/app_style.dart';
import 'package:workout_app/helper/providers/add_exercise.dart';
import 'package:workout_app/helper/providers/database_helper.dart';
import 'package:workout_app/helper/providers/new_workout_controller.dart';

class AddExerciseNewWorkoutButton extends StatefulWidget {
  const AddExerciseNewWorkoutButton({super.key});

  @override
  State<AddExerciseNewWorkoutButton> createState() =>
      _AddExerciseNewWorkoutButtonState();
}

class _AddExerciseNewWorkoutButtonState
    extends State<AddExerciseNewWorkoutButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ButtonStyle(
            fixedSize: WidgetStateProperty.all(
                Size(AppStyle.pageWidth(context) * 0.6, 40))),
        onPressed: () {
          final db = context.read<DatabaseHelper>();
          final ctrl = context.read<NewWorkoutController>();
          // Add the workout
          db.addWorkout(ctrl.controller.text).then((workout) {
            // Add exercises to the workout
            db.addExerciseToNewWorkout(context, workout.id);
            context.read<AddExercise>().clearLists();
            ctrl.clear();
            Navigator.pop(context);
            Navigator.pushNamed(context, Keys.workoutPage, arguments: workout);
          });
        },
        child: const Text(
          'Commencer',
          style: TextStyle(
              color: AppColors.backgroungColor,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ));
  }
}
