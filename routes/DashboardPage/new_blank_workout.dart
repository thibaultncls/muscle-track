import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/helper/app_color.dart';
import 'package:workout_app/helper/new_workout_helper.dart';
import 'package:workout_app/helper/providers/new_workout_controller.dart';

class NewBlankWorkout extends StatelessWidget {
  const NewBlankWorkout({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final formKey = GlobalKey<FormState>();
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.backgroungColor),
        height: height * 0.3,
        width: width * 0.8,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const Text(
                  'Nouvel entraînement',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const Spacer(
                  flex: 1,
                ),
                Consumer<NewWorkoutController>(builder: (_, value, __) {
                  return TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez rentrer un nom pour cet entraînement';
                      }
                      return null;
                    },
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.go,
                    onEditingComplete: () =>
                        NewWorkoutHelper.chooseNewExercises(formKey, context),
                    controller: value.controller,
                    decoration: InputDecoration(
                        hintText: 'Nom de l\'entraînement',
                        contentPadding: const EdgeInsets.only(left: 14),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.secondaryText.withOpacity(0.5),
                                width: 2),
                            borderRadius: BorderRadius.circular(14)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.secondaryText.withOpacity(0.5),
                                width: 2),
                            borderRadius: BorderRadius.circular(14))),
                  );
                }),
                const Spacer(
                  flex: 4,
                ),
                ElevatedButton(
                  onPressed: () =>
                      NewWorkoutHelper.chooseNewExercises(formKey, context),
                  style: ButtonStyle(
                      elevation: WidgetStateProperty.all(0),
                      backgroundColor:
                          WidgetStateProperty.all(AppColors.buttonColor),
                      fixedSize:
                          WidgetStateProperty.all(Size(width * 0.6, 40))),
                  child: const Text(
                    'Choisir les exercices',
                    style: TextStyle(
                        color: AppColors.backgroungColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w700),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
