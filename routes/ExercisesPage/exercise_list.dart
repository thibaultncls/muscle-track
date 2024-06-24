import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/helper/providers/database_helper.dart';
import 'package:workout_app/helper/widget_utils.dart';
import 'package:workout_app/widgets/listview_item.dart';

class ExerciseList extends StatefulWidget {
  const ExerciseList({super.key});

  @override
  State<ExerciseList> createState() => _ExerciseListState();
}

class _ExerciseListState extends State<ExerciseList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<DatabaseHelper>()
          .getExercises()
          .then((_) => setState(() {}));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseHelper>(builder: (_, db, __) {
      return ListView.builder(
        itemBuilder: (context, index) {
          final exercise = db.exercises[index];
          return ListViewItem(
            text: exercise.exerciseName,
            onTap: () =>
                WidgetUtils.showExerciseDetailBottomSheet(context, exercise),
          );
        },
        itemCount: db.exercises.length,
      );
    });
  }
}
