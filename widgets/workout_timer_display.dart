import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/helper/app_color.dart';
import 'package:workout_app/helper/widget_utils.dart';
import 'package:workout_app/helper/providers/workout_timer_model.dart';

class WorkoutTimerDisplay extends StatelessWidget {
  const WorkoutTimerDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<WorkoutTimerModel, int>(
        selector: (_, timerModel) => timerModel.elapsedTime,
        builder: (_, elapsedTime, __) {
          return Text(
            WidgetUtils.formattedTime(elapsedTime),
            style: const TextStyle(color: AppColors.primaryColor),
          );
        });
  }
}
