import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/helper/app_color.dart';
import 'package:workout_app/helper/app_style.dart';
import 'package:workout_app/helper/providers/database_helper.dart';
import 'package:workout_app/helper/dialog_helper.dart';
import 'package:workout_app/helper/providers/workout_data_loaded.dart';
import 'package:workout_app/helper/workout_helper.dart';
import 'package:workout_app/routes/WorkoutPage/text_fields.dart';
import 'package:workout_app/helper/providers/text_field_manager.dart';
import 'package:workout_app/routes/WorkoutPage/keyboard_overlay.dart';
import 'package:workout_app/model/workout_model.dart';
import 'package:workout_app/routes/WorkoutPage/workout_widgets.dart';
import 'package:workout_app/widgets/dismiss_keyboard.dart';
import 'package:workout_app/widgets/page_title.dart';
import 'package:workout_app/widgets/workout_timer_display.dart';
import 'package:workout_app/routes/WorkoutPage/workout_manager.dart';

class WorkoutPage extends StatefulWidget {
  final WorkoutModel workout;
  const WorkoutPage({super.key, required this.workout});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  final int animationDuration = 300;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WorkoutHelper.initWorkout(widget.workout, context);
    });
  }

  @override
  void dispose() {
    if (Platform.isIOS) KeyboardOverlay.removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        DialogHelper.showCancelDialog(context, true);
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return WorkoutManager(
                            workoutModel: widget.workout,
                          );
                        });
                  },
                  child: const Text(
                    'Modifier',
                    style: TextStyle(
                        color: AppColors.secondaryColor,
                        fontSize: AppStyle.averageTextSize),
                  )),
            )
          ],
          leading: Navigator.canPop(context)
              ? null
              : IconButton(
                  onPressed: () =>
                      DialogHelper.showCancelDialog(context, false),
                  icon: const Icon(Icons.arrow_back_ios)),
          title: PageTitle(
            text: widget.workout.workoutName,
          ),
        ),
        body: DismissKeyboard(
          child: Container(
            color: AppColors.backgroungColor,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: WorkoutTimerDisplay(),
                ),
                Consumer3<WorkoutDataLoaded, DatabaseHelper, TextFieldManager>(
                    builder: (_, loaded, db, fieldManager, __) {
                  return Expanded(
                      child: (!loaded.isLoaded)
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : (db.exercisesWorkout.isNotEmpty && loaded.isLoaded)
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: ListView.builder(
                                    itemCount: db.exercisesWorkout.length + 1,
                                    shrinkWrap: true,
                                    controller: fieldManager.scrollController,
                                    physics: const ScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      if (index == db.exercisesWorkout.length) {
                                        return Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              30, 10, 30, 50),
                                          child: ElevatedButton(
                                              onPressed: () =>
                                                  WorkoutHelper.workoutFinished(
                                                      context, widget.workout),
                                              child: const Text(
                                                'Terminer',
                                                style: TextStyle(
                                                    color: AppColors
                                                        .backgroungColor,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        AppStyle.fontWeight600),
                                              )),
                                        );
                                      } else {
                                        final exerciseWorkout =
                                            db.exercisesWorkout[index];

                                        return Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 8),
                                              child: ExerciseName(
                                                  exercise: exerciseWorkout,
                                                  widthCoef: 0.64),
                                            ),
                                            ListView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount:
                                                    exerciseWorkout.sets.length,
                                                itemBuilder:
                                                    (context, setIndex) {
                                                  final set = exerciseWorkout
                                                      .sets[setIndex];
                                                  final setID = set.id;

                                                  fieldManager
                                                      .focusNodeListener(
                                                          set, this.context);
                                                  return Padding(
                                                    key: fieldManager
                                                        .setKey(setID),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 5,
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        TextFields(
                                                            set: set,
                                                            exerciseIndex:
                                                                index,
                                                            setIndex: setIndex,
                                                            exercise:
                                                                exerciseWorkout,
                                                            workoutID: widget
                                                                .workout.id),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 4),
                                                          child: Container(
                                                            width: AppStyle
                                                                .pageWidth(
                                                                    context),
                                                            height: 0.3,
                                                            decoration: const BoxDecoration(
                                                                color: AppColors
                                                                    .secondaryText),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  );
                                                }),
                                            TextButton(
                                                onPressed: () {
                                                  db
                                                      .addSetToExerciseWorkout(
                                                          exerciseWorkout
                                                              .exerciseWorkoutID)
                                                      .then((set) =>
                                                          fieldManager
                                                              .addTextField(
                                                                  set.id));
                                                },
                                                child: const Text(
                                                  'Ajouter une série',
                                                  style: TextStyle(
                                                      color: AppColors
                                                          .secondaryColor,
                                                      fontSize: AppStyle
                                                          .averageTextSize),
                                                ))
                                          ],
                                        );
                                      }
                                    },
                                  ),
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Pas encore d\'exercices dans cet entraînement',
                                        style: TextStyle(
                                            fontSize: AppStyle.averageTextSize),
                                      ),
                                      const SizedBox(
                                        height: 30,
                                      ),
                                      ElevatedButton(
                                          onPressed: () =>
                                              DialogHelper.showExerciseDialog(
                                                  context, widget.workout),
                                          child: const Text(
                                            'Ajouter des exerices',
                                            style: TextStyle(
                                                color:
                                                    AppColors.backgroungColor,
                                                fontSize:
                                                    AppStyle.averageTextSize,
                                                fontWeight:
                                                    AppStyle.fontWeight600),
                                          ))
                                    ],
                                  ),
                                ));
                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
