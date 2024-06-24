import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/helper/app_color.dart';
import 'package:workout_app/helper/providers/database_helper.dart';
import 'package:workout_app/routes/DashboardPage/workout_details.dart';

class FixedListView extends StatelessWidget {
  const FixedListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseHelper>(builder: (_, db, __) {
      return ListView.builder(
          itemCount: db.workouts.length,
          itemBuilder: ((context, index) {
            final workout = db.workouts[index];
            return Padding(
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
          }));
    });
  }
}
