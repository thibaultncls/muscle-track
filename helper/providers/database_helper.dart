// ignore_for_file: slash_for_mments

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/web.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:workout_app/helper/providers/add_exercise.dart';
import 'package:workout_app/helper/providers/search_exercise.dart';
import 'package:workout_app/model/abstarct_class/workouts.dart';
import 'package:workout_app/model/exercise_model.dart';
import 'package:workout_app/model/exercise_performance.dart';
import 'package:workout_app/model/exercise_workout_history_model.dart';
import 'package:workout_app/model/exercise_workout_model.dart';
import 'package:workout_app/model/set_model.dart';
import 'package:workout_app/model/sets_history_model.dart';
import 'package:workout_app/model/workout_detail_model.dart';
import 'package:workout_app/model/workout_history_model.dart';
import 'package:workout_app/model/workout_model.dart';
import 'package:workout_app/helper/providers/metric_preferences.dart';
import 'package:workout_app/helper/providers/text_field_manager.dart';

class DatabaseHelper with ChangeNotifier {
  static const _dbName = "workoutdb.db";
  static const _dbVersion = 2;

  DatabaseHelper._privateConstructor() {
    _initDatabase();
  }
  static DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Database? _database;

  List<WorkoutModel> _workouts = [];
  // Get last workouts
  List<WorkoutModel> get workouts => _workouts;

  List<ExerciseModel> _exercises = [];
  // Get all the exercises
  List<ExerciseModel> get exercises => _exercises;

  List<ExerciseWorkoutModel> _exercisesWorkout = [];
  // Get all the exercises for the specific workout
  List<ExerciseWorkoutModel> get exercisesWorkout => _exercisesWorkout;

  List<SetModel> _sets = [];
  // Get the sets for the specific exercise
  List<SetModel> get sets => _sets;

  List<WorkoutHistoryModel> _workoutHistory = [];
  // Get the workouts history
  List<WorkoutHistoryModel> get workoutHistory => _workoutHistory;

  List<ExerciseWorkoutHistoryModel> _exerciseWorkoutHistory = [];
  // Get the history of exercises for specific workout
  List<ExerciseWorkoutHistoryModel> get exerciseWorkoutHistory =>
      _exerciseWorkoutHistory;

  // Variable for the sets of specific exercise
  List<SetsHistoryModel> _setsHistory = [];

  List<ExercisePerformance> _exercisesPerformance = [];
  // Get the performances for a specific exericse
  List<ExercisePerformance> get exercisesPerformance => _exercisesPerformance;

  List<ExerciseModel> _bodyPartExercises = [];
  // Get the exercises for a specific body part
  List<ExerciseModel> get bodyPartExercises => _bodyPartExercises;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _dbName);

    var exists = await databaseExists(path);

    if (!exists) {
      ByteData data = await rootBundle.load(join("assets", _dbName));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await File(path).writeAsBytes(bytes);
    }
    return await openDatabase(path,
        version: _dbVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS Exercises (
      ExerciseID INTEGER PRIMARY KEY,
      ExerciseName TEXT,
      Description TEXT,
      BodyPart TEXT,
      Category TEXT,
      ImagePath TEXT,
      Setup TEXT
    );
    ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS Workouts (
      WorkoutID INTEGER PRIMARY KEY,
      Date INTEGER,
      UserID TEXT,
      Duration INTEGER,
      WorkoutName TEXT,
      OrderInList INTEGER
    );
    ''');

    await db.execute('''
  CREATE TABLE IF NOT EXISTS ExercisesWorkout (
    ExerciseWorkoutID INTEGER PRIMARY KEY,
    WorkoutID INTEGER,
    ExerciseID INTEGER,
    Setup TEXT,
    FOREIGN KEY (WorkoutID) REFERENCES Workouts(WorkoutID),
    FOREIGN KEY (ExerciseID) REFERENCES Exercises(ExerciseID)
);
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS Sets (
  SetID INTEGER PRIMARY KEY,
  ExerciseWorkoutID INTEGER,
  SetNumber INTEGER,
  Repetitions REAL,
  Weight REAL,
  Note TEXT,
  RIR REAL,
  RER REAL,
  FOREIGN KEY (ExerciseWorkoutID) REFERENCES ExercisesWorkout(ExerciseWorkoutID)
);
''');
    await db.execute('''
    CREATE TABLE IF NOT EXISTS ExercisesWorkoutHistory (
      ExerciseWorkoutHistoryID INTEGER PRIMARY KEY,
	    HistoryID	INTEGER,
	    ExerciseID	INTEGER,
	    ExerciseName	TEXT,
	    OrderInList	INTEGER,
	    Setup	TEXT,
	  FOREIGN KEY(ExerciseID) REFERENCES Exercises(ExerciseID),
	  FOREIGN KEY(HistoryID) REFERENCES WorkoutHistory(HistoryID)
    );
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS WorkoutHistory (
	      HistoryID	INTEGER PRIMARY KEY,
	      WorkoutID	INTEGER,
	      Date	INTEGER,
	      Duration	INTEGER,
	      WorkoutName	TEXT,
	      FOREIGN KEY(WorkoutID) REFERENCES Workouts(WorkoutID)
        );
      ''');
    await db.execute('''
    CREATE TABLE IF NOT EXISTS SetsHistory (
	    SetHistoryID	INTEGER PRIMARY KEY,
	    ExerciseWorkoutHistoryID	INTEGER,
	    SetNumber	INTEGER,
	    Repetitions	REAL,
	    Weight	REAL,
	    Note	TEXT,
	    RIR	REAL,
	    RPE	REAL,
	  FOREIGN KEY(ExerciseWorkoutHistoryID) REFERENCES ExercisesWorkoutHistory(ExerciseWorkoutHistoryID)
);
      ''');
  }

  // ! Update this function when the database is updgraded
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE ExercisesWorkout ADD COLUMN Setup TEXT;');
      await db.execute('ALTER TABLE Exercises ADD COLUMN Setup TEXT;');
      await db.execute(
          'ALTER TABLE ExercisesWorkoutHistory ADD COLUMN Setup TEXT;');
    }
  }

  Future<void> getExercises() async {
    final db = await database;
    final List<Map<String, dynamic>> exercises =
        await db.query('Exercises', orderBy: 'ExerciseName ASC');

    List<ExerciseModel> exerisesModel =
        exercises.map((e) => ExerciseModel.fromMap(e)).toList();

    _exercises = exerisesModel;
    // notifyListeners();
  }

  Future<void> getWorkouts() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.rawQuery('''
    SELECT 
      W.WorkoutID, 
      W.Date, 
      W.WorkoutName, 
      W.OrderInList, 
      E.ExerciseName, 
      COUNT(S.SetID) as SetCount
    FROM Workouts W
    LEFT JOIN ExercisesWorkout EW ON W.WorkoutID = EW.WorkoutID
    LEFT JOIN Exercises E ON EW.ExerciseID = E.ExerciseID
    LEFT JOIN Sets S ON EW.ExerciseWorkoutID = S.ExerciseWorkoutID
    GROUP BY W.WorkoutID, E.ExerciseName
    ORDER BY W.OrderInList ASC, EW.OrderInList ASC, S.SetNumber ASC
  ''');

    Map<int, WorkoutModel> workoutsMap = {};
    for (var result in results) {
      int workoutID = result['WorkoutID'];
      if (!workoutsMap.containsKey(workoutID)) {
        workoutsMap[workoutID] = WorkoutModel(
            id: workoutID,
            date: result['Date'],
            workoutName: result['WorkoutName'],
            orderInList: result['OrderInList'],
            details: []);
      }
      if (result['ExerciseName'] != null) {
        workoutsMap[workoutID]!.details!.add(WorkoutDetailModel(
            exerciseName: result['ExerciseName'],
            setCount: result['SetCount']));
      }
    }

    _workouts = workoutsMap.values.toList();
    notifyListeners();
  }

  Future<void> getWorkoutHistories() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.rawQuery('''
    SELECT 
      WH.HistoryID,
      WH.WorkoutID,
      WH.Date,
      WH.Duration,
      WH.WorkoutName,
      E.ExerciseName,
      COUNT(S.SetHistoryID) as SetCount
    FROM WorkoutHistory WH
    LEFT JOIN ExercisesWorkoutHistory EWH ON WH.HistoryID = EWH.HistoryID
    LEFT JOIN Exercises E ON EWH.ExerciseID = E.ExerciseID
    LEFT JOIN SetsHistory S ON EWH.ExerciseWorkoutHistoryID = S.ExerciseWorkoutHistoryID
    GROUP BY WH.HistoryID, E.ExerciseName
    ORDER BY WH.Date DESC, EWH.OrderInList ASC
    ''');

    Map<int, WorkoutHistoryModel> workoutHistoriesMap = {};
    for (var result in results) {
      int historyID = result['HistoryID'];
      if (!workoutHistoriesMap.containsKey(historyID)) {
        workoutHistoriesMap[historyID] = WorkoutHistoryModel(
            id: historyID,
            workoutID: result['WorkoutID'],
            date: result['Date'],
            duration: result['Duration'],
            workoutName: result['WorkoutName'],
            details: []);
      }

      // var logger = Logger();
      // logger.d(result);

      if (result['ExerciseName'] != null) {
        workoutHistoriesMap[historyID]!.details!.add(WorkoutDetailModel(
            exerciseName: result['ExerciseName'],
            setCount: result['SetCount']));
      }
    }

    _workoutHistory = workoutHistoriesMap.values.toList();
    notifyListeners();
  }

  // * A function that fetch the exercises for the specific workout history

  Future<void> getWorkoutExercisesHistory(int workoutHistoryID) async {
    final db = await database;
    final results = await db.rawQuery('''
    SELECT 
    E.ExerciseID,
    E.ExerciseName,
    E.Bodypart,
    E.Setup as DefaultSetup,
    E.Description,
    EWH.ExerciseWorkoutHistoryID,
    EWH.OrderInList,
    EWH.Setup as ExerciseSetup
    FROM ExercisesWorkoutHistory EWH
    INNER JOIN Exercises E ON E.ExerciseID = EWH.ExerciseID
    WHERE EWH.HistoryID = ?
    ORDER BY EWH.OrderInList ASC
    ''', [workoutHistoryID]);

    Map<int, ExerciseWorkoutHistoryModel> exercisesHisotryMap = {};

    for (var result in results) {
      final exerciseWorkoutHistoryID =
          result['ExerciseWorkoutHistoryID'] as int;

      String? effectiveSetup = result['ExerciseSetup'] as String? ??
          result['DefaultSetup'] as String?;

      // If the map does not contain the ID of a exercise then add the exercise
      if (!exercisesHisotryMap.containsKey(exerciseWorkoutHistoryID)) {
        exercisesHisotryMap[exerciseWorkoutHistoryID] =
            ExerciseWorkoutHistoryModel.fromMap(result, effectiveSetup, []);
      }

      // Add the list of sets in the class
      await getSetsHistory(exerciseWorkoutHistoryID);
      exercisesHisotryMap[exerciseWorkoutHistoryID]!.setsHistory = _setsHistory;
    }

    _exerciseWorkoutHistory = exercisesHisotryMap.values.toList();
    notifyListeners();
  }

  Future<void> getSetsHistory(int exerciseWorkoutHistoryID) async {
    final db = await database;
    var setsHistory = await db.query('SetsHistory',
        where: 'ExerciseWorkoutHistoryID = ?',
        whereArgs: [exerciseWorkoutHistoryID],
        orderBy: 'SetNumber ASC');

    List<SetsHistoryModel> setsHistoryModel =
        setsHistory.map((e) => SetsHistoryModel.fromMap(e)).toList();
    _setsHistory = setsHistoryModel;
    notifyListeners();
  }

  Future<WorkoutModel?> getCurrentWorkout(int workoutID) async {
    final db = await database;
    var result = await db
        .query('Workouts', where: 'WorkoutID = ?', whereArgs: [workoutID]);
    if (result.isNotEmpty) {
      return WorkoutModel.fromMap(result.first);
    }
    return null;
  }

  Future<void> getSets(int exerciseWorkoutID) async {
    final db = await database;
    var sets = await db.query('Sets',
        where: 'ExerciseWorkoutID = ?',
        whereArgs: [exerciseWorkoutID],
        orderBy: 'SetNumber ASC');

    List<SetModel> setsModel = sets.map((e) => SetModel.fromMap(e)).toList();
    _sets = setsModel;

    notifyListeners();
  }

  Future<void> getBodyPartExercises(String bodyPart) async {
    final db = await database;
    final results = await db.query('Exercises',
        where: 'BodyPart = ?',
        whereArgs: [bodyPart],
        orderBy: 'ExerciseName ASC');

    List<ExerciseModel> exercises =
        results.map((e) => ExerciseModel.fromMap(e)).toList();
    _bodyPartExercises = exercises;
  }

  Future<void> getExerciseWorkout(int workoutID) async {
    final db = await database;

    final results = await db.rawQuery('''
      SELECT 
      e.ExerciseID,
      e.ExerciseName,
      e.BodyPart,
      e.Description,
      e.Setup as DefaultSetup,
      ew.ExerciseWorkoutID,
      ew.OrderInList,
      ew.Setup as WorkoutSpecificSetup
      FROM ExercisesWorkout ew
      INNER JOIN Exercises e ON e.ExerciseID = ew.ExerciseID
      WHERE ew.WorkoutID = ?
      ORDER BY ew.OrderInList ASC
      ''', [workoutID]);

    Map<int, ExerciseWorkoutModel> exercisesMap = {};

    for (var result in results) {
      final exerciseWorkoutID = result['ExerciseWorkoutID'] as int;
      String? effectiveSetup = result['WorkoutSpecificSetup'] as String? ??
          result['DefaultSetup'] as String?;

      if (!exercisesMap.containsKey(exerciseWorkoutID)) {
        exercisesMap[exerciseWorkoutID] =
            ExerciseWorkoutModel.fromMap(result, effectiveSetup, []);
      }

      // Fetch and assign sets to this exercise workout
      await getSets(exerciseWorkoutID);
      exercisesMap[exerciseWorkoutID]!.sets = _sets;
    }
    _exercisesWorkout = exercisesMap.values.toList();
    notifyListeners();
  }

  Future<void> getPerformanceByExercise(int exerciseID) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT
        WH.Date AS WorkoutDate,
        E.ExerciseName,
        EWH.ExerciseWorkoutHistoryID,
        SH.SetNumber,
        SH.SetHistoryID,
        SH.Repetitions,
        SH.Weight,
        SH.Note,
        SH.RIR,
        SH.RPE
      FROM
        WorkoutHistory WH
      JOIN 
      ExercisesWorkoutHistory EWH ON WH.HistoryID = EWH.HistoryID
    JOIN 
      Exercises E ON EWH.ExerciseID = E.ExerciseID
    JOIN 
      SetsHistory SH ON EWH.ExerciseWorkoutHistoryID = SH.ExerciseWorkoutHistoryID
    WHERE
      E.ExerciseID = ?
    ORDER BY
      WH.Date, EWH.ExerciseWorkoutHistoryID, SH.SetNumber DESC
      ''', [exerciseID]);

    List<ExercisePerformance> performances = [];

    for (var map in result) {
      // Retrieve the int WorkoutDate of the result
      int workoutDateInSeconds = map['WorkoutDate'] as int;
      DateTime workoutDate =
          DateTime.fromMillisecondsSinceEpoch(workoutDateInSeconds * 1000);
      ExercisePerformance performance = ExercisePerformance.fromMap(map)
        ..workoutDate = workoutDate;
      performances.add(performance);
    }
    _exercisesPerformance = performances;
    notifyListeners();
  }

  Future<void> addWorkoutHistory(
      Workout workout,
      List<ExerciseWorkoutModel> exercisesWorkout,
      int duration,
      BuildContext context) async {
    // Table name
    String workoutHistoryTable = 'WorkoutHistory';
    String exerciseHistoryTable = 'ExercisesWorkoutHistory';
    String setHistoryTable = 'SetsHistory';

    // bool to check witch preferences is currently active
    final metricPreferences = context.read<MetricPreferences>();
    bool isRIR = metricPreferences.selectedMetric == PerformanceMetric.rir;

    final tfm = context.read<TextFieldManager>();

    // Current date
    final now = DateTime.now();
    int date = now.millisecondsSinceEpoch ~/ 1000;
    final db = await database;

    await db.transaction((txn) async {
      // Create object WorkoutHistoryModel with data of WorkoutModel
      WorkoutHistoryModel workoutHistory = WorkoutHistoryModel(
          id: 0, // The database will handle the ID
          workoutID: workout.id,
          date: date,
          duration: duration,
          workoutName: workout.workoutName);

      // Add the workout history
      int historyID =
          await txn.insert(workoutHistoryTable, workoutHistory.toMap());

      // Add the details for the workout
      for (var exerciseWorkout in exercisesWorkout) {
        ExerciseWorkoutHistoryModel exerciseHistory =
            ExerciseWorkoutHistoryModel(
                exerciseWorkoutHistoryID: 0, // Handle by the database
                bodyPart: exerciseWorkout.bodyPart,
                description: exerciseWorkout.description,
                orderInList: exerciseWorkout.orderInList,
                historyID: historyID,
                exerciseID: exerciseWorkout.exerciseID,
                exerciseName: exerciseWorkout.exerciseName);

        // For every exercises in the workout, add the exercise
        int exerciseHistoryID =
            await txn.insert(exerciseHistoryTable, exerciseHistory.toMap());

        // Add sets for every exercise
        for (var set in exerciseWorkout.sets) {
          final int setID = set.id;

          // Check if the controllers have data to save or not the note
          bool isSetHasData =
              (tfm.repDouble(setID) != null && tfm.weightDouble(setID) != null);

          SetsHistoryModel setHistory = SetsHistoryModel(
              setHistoryID: 0, // Handle by the database
              exerciseWorkoutHistoryID: exerciseHistoryID,
              setNumber: set.setNumber,
              repetitions: tfm.repDouble(setID),
              weight: tfm.weightDouble(setID),
              note: (isSetHasData) ? set.note : null,
              rir: (isRIR) ? tfm.perfDouble(setID) : null,
              rpe: (!isRIR) ? tfm.perfDouble(setID) : null);

          // Add every set in the database
          await txn.insert(setHistoryTable, setHistory.toMap());
        }
      }
    });
    notifyListeners();
  }

  // * Rename the workout
  Future<void> renameWorkout(String workoutName, int workoutID) async {
    final db = await database;

    // Update the name of the workout
    await db.update('Workouts', {'WorkoutName': workoutName},
        where: 'WorkoutID = ?', whereArgs: [workoutID]);

    // locally update the workout name
    WorkoutModel changedWorkout =
        _workouts.firstWhere((workout) => workout.id == workoutID);
    changedWorkout.workoutName = workoutName;
    notifyListeners();
  }

  Future<int> countExercisesInWorkout(int workoutID) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('ExercisesWorkout',
        columns: ['COUNT(*) as count'],
        where: 'WorkoutID = ?',
        whereArgs: [workoutID]);

    return result.first['count'] as int;
  }

  Future<void> deleteWorkout(Workout workoutModel) async {
    final db = await database;
    final workoutID = workoutModel.id;

    await db.delete('Workouts', where: 'WorkoutID = ?', whereArgs: [workoutID]);
    _workouts.removeWhere((workout) => workout.id == workoutID);

    notifyListeners();
  }

  Future<void> deleteSet(int setID, int exerciseWorkoutID, int workoutID,
      BuildContext context) async {
    final db = await database;

    //Find the set to delete
    List<Map<String, dynamic>> setsToDelete = await db.query('Sets',
        columns: ['SetNumber'],
        where: 'SetID = ? AND ExerciseWorkoutID = ?',
        whereArgs: [setID, exerciseWorkoutID]);

    if (setsToDelete.isNotEmpty) {
      int setNumberToDelete = setsToDelete.first['SetNumber'];

      // Delete the set
      await db.delete('Sets', where: 'SetID = ?', whereArgs: [setID]);

      // Update all the next sets
      List<Map<String, dynamic>> setsToUpdate = await db.query('Sets',
          where: 'SetNumber > ? AND ExerciseWorkoutID = ?',
          whereArgs: [setNumberToDelete, exerciseWorkoutID],
          orderBy: 'SetNumber ASC');

      for (var set in setsToUpdate) {
        int currentSetNumber = set['SetNumber'];
        int newSetNumber = currentSetNumber - 1;

        await db.update('Sets', {'SetNumber': newSetNumber},
            where: 'SetID = ?', whereArgs: [set['SetID']]);
      }
    }

    // Remove localy the set and update the numbers
    final currentExercise = _exercisesWorkout.firstWhere(
        (element) => element.exerciseWorkoutID == exerciseWorkoutID);
    final set =
        currentExercise.sets.firstWhere((element) => element.id == setID);

    currentExercise.sets.removeWhere(
      (element) => element.id == setID,
    );
    for (var setModel in currentExercise.sets) {
      if (setModel.setNumber > set.setNumber) {
        setModel.setNumber -= 1;
      }
    }

    if (currentExercise.sets.isEmpty) {
      removeExerciseFromWorkout(workoutID, currentExercise.exerciseID, context);
    }
    notifyListeners();
  }

  Future<void> updateWorkoutOrder(int oldIndex, int newIndex) async {
    final db = await database;
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _workouts.removeAt(oldIndex);
    _workouts.insert(newIndex, item);
    await db.transaction((txn) async {
      for (int i = 0; i < _workouts.length; i++) {
        final workout = _workouts[i];
        await txn.update('Workouts', {'OrderInList': i},
            where: 'WorkoutID = ?', whereArgs: [workout.id]);
      }
    });

    notifyListeners();
  }

  Future<void> updateExerciseInWorkoutOrder(int oldIndex, int newIndex) async {
    final db = await database;

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final item = exercisesWorkout.removeAt(oldIndex);
    exercisesWorkout.insert(newIndex, item);
    await db.transaction((txn) async {
      for (int i = 0; i < exercises.length; i++) {
        final exercise = _exercisesWorkout[i];
        await txn.update('ExercisesWorkout', {'OrderInList': i},
            where: 'ExerciseWorkoutID = ?',
            whereArgs: [exercise.exerciseWorkoutID]);
      }
    });
    notifyListeners();
  }

  Future<void> updateWorkout(int workoutID,
      List<ExerciseWorkoutModel> exercisesWorkout, int elapsedTime) async {
    // Init the current date
    final now = DateTime.now();
    int timestamp = now.millisecondsSinceEpoch ~/ 1000;

    final db = await database;

    // Update the Workouts table
    await db.update('Workouts', {'Duration': elapsedTime, 'Date': timestamp},
        where: 'WorkoutID = ?', whereArgs: [workoutID]);

    // Update every set of every set in the workout
    for (ExerciseWorkoutModel exercise in exercisesWorkout) {
      for (SetModel set in exercise.sets) {
        await db.update(
            'Sets',
            {
              'Repetitions': set.repetitions,
              'Weight': set.weight,
              'RIR': set.rir,
              'RPE': set.rpe
            },
            where: 'SetID = ?',
            whereArgs: [set.id]);
      }
    }

    notifyListeners();
  }

  // Update the field Setup for all the exercises
  Future<void> updateExerciseSetup(int exerciseID, String setup) async {
    final db = await database;

    if (setup.isNotEmpty) {
      await db.update('Exercises', {'Setup': setup},
          where: 'ExerciseID = ?', whereArgs: [exerciseID]);
    } else {
      await db.update('Exercises', {'Setup': null},
          where: 'ExerciseID = ?', whereArgs: [exerciseID]);
    }

    final updatedExercise = _exercisesWorkout
        .firstWhere((element) => element.exerciseID == exerciseID);

    // if updatedExercise is not null, update it to null because when the workout will be reloaded
    // he will take the Setup of ExercisesWorkout and not of that Exercises
    if (updatedExercise.setup != null) {
      await db.update('ExercisesWorkout', {'Setup': null},
          where: 'ExerciseID = ?', whereArgs: [exerciseID]);
    }

    (setup.isNotEmpty)
        ? updatedExercise.setup = setup
        : updatedExercise.setup = null;

    notifyListeners();
  }

  //Update the field Setup only for this Workout
  Future<void> updateExerciseWorkoutSetup(int exerciseID, String setup) async {
    final db = await database;

    if (setup.isNotEmpty) {
      await db.update('ExercisesWorkout', {'Setup': setup},
          where: 'ExerciseID = ?', whereArgs: [exerciseID]);
    } else {
      await db.update('ExercisesWorkout', {'Setup': null},
          where: 'ExerciseID = ?', whereArgs: [exerciseID]);
    }

    final updatedExercise = _exercisesWorkout
        .firstWhere((element) => element.exerciseID == exerciseID);

    (setup.isNotEmpty)
        ? updatedExercise.setup = setup
        : updatedExercise.setup = null;

    notifyListeners();
  }

  // Update the current note
  Future<void> updateNote(int setID, String note) async {
    final db = await database;

    // If the controller is empty, set the value to null
    String? noteText = (note.isNotEmpty) ? note : null;

    await db.update('Sets', {'Note': noteText},
        where: 'SetID = ?', whereArgs: [setID]);

    final exercise = _exercisesWorkout
        .firstWhere((element) => element.sets.any((set) => set.id == setID));
    final updatedSet = exercise.sets.firstWhere((set) => set.id == setID);

    updatedSet.note = noteText;

    notifyListeners();
  }

  Future<WorkoutModel> addWorkout(String name) async {
    final db = await database;
    final date = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int workoutID = 0;
    int orderInList = 0;

    await db.transaction((txn) async {
      await txn
          .rawUpdate('''UPDATE Workouts SET OrderInList = OrderInList + 1''');

      workoutID = await txn.insert('Workouts', {
        'WorkoutName': name,
        'Date': date,
        'OrderInList': orderInList,
      });
    });

    WorkoutModel newWorkout = WorkoutModel(
        id: workoutID,
        date: date,
        workoutName: name,
        orderInList: orderInList,
        details: []);

    _workouts.add(newWorkout);
    notifyListeners();

    return newWorkout;
  }

  Future<ExerciseModel> addExercise(String name, String bodyPart) async {
    final db = await database;

    final exerciseID = await db
        .insert('Exercises', {'ExerciseName': name, 'BodyPart': bodyPart});
    ExerciseModel exerciseModel = ExerciseModel(
        exerciseID: exerciseID, exerciseName: name, bodyPart: bodyPart);
    notifyListeners();
    _exercises.add(exerciseModel);
    _exercises.sort(
      (a, b) => a.exerciseName.compareTo(b.exerciseName),
    );
    return exerciseModel;
  }

  Future<ExerciseWorkoutModel> _addExerciseToWorkout(
      int workoutID, int exerciseID) async {
    final db = await database;

    // Get exercise name and the body part from the 'Exercises' table
    final exerciseResult = await db
        .query('Exercises', where: 'ExerciseID = ?', whereArgs: [exerciseID]);
    String exerciseName = exerciseResult.first['ExerciseName'] as String;
    String bodyPart = exerciseResult.first['BodyPart'] as String;
    String? descrption = exerciseResult.first['Description'] as String?;

    //Retrieves the current number of exercises in the workout to set the new order
    final orderResult = await db.query('ExercisesWorkout',
        columns: ['MAX(OrderInList) as maxOrder'],
        where: 'WorkoutID = ?',
        whereArgs: [workoutID]);

    int maxOrder = orderResult.first['maxOrder'] != null
        ? orderResult.first['maxOrder'] as int
        : 0;
    int nextOrder = maxOrder + 1;

    //Check if the exercise is already linked to the wokout
    final existingLink = await db.query('ExercisesWorkout',
        where: 'WorkoutID = ? AND ExerciseID = ?',
        whereArgs: [workoutID, exerciseID]);

    int exerciseWorkoutID;

    //If the exercise is not already linked, add it and retrieve its ID
    if (existingLink.isEmpty) {
      exerciseWorkoutID = await db.insert('ExercisesWorkout', {
        'WorkoutID': workoutID,
        'ExerciseID': exerciseID,
        'OrderInList': nextOrder
      });
    } else {
      exerciseWorkoutID = existingLink.first['ExerciseWorkoutID'] as int;
    }

    //Add a default Set for this exercise in this workout
    int setID = await db.insert('Sets', {
      'ExerciseWorkoutID': exerciseWorkoutID,
      'SetNumber': 1,
    });

    SetModel defaultSet =
        SetModel(id: setID, exerciseWorkoutID: exerciseWorkoutID, setNumber: 1);

    ExerciseWorkoutModel exerciseWorkoutModel = ExerciseWorkoutModel(
        exerciseWorkoutID: exerciseWorkoutID,
        exerciseID: exerciseID,
        bodyPart: bodyPart,
        orderInList: nextOrder,
        exerciseName: exerciseName,
        description: descrption,
        sets: [defaultSet]);

    _exercisesWorkout.add(exerciseWorkoutModel);
    notifyListeners();

    return exerciseWorkoutModel;
  }

  Future<void> removeExerciseFromWorkout(
      int workoutID, int exerciseID, BuildContext context) async {
    final fieldManager = context.read<TextFieldManager>();

    final db = await database;

    final orderResult = await db.query('ExercisesWorkout',
        columns: ['OrderInList'],
        where: 'WorkoutID = ? AND ExerciseID = ?',
        whereArgs: [workoutID, exerciseID]);

    if (orderResult.isNotEmpty) {
      int orderToRemove = orderResult.first['OrderInList'] as int;

      //Delete the exercise
      await db.delete('ExercisesWorkout',
          where: 'WorkoutID = ? AND ExerciseID = ?',
          whereArgs: [workoutID, exerciseID]);

      //Update OrderInList
      await db.rawUpdate('''
      UPDATE ExercisesWorkout
      SET OrderInList = OrderInList - 1
      WHERE WorkoutID = ? AND OrderInList > ?
      ''', [workoutID, orderToRemove]);
    }

    fieldManager.removeSetupField(exerciseID);
    final currentExercise =
        _exercisesWorkout.firstWhere((e) => e.exerciseID == exerciseID);
    for (var set in currentExercise.sets) {
      fieldManager.removeTextFieldControllers(set.id);
    }
    _exercisesWorkout
        .removeWhere((exercise) => exercise.exerciseID == exerciseID);
    notifyListeners();
  }

  Future<SetModel> addSetToExerciseWorkout(int exerciseWorkoutID) async {
    final db = await database;

    // Find the highest set number for this ExerciseWorkoutID to determine the new set number
    final maxSetNumberResult = await db.query('Sets',
        columns: ['MAX(SetNumber) as maxSetNumber'],
        where: 'ExerciseWorkoutID = ?',
        whereArgs: [exerciseWorkoutID]);

    int maxNumberSet = maxSetNumberResult.first['maxSetNumber'] != null
        ? maxSetNumberResult.first['maxSetNumber'] as int
        : 0;
    int nextSetNumber = maxNumberSet + 1;

    final result = await db.insert('Sets',
        {'ExerciseWorkoutID': exerciseWorkoutID, 'SetNumber': nextSetNumber});

    SetModel set = SetModel(
        id: result,
        exerciseWorkoutID: exerciseWorkoutID,
        setNumber: nextSetNumber);

    final exercise = _exercisesWorkout.firstWhere(
      (element) => element.exerciseWorkoutID == exerciseWorkoutID,
    );

    exercise.sets.add(set);

    notifyListeners();

    return set;
  }

  ExerciseWorkoutModel getCurrentExercise(int setID) {
    final currentExercise = _exercisesWorkout
        .firstWhere((exercise) => exercise.sets.any((set) => set.id == setID));
    return currentExercise;
  }

  List<SetModel> getAllSets() {
    List<SetModel> sets = [];

    for (var exercise in _exercisesWorkout) {
      for (var set in exercise.sets) {
        sets.add(set);
      }
    }
    return sets;
  }

  void updateWorkoutExercises(int workoutID, BuildContext context) {
    final addEx = context.read<AddExercise>();
    final fieldManager = context.read<TextFieldManager>();
    Logger().d(addEx.addedExercises);

    for (var exercise in addEx.exercises) {
      // Check if an exercise has been deleted
      if (!addEx.addedExercises.containsKey(exercise.exerciseID)) {
        // Remove the exercise from the workout
        removeExerciseFromWorkout(workoutID, exercise.exerciseID, context);

        // remove the data associated with the text fields
      } else if (!_exercisesWorkout
          .any((element) => element.exerciseID == exercise.exerciseID)) {
        // add all the new exercises in the workout
        _addExerciseToWorkout(workoutID, exercise.exerciseID)
            .then((exerciseWorkout) {
          fieldManager.addSetupField(exerciseWorkout.exerciseWorkoutID);
          for (var set in exerciseWorkout.sets) {
            fieldManager.addTextField(set.id);
          }
        });
      }
    }
    context.read<SearchExercise>().clearTextField();
    addEx.clearLists();
    notifyListeners();
  }

  void addExerciseToNewWorkout(BuildContext context, int workoutID) {
    final addEx = context.read<AddExercise>();

    for (var exercise in addEx.totalExercise) {
      _addExerciseToWorkout(workoutID, exercise.exerciseID);
    }
    context.read<SearchExercise>().clearTextField();
  }

  void resetLocalWorkoutExercise() {
    _exercisesWorkout.clear();
  }

  List<String> bodyPartsList() {
    List<String> bodyPart = [];
    for (var exercise in _exercises) {
      if (!bodyPart.contains(exercise.bodyPart)) {
        bodyPart.add(exercise.bodyPart);
      }
    }
    bodyPart.sort(
      (a, b) => a.compareTo(b),
    );
    return bodyPart;
  }
}
