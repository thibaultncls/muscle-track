import 'package:flutter/material.dart';
import 'package:logger/web.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_app/helper/app_keys.dart';
import 'package:workout_app/helper/providers/database_helper.dart';
import 'package:workout_app/helper/dialog_helper.dart';
import 'package:workout_app/helper/providers/workout_data_loaded.dart';
import 'package:workout_app/helper/providers/set_timer_model.dart';
import 'package:workout_app/helper/providers/workout_timer_model.dart';
import 'package:workout_app/model/abstarct_class/workouts.dart';
import 'package:workout_app/model/exercise_workout_model.dart';
import 'package:workout_app/model/set_model.dart';
import 'package:workout_app/helper/providers/metric_preferences.dart';
import 'package:workout_app/helper/providers/text_field_manager.dart';
import 'package:workout_app/routes/home_page.dart';

class WorkoutHelper {
  static Future<void> addSet(
      ExerciseWorkoutModel exerciseWorkout, BuildContext context) async {
    context
        .read<DatabaseHelper>()
        .addSetToExerciseWorkout(exerciseWorkout.exerciseWorkoutID)
        .then((set) {
      context.read<TextFieldManager>().addTextField(set.id);
    });
  }

  // Get the global index of all exercises and sets
  static int getGlobalSetIndex(
      int exerciseIndex, int setIndex, BuildContext context) {
    final exercises = context.read<DatabaseHelper>().exercisesWorkout;
    int globalIndex = 0;

    // Add all sets from previous exercises
    for (int i = 0; i < exerciseIndex; i++) {
      globalIndex += exercises[i].sets.length;
    }

    // Add the local index of the series in the current exercise
    globalIndex += setIndex;

    return globalIndex;
  }

  static Future<void> updateWorkout(
      BuildContext context, Workout workout) async {
    final db = context.read<DatabaseHelper>();
    final fieldManager = context.read<TextFieldManager>();
    final workoutTimer = context.read<WorkoutTimerModel>();
    final setTimer = context.read<SetTimerModel>();
    _updateSetsVariable(context);
    // Update the current workout
    db
        .updateWorkout(
            workout.id, db.exercisesWorkout, workoutTimer.elapsedTime)
        .then((_) {
      // Reset the controllers
      fieldManager.resetPreferences();

      // Add the workout in the history
      db.addWorkoutHistory(
          workout, db.exercisesWorkout, workoutTimer.elapsedTime, context);

      // Reset the timers

      workoutTimer.endWorkout();
      setTimer.resetTimer();

      // Check if the current page can pop
      if (Navigator.canPop(context)) {
        Navigator.pop(
            context, true // Return true to update the workouts in the HomePage
            );
      } else {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false //
            );
      }
    });
  }

  // * At the end of the workout, update the set with the data saved in controllers
  static _updateSetsVariable(BuildContext context) {
    // Providers
    final db = context.read<DatabaseHelper>();
    final fieldManager = context.read<TextFieldManager>();
    final metricPrefs = context.read<MetricPreferences>();

    for (var exercise in db.exercisesWorkout) {
      for (var set in exercise.sets) {
        final setID = set.id;

        _updateSetDouble(
            fieldManager.weightController(setID), set, (s, v) => s.weight = v);
        _updateSetDouble(fieldManager.repsController(setID), set,
            (s, v) => s.repetitions = v);
        if (metricPrefs.selectedMetric == PerformanceMetric.rir) {
          _updateSetDouble(fieldManager.performanceMetricController(setID), set,
              (s, v) => s.rir = v);
        } else {
          _updateSetDouble(fieldManager.performanceMetricController(setID), set,
              (s, v) => s.rpe = v);
        }
      }
    }
  }

  // * If the controller is not null and if he is not empty, update the double data of SetModel
  static void _updateSetDouble(TextEditingController controller, SetModel set,
      void Function(SetModel, double) setProperty) {
    if (controller.text.isNotEmpty) {
      double? newValue = double.tryParse(controller.text);
      if (newValue != null) {
        setProperty(set, newValue);
      }
    }
  }

  static void workoutFinished(BuildContext context, Workout workout) {
    final exercises = context.read<DatabaseHelper>().exercisesWorkout;
    final fieldManager = context.read<TextFieldManager>();
    bool hasEmptyTextField = false;
    for (var exercise in exercises) {
      for (var set in exercise.sets) {
        final setID = set.id;
        final weightController = fieldManager.weightController(setID);
        final repController = fieldManager.repsController(setID);

        if (weightController.text.isEmpty || repController.text.isEmpty) {
          hasEmptyTextField = true;
          Logger().d(hasEmptyTextField);
        }
      }
    }
    if (hasEmptyTextField) {
      DialogHelper.showEndWorkout(context, workout);
    } else {
      DialogHelper.showFinishedWorkout(context, workout);
    }
  }

  static void resetPrefs(BuildContext context) async {
    context.read<WorkoutTimerModel>().endWorkout();
    context.read<SetTimerModel>().resetTimer();
    context.read<TextFieldManager>().resetPreferences();
  }

  static Future<void> initWorkout(Workout workout, BuildContext context) async {
    final db = context.read<DatabaseHelper>();
    final fieldManag = context.read<TextFieldManager>();
    final workoutTimer = context.read<WorkoutTimerModel>();
    final setTimer = context.read<SetTimerModel>();
    final dataLoaded = context.read<WorkoutDataLoaded>();

    // load the exercises for the workout
    await db.getExerciseWorkout(workout.id);
    final exercisesWorkout = db.exercisesWorkout;

    final prefs = await SharedPreferences.getInstance();

    // load the data stored in preferences and init the textField values
    await fieldManag.loadAllData(exercisesWorkout);

    // start the timer for the workout
    workoutTimer.startWorkout(workout.id, workout.workoutName);

    // make _isLoading false to show the list of exercises
    dataLoaded.isLoaded = true;

    bool isWorkoutInProgress =
        prefs.getBool(Keys.isWorkoutInProgressKey) ?? false;

    // start the timer for the set
    if (!isWorkoutInProgress) {
      setTimer.startSet();
    }
  }
}
