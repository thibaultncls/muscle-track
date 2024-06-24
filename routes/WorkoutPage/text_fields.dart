import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/helper/app_color.dart';
import 'package:workout_app/helper/app_style.dart';
import 'package:workout_app/helper/providers/database_helper.dart';
import 'package:workout_app/helper/dialog_helper.dart';
import 'package:workout_app/helper/providers/request_focus.dart';
import 'package:workout_app/helper/workout_helper.dart';
import 'package:workout_app/model/exercise_workout_model.dart';
import 'package:workout_app/model/set_model.dart';
import 'package:workout_app/helper/providers/metric_preferences.dart';
import 'package:workout_app/helper/providers/text_field_manager.dart';
import 'package:workout_app/routes/WorkoutPage/workout_widgets.dart';

class TextFields extends StatelessWidget {
  final SetModel set;
  final int exerciseIndex;
  final int setIndex;
  final ExerciseWorkoutModel exercise;
  final int workoutID;
  const TextFields(
      {super.key,
      required this.set,
      required this.exerciseIndex,
      required this.setIndex,
      required this.exercise,
      required this.workoutID});

  @override
  Widget build(BuildContext context) {
    final setID = set.id;
    final GlobalKey key = GlobalKey();
    return Consumer<TextFieldManager>(builder: (_, fieldManager, __) {
      return Row(
        children: [
          Text(
            '${set.setNumber}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
          ),
          const Spacer(
            flex: 5,
          ),
          Column(
            children: [
              WeightField(
                set: set,
                onTap: () {
                  context.read<RequestFocus>().requestFocus(0);

                  DialogHelper.showSetDetail(
                    context,
                    WorkoutHelper.getGlobalSetIndex(
                        exerciseIndex, setIndex, context),
                  );
                },
                readOnly: true,
              )
            ],
          ),
          const Spacer(flex: 1),
          Column(
            children: [
              RepsField(
                set: set,
                onTap: () {
                  context.read<RequestFocus>().requestFocus(1);

                  return DialogHelper.showSetDetail(
                    context,
                    WorkoutHelper.getGlobalSetIndex(
                        exerciseIndex, setIndex, context),
                  );
                },
                readOnly: true,
              )
            ],
          ),
          const Spacer(
            flex: 1,
          ),
          Column(
            children: [
              Consumer<MetricPreferences>(
                builder: (_, metricPreference, __) {
                  return TextField(
                    style: AppStyle.textFieldStyle(),
                    readOnly: true,
                    onTap: () {
                      context.read<RequestFocus>().requestFocus(2);

                      DialogHelper.showSetDetail(
                        context,
                        WorkoutHelper.getGlobalSetIndex(
                            exerciseIndex, setIndex, context),
                      );
                    },
                    controller: fieldManager.performanceMetricController(setID),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                        border: AppStyle.border(
                            fieldManager.isPerformanceMetricSubmitted(setID)),
                        enabledBorder: AppStyle.border(
                            fieldManager.isPerformanceMetricSubmitted(setID)),
                        focusedBorder: AppStyle.border(
                            fieldManager.isPerformanceMetricSubmitted(setID)),
                        disabledBorder: AppStyle.border(
                            fieldManager.isPerformanceMetricSubmitted(setID)),
                        suffixIcon: InkWell(
                          key: key,
                          onTap: () =>
                              DialogHelper.showMetricMenu(set, key, context),
                          child: const Icon(Icons.arrow_drop_down),
                        ),
                        hintText: AppStyle.showPerformanceMetric(
                            set, metricPreference),
                        constraints: AppStyle.textFieldConstraints(true)),
                  );
                },
              )
            ],
          ),
          IconButton(
              onPressed: () {
                fieldManager.setIsPerformanceMetricActive(true, setID);
                DialogHelper.showPerformanceMetricInfo(context).then((_) =>
                    fieldManager.setIsPerformanceMetricActive(false, setID));
              },
              icon: const Icon(
                Icons.help_outline,
                color: AppColors.paleBlue,
              )),
          IconButton(
              onPressed: () {
                context.read<DatabaseHelper>().deleteSet(
                    setID, exercise.exerciseWorkoutID, workoutID, context);
                fieldManager.removeTextFieldControllers(setID);
              },
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.deleteColor,
              )),
        ],
      );
    });
  }
}
