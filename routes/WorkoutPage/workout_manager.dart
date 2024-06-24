import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/helper/app_color.dart';
import 'package:workout_app/helper/app_style.dart';
import 'package:workout_app/helper/providers/database_helper.dart';
import 'package:workout_app/helper/dialog_helper.dart';
import 'package:workout_app/model/workout_model.dart';

class WorkoutManager extends StatefulWidget {
  final WorkoutModel workoutModel;
  const WorkoutManager({super.key, required this.workoutModel});

  @override
  State<WorkoutManager> createState() => _WorkoutManagerState();
}

class _WorkoutManagerState extends State<WorkoutManager> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
          decoration: BoxDecoration(
              color: AppColors.backgroungColor,
              borderRadius: BorderRadius.circular(20)),
          height: AppStyle.pageHeight(context) * 0.6,
          width: AppStyle.pageWidth(context) * .9,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 30),
                child: Text(
                  widget.workoutModel.workoutName,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              Consumer<DatabaseHelper>(builder: (_, db, __) {
                return Expanded(
                  child: ListView(children: [
                    (db.exercisesWorkout.isNotEmpty)
                        ? ReorderableListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final exerciseWorkout =
                                  db.exercisesWorkout[index];
                              ValueKey key =
                                  ValueKey(exerciseWorkout.exerciseWorkoutID);
                              return Padding(
                                key: key,
                                padding: const EdgeInsets.only(
                                    left: 20, top: 8, right: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.drag_handle,
                                      color: AppColors.secondaryText,
                                    ),
                                    const Spacer(),
                                    Expanded(
                                      flex: 8,
                                      child: Center(
                                        child: Text(
                                          overflow: TextOverflow.ellipsis,
                                          exerciseWorkout.exerciseName,
                                          style: const TextStyle(
                                              fontSize:
                                                  AppStyle.averageTextSize,
                                              fontWeight:
                                                  AppStyle.fontWeight500),
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                        onPressed: () => context
                                            .read<DatabaseHelper>()
                                            .removeExerciseFromWorkout(
                                                widget.workoutModel.id,
                                                exerciseWorkout.exerciseID,
                                                context),
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: AppColors.deleteColor,
                                        ))
                                  ],
                                ),
                              );
                            },
                            itemCount: db.exercisesWorkout.length,
                            onReorder: db.updateExerciseInWorkoutOrder)
                        : const SizedBox(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: TextButton(
                          onPressed: () {
                            DialogHelper.showExerciseDialog(
                                context, widget.workoutModel);
                          },
                          child: const Text(
                            'Ajouter un exercice',
                            style: TextStyle(
                                color: AppColors.secondaryColor,
                                fontSize: AppStyle.averageTextSize,
                                fontWeight: AppStyle.fontWeight500),
                          )),
                    )
                  ]),
                );
              }),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: const ButtonStyle(
                      padding: WidgetStatePropertyAll(
                          EdgeInsets.symmetric(horizontal: 40))),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                        color: AppColors.backgroungColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16),
                  ),
                ),
              )
            ],
          )),
    );
  }
}
