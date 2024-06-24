import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/helper/app_color.dart';
import 'package:workout_app/helper/providers/database_helper.dart';
import 'package:workout_app/helper/widget_utils.dart';
import 'package:workout_app/widgets/listview_item.dart';
import 'package:workout_app/widgets/page_title.dart';

class BodyPartExercises extends StatefulWidget {
  final String bodyPart;
  const BodyPartExercises({super.key, required this.bodyPart});

  @override
  State<BodyPartExercises> createState() => _BodyPartExercisesState();
}

class _BodyPartExercisesState extends State<BodyPartExercises> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<DatabaseHelper>()
          .getBodyPartExercises(widget.bodyPart)
          .then((_) => setState(() {}));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: PageTitle(
            text: widget.bodyPart,
          ),
        ),
        body: Container(
            color: AppColors.backgroungColor,
            child: Consumer<DatabaseHelper>(builder: (_, db, __) {
              return ListView.builder(
                  itemCount: db.bodyPartExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = db.bodyPartExercises[index];
                    return ListViewItem(
                      text: exercise.exerciseName,
                      onTap: () => WidgetUtils.showExerciseDetailBottomSheet(
                          context, exercise),
                    );
                  });
            })));
  }
}
