import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_app/helper/app_keys.dart';
import 'package:workout_app/helper/providers/database_helper.dart';
import 'package:workout_app/helper/providers/set_timer_model.dart';
import 'package:workout_app/model/abstarct_class/exercises.dart';
import 'package:workout_app/model/exercise_workout_model.dart';
import 'package:workout_app/model/set_model.dart';
import 'package:workout_app/routes/WorkoutPage/keyboard_overlay.dart';
import 'package:workout_app/helper/providers/metric_preferences.dart';

class TextFieldManager extends ChangeNotifier {
  // Controllers
  Map<int, TextEditingController> _weightControllers = {};
  Map<int, TextEditingController> _repsControllers = {};
  Map<int, TextEditingController> _performanceMetricControllers = {};
  Map<int, TextEditingController> _noteControllers = {};

  final Map<int, TextEditingController> _setupControllers = {};
  TextEditingController setupController(int exerciseID) =>
      _setupControllers[exerciseID] ?? TextEditingController();

  late PageController _controller;
  PageController get controller => _controller;

  final _scrollController = ScrollController();
  ScrollController get scrollController => _scrollController;

  // Valid text input
  final Map<int, String> _lastValidPerformanceMetric = {};
  final Map<int, String> _lastValidWeight = {};
  final Map<int, String> _lastValidReps = {};

  // FocusNode for the TextField
  final Map<int, FocusNode> _weightNode = {};
  final Map<int, FocusNode> _repsNode = {};
  final Map<int, FocusNode> _noteNode = {};
  final Map<int, FocusNode> _performanceMetricNode = {};

  // Global key for the current set
  final Map<int, GlobalKey> _setKey = {};
  final Map<int, GlobalKey> _exerciseKey = {};

  // Bool to check if the textField is submitted
  Map<int, bool> _isWeightSubmitted = {};
  Map<int, bool> _isRepsSubmitted = {};
  Map<int, bool> _isPerformanceMetricSubmitted = {};

  // bool to diasbled the button 'Suivant' when the user pass to the next set
  // to avoid error when the text fields are focus too fast
  bool _isOnNextEnabled = true;
  bool get isOnNextEnabled => _isOnNextEnabled;

  // bool to check if the current set has focus if the nodes are out of target
  final Map<int, bool> _isPerformanceMetricActive = {};

  //Getters for the controllers
  TextEditingController weightController(int setID) =>
      _weightControllers[setID] ?? TextEditingController();
  TextEditingController repsController(int setID) =>
      _repsControllers[setID] ?? TextEditingController();
  TextEditingController performanceMetricController(int setID) =>
      _performanceMetricControllers[setID] ?? TextEditingController();
  TextEditingController noteController(int setID) =>
      _noteControllers[setID] ?? TextEditingController();

  // Getters to the value stored in the controller converted in double
  double? weightDouble(int setID) =>
      double.tryParse(_weightControllers[setID]!.text);
  double? repDouble(int setID) =>
      double.tryParse(_repsControllers[setID]!.text);
  double? perfDouble(int setID) =>
      double.tryParse(_performanceMetricControllers[setID]!.text);

  // Getters for the node
  FocusNode weightNode(int setID) => _weightNode[setID] ?? FocusNode();
  FocusNode repsNode(int setID) => _repsNode[setID] ?? FocusNode();
  FocusNode performanceMetricNode(int setID) =>
      _performanceMetricNode[setID] ?? FocusNode();
  FocusNode noteNode(int setID) => _noteNode[setID] ?? FocusNode();

  // Getter for the GlobalKey
  GlobalKey setKey(int setID) => _setKey[setID] ?? GlobalKey();
  GlobalKey exerciseKey(int exerciseID) =>
      _exerciseKey[exerciseID] ?? GlobalKey();

  // Getter for the bool
  bool isWeightSubmitted(int setID) => _isWeightSubmitted[setID] ?? false;
  bool isRepsSubmitted(int setID) => _isRepsSubmitted[setID] ?? false;
  bool isPerformanceMetricSubmitted(int setID) =>
      _isPerformanceMetricSubmitted[setID] ?? false;

  //Setters
  setIsPerformanceMetricActive(bool value, int setID) {
    _isPerformanceMetricActive[setID] = value;
    notifyListeners();
  }

  requestWeightFocus(int setID) {
    _weightNode[setID]!.requestFocus();
    notifyListeners();
  }

  late SharedPreferences _prefs;

  TextFieldManager() {
    _initPreferences();
  }

  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  void initialize(int initialPage) {
    _controller = PageController(initialPage: initialPage);
  }

  // ! add elements for the text field
  void addTextField(int setID) {
    //Add the controllers
    _weightControllers.addAll({setID: TextEditingController()});
    _repsControllers.addAll({setID: TextEditingController()});
    _noteControllers.addAll({setID: TextEditingController()});
    _performanceMetricControllers.addAll({setID: TextEditingController()});

    //Add the node
    _weightNode.addAll({setID: FocusNode()});
    _repsNode.addAll({setID: FocusNode()});
    _noteNode.addAll({setID: FocusNode()});
    _performanceMetricNode.addAll({setID: FocusNode()});

    //Add the valid Text Input
    _lastValidPerformanceMetric.addAll({setID: ''});
    _lastValidWeight.addAll({setID: ''});
    _lastValidReps.addAll({setID: ''});

    //Add the bool
    _isPerformanceMetricActive.addAll({setID: false});
    _isWeightSubmitted.addAll({setID: false});
    _isRepsSubmitted.addAll({setID: false});
    _isPerformanceMetricSubmitted.addAll({setID: false});

    // Add globalKey
    _setKey.addAll({setID: GlobalKey()});

    //Add the listeners
    _performanceMetricControllers[setID]!
        .addListener(() => _validatePerformanceMetricInput(setID));
    _weightControllers[setID]!.addListener(
        () => _validateInput(setID, 2, _lastValidWeight, _weightControllers));
    _repsControllers[setID]!.addListener(
      () => _validateInput(setID, 1, _lastValidReps, _repsControllers),
    );

    notifyListeners();
  }

  void addSetupField(int exerciseID) {
    _setupControllers.addAll({exerciseID: TextEditingController()});
    notifyListeners();
  }

  // ! remove elements of the deleted text field
  void removeTextFieldControllers(int setID) {
    // Remove the listeners
    _weightControllers[setID]?.removeListener(() {});
    _performanceMetricControllers[setID]?.removeListener(() {});
    _repsControllers[setID]?.removeListener(() {});

    // Remove the node
    _weightNode.remove(setID);
    _repsNode.remove(setID);
    _noteNode.remove(setID);
    _performanceMetricNode.remove(setID);

    // Remove the controllers
    _weightControllers.remove(setID);
    _repsControllers.remove(setID);
    _noteControllers.remove(setID);
    _performanceMetricControllers.remove(setID);

    // Remove the last valid input in the map
    _lastValidPerformanceMetric.remove(setID);
    _lastValidWeight.remove(setID);
    _lastValidReps.remove(setID);

    // Remove the bool for the deleted ID
    _isPerformanceMetricActive.remove(setID);
    _isWeightSubmitted.remove(setID);
    _isRepsSubmitted.remove(setID);
    _isPerformanceMetricSubmitted.remove(setID);

    //Remove the globalKey
    _setKey.remove(setID);
    notifyListeners();
  }

  void removeSetupField(int exerciseID) {
    _setupControllers.remove(exerciseID);
    notifyListeners();
  }

  // ! save the data
  Future<void> saveData() async {
    //Save data for all type of controllers
    _saveControllersData(Keys.weight, _weightControllers);
    _saveControllersData(Keys.reps, _repsControllers);
    _saveControllersData(Keys.performanceMetric, _performanceMetricControllers);
    _saveControllersData(Keys.note, _noteControllers);
    notifyListeners();
  }

  Future<void> _saveControllersData(
      String type, Map<int, TextEditingController> controllers) async {
    for (var entry in controllers.entries) {
      await _prefs.setString('${type}_${entry.key}', entry.value.text);
    }
  }

  Future<void> resetPreferences() async {
    _resetControllerData(_weightControllers, Keys.weight);
    _resetControllerData(_repsControllers, Keys.reps);
    _resetControllerData(_performanceMetricControllers, Keys.performanceMetric);
    _resetControllerData(_noteControllers, Keys.note);

    _resetBoolData(_isWeightSubmitted, Keys.weightSubmit);
    _resetBoolData(_isRepsSubmitted, Keys.repsSubmit);
    _resetBoolData(_isPerformanceMetricSubmitted, Keys.perfsSubmit);
    notifyListeners();
  }

  Future<void> _resetControllerData(
      Map<int, TextEditingController> controllers, String type) async {
    for (var entry in controllers.entries) {
      await _prefs.remove('${type}_${entry.key}');
    }
  }

  // ! Manage the setup controller
  void cancelSetupChange(Exercises exercise) {
    int exerciseID = exercise.exerciseID;
    _setupControllers[exerciseID]!.text = exercise.setup ?? '';
    notifyListeners();
  }

  void clearSetupField(int exerciseID) {
    _setupControllers[exerciseID]?.clear();
    notifyListeners();
  }

  bool isSetupEmpty(int exerciseID) {
    return _setupControllers[exerciseID]!.text.isEmpty;
  }

  void updateSetupText(int exerciseID, String text) {
    if (_setupControllers[exerciseID] != null) {
      _setupControllers[exerciseID]!.text = text;
      notifyListeners();
    }
  }

  // ! Manage the note controller
  clearNoteController(int setID) {
    _noteControllers[setID]?.clear();
    notifyListeners();
  }

  void cancelNoteChange(SetModel set) {
    int setID = set.id;
    _noteControllers[setID]!.text = set.note ?? '';
    notifyListeners();
  }

  bool isNoteEmpty(int setID) {
    return _noteControllers[setID]!.text.isEmpty;
  }

  void updateNoteText(int setID, String text) {
    if (_noteControllers[setID] != null) {
      _noteControllers[setID]!.text = text;
      notifyListeners();
    }
  }

  Future<void> _resetBoolData(Map<int, bool> bools, String type) async {
    for (var entry in bools.entries) {
      await _prefs.remove('${type}_${entry.key}');
    }
  }

  // Load all the data stored in TextField and init the controllers for the TextField even if there are no data
  Future<void> loadAllData(List<ExerciseWorkoutModel> exercisesWorkout) async {
    List<int> setKeys = [];
    for (var exerciseWorkout in exercisesWorkout) {
      _setupControllers[exerciseWorkout.exerciseID] =
          TextEditingController(text: exerciseWorkout.setup);
      _exerciseKey[exerciseWorkout.exerciseID] = GlobalKey();
      for (var set in exerciseWorkout.sets) {
        int setID = set.id;
        setKeys.add(setID);
        _lastValidPerformanceMetric[setID] = '';
        _lastValidWeight[setID] = '';
        _lastValidReps[setID] = '';
        _weightNode[setID] = FocusNode();
        _repsNode[setID] = FocusNode();
        _noteNode[setID] = FocusNode();
        _performanceMetricNode[setID] = FocusNode();
        _isPerformanceMetricActive[setID] = false;
        _isWeightSubmitted[setID] = false;
        _isRepsSubmitted[setID] = false;
        _isPerformanceMetricSubmitted[setID] = false;
        _setKey[setID] = GlobalKey();
        _noteControllers[setID] = await _loadNoteData(Keys.note, set);
      }
    }
    // Load the data
    _weightControllers = await _loadPerfsData(Keys.weight, setKeys);
    _repsControllers = await _loadPerfsData(Keys.reps, setKeys);
    _performanceMetricControllers =
        await _loadPerfsData(Keys.performanceMetric, setKeys);

    _isWeightSubmitted = await _loadBoolPreferences(Keys.weightSubmit, setKeys);
    _isRepsSubmitted = await _loadBoolPreferences(Keys.repsSubmit, setKeys);
    _isPerformanceMetricSubmitted =
        await _loadBoolPreferences(Keys.perfsSubmit, setKeys);

    // Add the listener for all the TextField already created
    _performanceMetricControllers.forEach((key, value) =>
        value.addListener(() => _validatePerformanceMetricInput(key)));
    _weightControllers.forEach((key, value) => value.addListener(
        () => _validateInput(key, 2, _lastValidWeight, _weightControllers)));
    _repsControllers.forEach((key, value) => value.addListener(
        () => _validateInput(key, 1, _lastValidReps, _repsControllers)));

    notifyListeners();
  }

  Future<Map<int, TextEditingController>> _loadPerfsData(
      String type, List<int> keys) async {
    Map<int, TextEditingController> controllers = {};

    for (int key in keys) {
      String value = _prefs.getString('${type}_$key') ?? '';
      controllers[key] = TextEditingController(text: value);
    }
    return controllers;
  }

  Future<TextEditingController> _loadNoteData(String type, SetModel set) async {
    int key = set.id;
    TextEditingController textEditingController;
    String value = _prefs.getString('${type}_$key') ?? '';
    if (value.isEmpty) {
      value = set.note ?? '';
    }
    textEditingController = TextEditingController(text: value);
    return textEditingController;
  }

  Future<Map<int, bool>> _loadBoolPreferences(
      String boolKey, List<int> keys) async {
    Map<int, bool> map = {};

    for (int key in keys) {
      bool value = _prefs.getBool('${boolKey}_$key') ?? false;
      map[key] = value;
    }
    return map;
  }

  // Function to save if the the text has been submitted or not
  Future<void> _saveTextFieldSubmit(
      Map<int, bool> isTextFieldSubmitted, String key) async {
    for (var entry in isTextFieldSubmitted.entries) {
      await _prefs.setBool('${key}_${entry.key}', entry.value);
    }
  }

  void _validateInput(int setID, int decimal, Map<int, String> lastValidInput,
      Map<int, TextEditingController> controllers) {
    TextEditingController? controller = controllers[setID];
    String text = controller!.text.replaceAll(',', '.');

    // Check if the text is not empty
    if (text.isNotEmpty) {
      List<String> parts = text.split('.');

      // Check if there are too many 0 at the beginning and remove them
      if (parts[0] == '00' ||
          (parts[0].startsWith('0') && parts[0] != '0' && parts.length == 1)) {
        text = '0';
      }
      // Check if there are more than 1 dot and remove if there are more
      if (parts.length > 2) {
        text = lastValidInput[setID] ?? text;
      }
      // Check the number of decimal and remove if there are more than 2

      if (parts.length == 2 && parts[1].length > 1) {
        parts[1] = parts[1].substring(0, decimal);
        text = parts.join('.');
      }
      if (text.contains('-')) {
        text = lastValidInput[setID] ?? text;
      }
      if (text.contains(' ')) {
        text = lastValidInput[setID] ?? text;
      }

      //Check if the text begin with a '.' and replace it with 0
      if (text.length == 1 && text.contains('.')) {
        text = '0';
      } else {
        lastValidInput[setID] = text;
      }
    }
    //Update controller.text if the text is different of controller.text
    if (controller.text != text) {
      controller.text = text;
      controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length));
    }
    notifyListeners();
  }

  //Check if the data inside RIR and RPE TextField are correct and block the text entry
  //if the data are incorrect
  void _validatePerformanceMetricInput(int setID) {
    TextEditingController? controller = _performanceMetricControllers[setID];
    String text =
        controller!.text.replaceAll(',', '.'); // Convert comma to period

    if (text.isNotEmpty) {
      List<String> parts = text.split('.');

      // Handle multiple leading zeros
      if (parts[0] == '00' ||
          (parts[0].startsWith('0') && parts[0] != '0' && parts.length == 1)) {
        text = '0';
      }
      if (parts.length > 2) {
        text = _lastValidPerformanceMetric[setID] ?? text;
      } else if (parts.length == 2 && parts[1].length > 1) {
        parts[1] = parts[1].substring(0, 1);
        text = parts.join('.');
      } else if (text.length == 1 && text.contains('.')) {
        text = '0';
      } else if (text.contains('-')) {
        text = _lastValidPerformanceMetric[setID] ?? text;
      }

      // Validation of numeric value and decimals
      double? value = double.tryParse(text);
      if (value != null && (value < 0 || value > 10) ||
          (parts.length > 1 && parts[1].length > 1)) {
        // Restore last valid value if out of range or too many decimal places
        text = _lastValidPerformanceMetric[setID] ?? text;
      } else {
        //Update last valid value
        _lastValidPerformanceMetric[setID] = text;
      }

      // Update text in controller if necessary
      if (controller.text != text) {
        controller.text = text;
        controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length));
      }
    }
    notifyListeners();
  }

  void focusNodeListener(SetModel set, BuildContext context) {
    int setID = set.id;
    _weightNode[setID]?.addListener(() {
      bool hasFocus = _weightNode[setID]!.hasFocus;
      if (hasFocus && Platform.isIOS) {
        KeyboardOverlay.showOverlay(
            context, _isLastSetOfTraining(_weightNode[setID]!, context), set);
      } else {
        KeyboardOverlay.removeOverlay();
      }
    });
    _repsNode[set.id]?.addListener(() {
      bool hasFocus = _repsNode[set.id]!.hasFocus;
      if (hasFocus && Platform.isIOS) {
        KeyboardOverlay.showOverlay(
            context, _isLastSetOfTraining(_repsNode[set.id]!, context), set);
      } else {
        KeyboardOverlay.removeOverlay();
      }
    });
    _performanceMetricNode[set.id]?.addListener(() {
      bool hasFocus = _performanceMetricNode[set.id]!.hasFocus;

      if (hasFocus && Platform.isIOS) {
        KeyboardOverlay.showOverlay(context,
            _isLastSetOfTraining(_performanceMetricNode[setID]!, context), set);
      } else {
        KeyboardOverlay.removeOverlay();
      }
    });
  }

  void onNext(SetModel set, BuildContext context) {
    int setID = set.id;

    final setTimerModel = Provider.of<SetTimerModel>(context, listen: false);

    final metricPreferences =
        Provider.of<MetricPreferences>(context, listen: false);
    bool isRIR = metricPreferences.selectedMetric == PerformanceMetric.rir;

    List<int> sortedSetIDs = _getSortedSetIDs(context);
    int currentIndex = sortedSetIDs.indexOf(setID);

    if (currentIndex == -1) return;

    // Check if the TextField of the weight has focus
    if (_weightNode[setID]!.hasFocus) {
      // Pass the focus to the repetition focus
      FocusScope.of(context).requestFocus(_repsNode[setID]);

      // Function to change the preferences
      _validateEmptyTextField(_weightControllers, set.weight, set, context);
      _setIsWeightSubmitted(set);
      _saveTextFieldSubmit(_isWeightSubmitted, Keys.weightSubmit);

      // Check if the TextField of the reps has focus
    } else if (_repsNode[setID]!.hasFocus) {
      // Pass the focus to the performance metric textField
      FocusScope.of(context).requestFocus(_performanceMetricNode[setID]);

      // Function to change the preferences
      _validateEmptyTextField(_repsControllers, set.repetitions, set, context);
      _setIsRepsSubmitted(set);
      _saveTextFieldSubmit(_isRepsSubmitted, Keys.repsSubmit);

      // Check if the TextField of the performance metric has focus
    } else {
      // Check if the current set is the last set
      bool isLastSet = currentIndex == sortedSetIDs.length - 1;

      if (!isLastSet) {
        int nextID = sortedSetIDs[currentIndex + 1];

        _validateEmptyTextField(_performanceMetricControllers,
            (isRIR) ? set.rir : set.rpe, set, context);

        _setIsPerformanceMetricSubmitted(set, context);
        setTimerModel.resetTimer().then((_) => setTimerModel.startSet());
        _saveTextFieldSubmit(_isPerformanceMetricSubmitted, Keys.perfsSubmit);
        _isOnNextEnabled = false;
        _controller
            .nextPage(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut)
            .then((_) {
          FocusScope.of(context).requestFocus(_weightNode[nextID]);
          _isOnNextEnabled = true;
        });
      } else {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus!.unfocus();
        }
        Navigator.pop(context);
        _scrollController.animateTo(100,
            duration: const Duration(
              milliseconds: 200,
            ),
            curve: Curves.easeInOut);
        _saveTextFieldSubmit(_isPerformanceMetricSubmitted, Keys.perfsSubmit);

        _validateEmptyTextField(_performanceMetricControllers,
            (isRIR) ? set.rir : set.rpe, set, context);
        _setIsPerformanceMetricSubmitted(set, context);
      }
    }
    notifyListeners();
  }

  // Function to change the value of the bool
  _setIsWeightSubmitted(SetModel set) {
    final setID = set.id;
    if (set.weight != null || _weightControllers[setID]!.text.isNotEmpty) {
      _isWeightSubmitted[setID] = true;
    }
  }

  _setIsRepsSubmitted(SetModel set) {
    final setID = set.id;
    if (set.repetitions != null || _repsControllers[setID]!.text.isNotEmpty) {
      _isRepsSubmitted[setID] = true;
    }
  }

  _setIsPerformanceMetricSubmitted(SetModel set, BuildContext context) {
    final metricPreferences =
        Provider.of<MetricPreferences>(context, listen: false);
    final setID = set.id;
    if (metricPreferences.selectedMetric == PerformanceMetric.rir) {
      if (set.rir != null ||
          _performanceMetricControllers[setID]!.text.isNotEmpty) {
        _isPerformanceMetricSubmitted[setID] = true;
      }
    } else {
      if (set.rpe != null ||
          _performanceMetricControllers[setID]!.text.isNotEmpty) {
        _isPerformanceMetricSubmitted[setID] = true;
      }
    }
  }

  // Check if the current set is the last of the training
  bool _isLastSetOfTraining(FocusNode? currentFocusNode, BuildContext context) {
    final databaseHelper = Provider.of<DatabaseHelper>(context, listen: false);
    final exercisesWorkout = databaseHelper.exercisesWorkout;
    List<SetModel> sets = [];

    for (var exercise in exercisesWorkout) {
      for (var set in exercise.sets) {
        sets.add(set);
      }
    }

    int lastSetID = sets[sets.length - 1].id;

    bool isFocusOnLastTextField =
        currentFocusNode == _performanceMetricNode[lastSetID];

    return isFocusOnLastTextField;
  }

  // List all the setID in the order they are in the workout
  List<int> _getSortedSetIDs(BuildContext context) {
    final databaseHelper = Provider.of<DatabaseHelper>(context, listen: false);
    final exercisesWorkout = databaseHelper.exercisesWorkout;
    List<int> sortedSetIDs = [];
    for (var workoutExercise in exercisesWorkout) {
      for (var set in workoutExercise.sets) {
        sortedSetIDs.add(set.id);
      }
    }
    return sortedSetIDs;
  }

  // If the user press onNext, and the text field is empty but the data are already in the database
  // from the previous workout, save the controller as the previous set value
  void _validateEmptyTextField(Map<int, TextEditingController> controllers,
      double? value, SetModel set, BuildContext context) {
    int setID = set.id;
    TextEditingController currentController = controllers[setID]!;
    final textFieldManager =
        Provider.of<TextFieldManager>(context, listen: false);

    if (currentController.text.isEmpty && value != null) {
      currentController.text = _formatDouble(value);
      textFieldManager.saveData();
    }
  }

  // Formats values ​​to see if there is a digit after the decimal point
  String _formatDouble(double value) {
    // Check if the value hasn't decimal
    if (value % 1 == 0) {
      return value.toInt().toString();
    } else {
      return value.toString();
    }
  }

  // Check if the set is completed and the text field are not active
  bool isSetSubmittedAndCompleted(int setID) {
    final weigthController = _weightControllers[setID];
    final repsController = _repsControllers[setID];
    final weightNode = _weightNode[setID];
    final repsNode = _weightNode[setID];
    final perfNode = _performanceMetricNode[setID];

    if (weigthController!.text.isNotEmpty &&
        repsController!.text.isNotEmpty &&
        !weightNode!.hasFocus &&
        !repsNode!.hasFocus &&
        !perfNode!.hasFocus) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    saveData();

    // Dispose and remove the listeners for the controllers
    _weightControllers.forEach((key, value) {
      value.removeListener(() {});
      value.dispose();
    });
    _repsControllers.forEach((key, value) {
      value.removeListener(() {});
      value.dispose();
    });
    _performanceMetricControllers.forEach((key, value) {
      value.removeListener(() {});
      value.dispose();
    });
    _noteControllers.forEach((key, value) => value.dispose());

    // Dispose the node
    _weightNode.forEach((key, value) => value.dispose());
    _repsNode.forEach((key, value) => value.dispose());
    _noteNode.forEach((key, value) => value.dispose());
    _performanceMetricNode.forEach((key, value) => value.dispose());
    _controller.dispose();
    super.dispose();
  }
}
