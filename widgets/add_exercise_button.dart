import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/helper/app_color.dart';
import 'package:workout_app/helper/app_style.dart';
import 'package:workout_app/helper/providers/database_helper.dart';
import 'package:workout_app/model/abstarct_class/workouts.dart';

class AddExerciseButton extends StatefulWidget {
  final Workout workout;
  const AddExerciseButton({super.key, required this.workout});

  @override
  State<AddExerciseButton> createState() => _AddExerciseButtonState();
}

class _AddExerciseButtonState extends State<AddExerciseButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ButtonStyle(
            backgroundColor:
                const WidgetStatePropertyAll(AppColors.buttonColor),
            fixedSize: WidgetStateProperty.all(
                Size(AppStyle.pageWidth(context) * 0.6, 40))),
        onPressed: () {
          context
              .read<DatabaseHelper>()
              .updateWorkoutExercises(widget.workout.id, context);

          Navigator.pop(context);
        },
        child: const Text(
          'Valider',
          style: TextStyle(
              color: AppColors.backgroungColor,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ));
  }
}
