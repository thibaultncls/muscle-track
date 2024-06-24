import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/helper/app_color.dart';
import 'package:workout_app/helper/app_style.dart';
import 'package:workout_app/helper/providers/database_helper.dart';
import 'package:workout_app/helper/widget_utils.dart';
import 'package:workout_app/model/exercise_workout_history_model.dart';
import 'package:workout_app/model/workout_history_model.dart';
import 'package:workout_app/widgets/grouped_list_elements.dart';

class DetailHistoryDialog extends StatefulWidget {
  final WorkoutHistoryModel workoutHistory;
  const DetailHistoryDialog({super.key, required this.workoutHistory});

  @override
  State<DetailHistoryDialog> createState() => _DetailHistoryDialogState();
}

class _DetailHistoryDialogState extends State<DetailHistoryDialog> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getExercisesWorkoutHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    // * The size of the widget
    final height = MediaQuery.of(context).size.height * 0.6;
    final width = MediaQuery.of(context).size.width * 0.9;

    final databaseHelper = Provider.of<DatabaseHelper>(context);
    final exercisesWorkout = databaseHelper.exerciseWorkoutHistory;

    return Dialog(
      child: Container(
        height: height,
        width: width,
        decoration: const BoxDecoration(
            color: AppColors.backgroungColor,
            borderRadius: BorderRadius.all(Radius.circular(14))),
        child: (_isLoading)
            ? _dataNotLoaded()
            : (exercisesWorkout.isEmpty)
                ? _emptyHistory()
                : _details(),
      ),
    );
  }

  // * Return an indiactor if the data are not loaded yet
  Widget _dataNotLoaded() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  // * Return a text if the list of exercises is empty
  Widget _emptyHistory() {
    return const Center(
      child: Text('Pas de données dans cet entraînement'),
    );
  }

  // * The widget with details of the exercises
  Widget _details() {
    final databaseHelper = Provider.of<DatabaseHelper>(context);
    final exercisesWorkout = databaseHelper.exerciseWorkoutHistory;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Text(
              widget.workoutHistory.workoutName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            WidgetUtils.formattedTime(widget.workoutHistory.duration),
            style: const TextStyle(color: AppColors.secondaryText),
          ),
          Expanded(
              child: GroupedListView(
            order: GroupedListOrder.ASC,
            groupSeparatorBuilder: (orderInList) =>
                WidgetUtils.groupSepatatorBuilder(
                    _getExerciceNameByOrder(exercisesWorkout, orderInList)),
            itemBuilder: (context, exercise) => ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: exercise.setsHistory!.length,
                itemBuilder: (context, index) {
                  final set = exercise.setsHistory![index];
                  return GroupedListElement(set: set, exercise: exercise);
                }),
            elements: exercisesWorkout,
            groupBy: (element) => element.orderInList,
          )),
          ElevatedButton(
              onPressed: () => _pop(),
              child: const Text(
                'OK',
                style: TextStyle(
                    color: AppColors.backgroungColor,
                    fontSize: AppStyle.averageTextSize,
                    fontWeight: AppStyle.fontWeight600),
              ))
        ],
      ),
    );
  }

  Future<void> _pop() async {
    Navigator.pop(context);
  }

  // * A function that load the exercises for the workout from the database
  Future<void> _getExercisesWorkoutHistory() async {
    final databaseHelper = Provider.of<DatabaseHelper>(context, listen: false);
    databaseHelper
        .getWorkoutExercisesHistory(widget.workoutHistory.id)
        .then((value) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  // Get the exercise name by their order
  String _getExerciceNameByOrder(
      List<ExerciseWorkoutHistoryModel> exercises, int orderInList) {
    final exercise =
        exercises.firstWhere((element) => element.orderInList == orderInList);
    return exercise.exerciseName;
  }
}
