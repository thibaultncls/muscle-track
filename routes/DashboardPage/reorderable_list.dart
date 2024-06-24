import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/helper/app_color.dart';
import 'package:workout_app/helper/providers/database_helper.dart';
import 'package:workout_app/helper/widget_utils.dart';
import 'package:workout_app/routes/DashboardPage/workout_details.dart';

class ReorderableDashboardList extends StatefulWidget {
  const ReorderableDashboardList({super.key});

  @override
  State<ReorderableDashboardList> createState() =>
      _ReorderableDashboardListState();
}

class _ReorderableDashboardListState extends State<ReorderableDashboardList> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseHelper>(builder: (_, db, __) {
      return ReorderableListView.builder(
        proxyDecorator: proxyDecorator,
        primary: true,
        itemCount: db.workouts.length,
        itemBuilder: (context, index) {
          final workout = db.workouts[index];
          ValueKey key = ValueKey(workout.id);

          return Padding(
            key: key,
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: Container(
                decoration: BoxDecoration(
                    color: AppColors.backgroungColor,
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    border: Border.all(
                        width: .7,
                        color: AppColors.primaryColor.withOpacity(.9))),
                width: double.infinity,
                child: WorkoutDetails(workout: workout)),
          );
        },
        onReorder: ((oldIndex, newIndex) {
          db.updateWorkoutOrder(oldIndex, newIndex);
        }),
      );
    });
  }

  Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
    final workout =
        Provider.of<DatabaseHelper>(context, listen: false).workouts[index];
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double scale = lerpDouble(0.95, 1, animValue)!;
        return Transform.scale(
          scale: scale,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
                color: AppColors.backgroungColor,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                border: Border.all(
                    width: .7, color: AppColors.primaryColor.withOpacity(.9))),
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.workoutName,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    WidgetUtils.formatTimestamp(workout.date),
                    style: const TextStyle(
                        color: AppColors.secondaryText, fontSize: 12),
                  )
                ],
              ),
            ),
          ),
        );
      },
      child: child,
    );
  }
}
