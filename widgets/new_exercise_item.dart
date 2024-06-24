import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/helper/app_color.dart';
import 'package:workout_app/helper/providers/add_exercise.dart';
import 'package:workout_app/helper/widget_utils.dart';
import 'package:workout_app/model/abstarct_class/exercises.dart';

class NewExerciseItem extends StatelessWidget {
  final Exercises exercise;

  const NewExerciseItem({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    String exerciseName = exercise.exerciseName.toString();
    final int exerciseID = exercise.exerciseID;
    final sizedBoxWidth = MediaQuery.sizeOf(context).width * 0.5;

    return InkWell(
      onTap: () => WidgetUtils.showExerciseDetailBottomSheet(context, exercise),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: sizedBoxWidth,
                      child: Text(
                        exerciseName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Text(
                      exercise.bodyPart,
                      style: const TextStyle(color: AppColors.secondaryText),
                    )
                  ],
                ),
                Consumer<AddExercise>(builder: (_, addEx, __) {
                  bool isAdded = addEx.isAdded(exerciseID);

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: child,
                      );
                    },
                    child: GestureDetector(
                      key: ValueKey(isAdded),
                      onTap: () {
                        if (!isAdded) {
                          addEx.addExerciseToList(exercise);
                        } else {
                          addEx.removeExerciseFromList(exercise);
                        }
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: !isAdded
                                    ? Colors.transparent
                                    : AppColors.paleBlue),
                            borderRadius: BorderRadius.circular(8),
                            color: isAdded
                                ? AppColors.backgroungColor
                                : AppColors.buttonColor),
                        child: Icon(
                          isAdded ? Icons.check : Icons.add,
                          //key: ValueKey(isAdded),
                          color: isAdded
                              ? AppColors.paleBlue
                              : AppColors.backgroungColor,
                        ),
                      ),
                    ),
                  );
                })
              ],
            ),
          ),
          const Divider(
            endIndent: 10,
            indent: 10,
          )
        ],
      ),
    );
  }
}
