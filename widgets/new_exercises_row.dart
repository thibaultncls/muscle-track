import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/helper/app_color.dart';
import 'package:workout_app/helper/providers/add_exercise.dart';
import 'package:workout_app/helper/providers/new_workout_controller.dart';
import 'package:workout_app/helper/providers/search_exercise.dart';
import 'package:workout_app/widgets/new_exercise_dialog.dart';

class NewExercisesRow extends StatelessWidget {
  const NewExercisesRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
            onPressed: () {
              context.read<AddExercise>().clearLists();
              context.read<SearchExercise>().clearTextField();
              context.read<NewWorkoutController>();

              Navigator.pop(context);
            },
            child: const Text(
              'Annuler',
              style: TextStyle(color: AppColors.deleteColor, fontSize: 16),
            )),
        TextButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) => const NewExerciseDialog());
            },
            child: const Text(
              'Nouveau',
              style: TextStyle(color: AppColors.paleBlue, fontSize: 16),
            ))
      ],
    );
  }
}
