import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/helper/app_color.dart';
import 'package:workout_app/helper/app_keys.dart';
import 'package:workout_app/helper/app_style.dart';
import 'package:workout_app/helper/dialog_helper.dart';
import 'package:workout_app/helper/providers/reorder_workouts.dart';
import 'package:workout_app/helper/widget_utils.dart';
import 'package:workout_app/model/abstarct_class/workouts.dart';
import 'package:workout_app/widgets/detail_list_widget.dart';

class WorkoutDetails extends StatefulWidget {
  final Workout workout;
  const WorkoutDetails({super.key, required this.workout});

  @override
  State<WorkoutDetails> createState() => _WorkoutDetailsState();
}

class _WorkoutDetailsState extends State<WorkoutDetails> {
  @override
  Widget build(BuildContext context) {
    final key = ValueKey(widget.workout.id);

    const borderSide = BorderSide(width: .5, color: AppColors.primaryColor);
    return Consumer<ReorderWorkouts>(builder: (_, reorder, __) {
      return Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: Builder(
          builder: (context) => ExpansionTile(
            enabled: !reorder.isReordered,
            key: key,
            trailing:
                (reorder.isReordered) ? const Icon(Icons.drag_handle) : null,
            title: Text(
              widget.workout.workoutName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              WidgetUtils.formatTimestamp(widget.workout.date),
              style:
                  const TextStyle(color: AppColors.secondaryText, fontSize: 12),
            ),
            children: [
              Container(
                width: AppStyle.pageWidth(this.context) * 0.6,
                height: 50,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    border: Border(
                        bottom: borderSide,
                        top: borderSide,
                        left: borderSide,
                        right: borderSide)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                        visualDensity: VisualDensity.comfortable,
                        onPressed: () => DialogHelper.showRenameWorkoutDialog(
                            widget.workout, context),
                        icon: const Icon(
                          Icons.edit,
                          color: AppColors.paleBlue,
                        )),
                    Container(
                      height: 50,
                      width: 0.5,
                      color: AppColors.primaryColor,
                      alignment: Alignment.center,
                    ),
                    IconButton(
                        visualDensity: VisualDensity.comfortable,
                        onPressed: () => DialogHelper.showDeleteDialog(
                            widget.workout, context),
                        icon: const Icon(
                          Icons.delete,
                          color: AppColors.deleteColor,
                        ))
                  ],
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(8),
                  child: (widget.workout.details == null)
                      ? const SizedBox()
                      : DetailList(workout: widget.workout)),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    style: ButtonStyle(
                        elevation: WidgetStateProperty.all(0),
                        backgroundColor:
                            WidgetStateProperty.all(AppColors.buttonColor),
                        shape: const WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(14))))),
                    onPressed: () => Navigator.pushNamed(
                        context, Keys.workoutPage,
                        arguments: widget.workout),
                    child: const Text(
                      'GO!',
                      style: TextStyle(
                          color: AppColors.backgroungColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    )),
              ),
            ],
          ),
        ),
      );
    });
  }
}
