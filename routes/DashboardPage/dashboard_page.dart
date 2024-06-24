// ignore_for_file: slash_for_doc_comments

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/helper/app_color.dart';
import 'package:workout_app/helper/app_keys.dart';
import 'package:workout_app/helper/providers/database_helper.dart';
import 'package:workout_app/helper/providers/reorder_workouts.dart';
import 'package:workout_app/routes/DashboardPage/fixed_list_view.dart';
import 'package:workout_app/routes/DashboardPage/new_blank_workout.dart';
import 'package:workout_app/routes/DashboardPage/reorderable_list.dart';
import 'package:workout_app/widgets/page_title.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              size: 28,
            ),
            onPressed: () => Navigator.pushNamed(context, Keys.settingsPage),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Consumer<ReorderWorkouts>(builder: (_, reorder, __) {
                return IconButton(
                    onPressed: () {
                      reorder.isReordered = !reorder.isReordered;
                    },
                    icon: (!reorder.isReordered)
                        ? const Icon(
                            Icons.swap_vert_outlined,
                            size: 28,
                          )
                        : const Icon(
                            Icons.check,
                            size: 28,
                          ));
              }),
            )
          ],
          elevation: 0,
          backgroundColor: AppColors.backgroungColor,
          centerTitle: true,
          title: const PageTitle(text: 'Entraînements')),
      body: Container(
        color: AppColors.backgroungColor,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(left: 25, right: 25, top: 15),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const NewBlankWorkout();
                        });
                  },
                  style: ButtonStyle(
                      elevation: WidgetStateProperty.all(0),
                      padding: WidgetStateProperty.all(const EdgeInsets.only(
                          left: 50, right: 50, top: 10, bottom: 10)),
                      backgroundColor:
                          WidgetStateProperty.all(AppColors.buttonColor)),
                  child: const Text(
                    'Nouvel entraînement',
                    style: TextStyle(
                        color: AppColors.backgroungColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Consumer2<DatabaseHelper, ReorderWorkouts>(
                builder: (_, db, reorder, __) {
                  return Expanded(
                      child: (db.workouts.isEmpty)
                          ? const Center(
                              child: Text(
                                'Pas encore d\'entraînements',
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : (reorder.isReordered)
                              ? const ReorderableDashboardList()
                              : const FixedListView());
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
