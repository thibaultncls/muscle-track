import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/helper/app_color.dart';
import 'package:workout_app/helper/providers/add_exercise.dart';
import 'package:workout_app/helper/providers/database_helper.dart';
import 'package:workout_app/helper/providers/search_exercise.dart';
import 'package:workout_app/model/exercise_workout_model.dart';
import 'package:workout_app/widgets/new_exercise_item.dart';
import 'package:workout_app/widgets/new_exercises_row.dart';

class ExercisesListForWorkout extends StatefulWidget {
  final Widget addButton;
  const ExercisesListForWorkout({super.key, required this.addButton});

  @override
  State<ExercisesListForWorkout> createState() =>
      _ExercisesListForWorkoutState();
}

class _ExercisesListForWorkoutState extends State<ExercisesListForWorkout> {
  List<ExerciseWorkoutModel> newAddedExercises = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DatabaseHelper>().getExercises().then((_) {
        context.read<AddExercise>().initAddedExercises();
        setState(() {});
      });
    });
    context.read<SearchExercise>().addControllerListener();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;

    return Dialog(
      child: Container(
        height: height * 0.8,
        width: width * 0.95,
        decoration: BoxDecoration(
            color: AppColors.backgroungColor,
            borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Padding(
                  padding: EdgeInsets.only(left: 5, right: 5, top: 5),
                  child: NewExercisesRow()),
              Consumer<SearchExercise>(builder: (_, search, __) {
                return TextField(
                  controller: search.controller,
                  decoration: InputDecoration(
                      hintText: 'Rechercher',
                      suffixIcon: (search.controller.text.isNotEmpty)
                          ? IconButton(
                              onPressed: () => search.clearTextField(),
                              icon: const Icon(Icons.cancel_outlined))
                          : null),
                );
              }),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Consumer<AddExercise>(
                    builder: (_, value, __) {
                      return Text(
                          'Exercice(s) dans cette séance : ${value.totalExercise.length}');
                    },
                  )),
              Consumer<SearchExercise>(builder: (_, search, __) {
                final exercises = search.searchedExercises();

                return Expanded(
                    child: ListView.builder(
                  itemBuilder: ((context, index) {
                    final filteredExercise = exercises[index];
                    return NewExerciseItem(exercise: filteredExercise);
                  }),
                  itemCount: exercises.length,
                ));
              }),
              Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 5),
                  child: widget.addButton),
            ],
          ),
        ),
      ),
    );
  }
}
