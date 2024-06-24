import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/web.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_app/helper/app_keys.dart';
import 'package:workout_app/helper/lifecycle_helper.dart';

class SetTimerModel extends ChangeNotifier {
  Timer? _timer;
  int _elapsedTime = 0;
  late SharedPreferences _prefs;
  final _logger = Logger();

  // keys for the preferences

  SetTimerModel() {
    _loadPreferences();
    WidgetsBinding.instance.addObserver(LifecycleEventHandler(
        detachedCallBack: () async => _saveTimer(),
        resumeCallBack: () async => _loadPreferences()));
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();

    // check if a workout is started
    bool isWorkoutInProgress =
        _prefs.getBool(Keys.isWorkoutInProgressKey) ?? false;

    // if a workout is started calculate the difference between the last save and now
    if (isWorkoutInProgress) {
      int setBeginning =
          _prefs.getInt(Keys.startSet) ?? DateTime.now().millisecondsSinceEpoch;

      int lastSavedTime = _prefs.getInt(Keys.setSavedTime) ??
          DateTime.now().millisecondsSinceEpoch;

      _elapsedTime = ((lastSavedTime - setBeginning) +
          (DateTime.now().millisecondsSinceEpoch - lastSavedTime));

      _logger.d('Elapsed time recalculated: $_elapsedTime ms since last start');
    }

    if (_timer == null || !_timer!.isActive) {
      _startTimer();
    }
    notifyListeners();
  }

  int get elapsedTime => _elapsedTime;

  void _startTimer() {
    const oneMilli = Duration(milliseconds: 1);
    _timer?.cancel();

    _timer = Timer.periodic(oneMilli, (timer) {
      _elapsedTime++;
      notifyListeners();
    });
  }

  // reset the preferences at the beginning of a set
  Future<void> startSet() async {
    await _prefs.setInt(Keys.startSet, DateTime.now().millisecondsSinceEpoch);
    _startTimer();
  }

  Future<void> resetTimer() async {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
      _timer = null;
      notifyListeners();
    }
    _elapsedTime = 0;
    notifyListeners();

    await _prefs.remove(Keys.startSet);
    await _prefs.remove(Keys.setSavedTime);
  }

  void _saveTimer() async {
    if (_timer != null && _timer!.isActive) {
      int now = DateTime.now().millisecondsSinceEpoch;

      await _prefs.setInt(Keys.setSavedTime, now);
      Logger().d('Set timer saved');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
