import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/helper/app_color.dart';
import 'package:workout_app/helper/providers/set_timer_model.dart';

class SetTimerDisplay extends StatelessWidget {
  const SetTimerDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<SetTimerModel, int>(
      selector: (_, timerModel) => timerModel.elapsedTime,
      builder: (_, elapsedTime, __) {
        int minutes = (elapsedTime ~/ 60000);
        int seconds = (elapsedTime % 60000) ~/ 1000;
        int milliseconds = (elapsedTime % 1000) ~/ 10;

        String formattedTime =
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${milliseconds.toString().padLeft(2, '0')}';
        return SizedBox(
          width: 250,
          child: Text(
            formattedTime,
            //textAlign: TextAlign.center,

            style: const TextStyle(
              color: AppColors.primaryColor,
              fontSize: 55,
            ),
          ),
        );
      },
    );
  }
}
