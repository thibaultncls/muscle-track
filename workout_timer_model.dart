import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/web.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_app/helper/app_keys.dart';
import 'package:workout_app/helper/lifecycle_helper.dart';

class WorkoutTimerModel extends ChangeNotifier {
  Timer? _timer;
  int _elapsedTime = 0;
  late SharedPreferences _preferences;

  // Keys for the preferences

  WorkoutTimerModel() {
    _loadPreferences();
    WidgetsBinding.instance.addObserver(LifecycleEventHandler(
        detachedCallBack: () async => _saveTimer(),
        resumeCallBack: () async => _loadPreferences()));
  }

  Future<void> _loadPreferences() async {
    _preferences = await SharedPreferences.getInstance();
    bool isWorkoutInProgress =
        _preferences.getBool(Keys.isWorkoutInProgressKey) ?? false;

    // Only start the Timer if a workout is in progress
    if (isWorkoutInProgress) {
      int workoutBeginning = _preferences.getInt(Keys.startTime) ??
          DateTime.now().microsecondsSinceEpoch;
      int lastSavedTime = _preferences.getInt(Keys.workoutSavedTime) ??
          DateTime.now().millisecondsSinceEpoch;

      _elapsedTime = ((lastSavedTime - workoutBeginning) +
              (DateTime.now().millisecondsSinceEpoch - lastSavedTime)) ~/
          1000;
    }

    // Only start the Timer if it is not already active
    if (_timer == null || !_timer!.isActive) {
      _startTimer();
    }
    notifyListeners();
  }

  int get elapsedTime => _elapsedTime;

  // Start the timer at the beginning of the workout
  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    //_timer?.cancel();
    _timer = Timer.periodic(oneSec, (timer) {
      _elapsedTime++;
      notifyListeners();
    });
  }

  Future<void> _resetTimer() async {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
      _timer = null;
      notifyListeners();
    }
    _elapsedTime = 0;
    notifyListeners();

    // Reset the values ​​in SharedPreferences
    await _preferences.setInt(
        Keys.startTime, DateTime.now().millisecondsSinceEpoch);
  }

  @override
  void dispose() {
    _timer?.cancel();

    super.dispose();
  }

  void _saveTimer() async {
    await _preferences.setInt(
        Keys.workoutSavedTime, DateTime.now().millisecondsSinceEpoch);
    Logger().d('Workout timer saved');
  }

  Future<void> startWorkout(int workoutID, String workoutName) async {
    _loadPreferences();
    _preferences = await SharedPreferences.getInstance();
    bool isWorkoutInProgress =
        _preferences.getBool(Keys.isWorkoutInProgressKey) ?? false;

    await _preferences.setBool(Keys.isWorkoutInProgressKey, true);
    await _preferences.setInt(Keys.currentWorkoutID, workoutID);
    await _preferences.setString(Keys.currentWorkoutName, workoutName);

    if (!isWorkoutInProgress) {
      await _preferences.setInt(
          Keys.startTime, DateTime.now().millisecondsSinceEpoch);
    }
  }

  Future<void> endWorkout() async {
    _resetTimer();
    await _preferences.setBool(Keys.isWorkoutInProgressKey, false);
    await _preferences.remove(Keys.currentWorkoutID);
    await _preferences.remove(Keys.currentWorkoutName);
  }
}
