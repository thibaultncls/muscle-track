import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/helper/app_keys.dart';
import 'package:workout_app/helper/app_style.dart';
import 'package:workout_app/helper/providers/add_exercise.dart';
import 'package:workout_app/helper/providers/database_helper.dart';
import 'package:workout_app/helper/providers/navigation_helper.dart';
import 'package:workout_app/helper/providers/new_workout_controller.dart';
import 'package:workout_app/helper/providers/request_focus.dart';
import 'package:workout_app/helper/providers/search_exercise.dart';
import 'package:workout_app/helper/providers/workout_data_loaded.dart';
import 'package:workout_app/helper/providers/reorder_workouts.dart';
import 'package:workout_app/helper/providers/set_timer_model.dart';
import 'package:workout_app/model/workout_model.dart';
import 'package:workout_app/helper/providers/metric_preferences.dart';
import 'package:workout_app/helper/providers/show_dialog_controller.dart';
import 'package:workout_app/helper/providers/text_field_manager.dart';
import 'package:workout_app/helper/providers/workout_timer_model.dart';
import 'package:workout_app/routes/body_part_exercises.dart';
import 'package:workout_app/routes/home_page.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:workout_app/routes/WorkoutPage/workout_page.dart';
import 'package:workout_app/routes/setting_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Workmanager()
  //     .initialize(BackgroundManager.callBackDispatcher, isInDebugMode: true);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    initializeDateFormatting('fr_FR', null);
    Intl.defaultLocale = 'fr_FR';

    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider<DatabaseHelper>(
          create: (context) => DatabaseHelper.instance,
          lazy: false,
        ),
        ChangeNotifierProvider<WorkoutTimerModel>(
            create: (_) => WorkoutTimerModel()),
        ChangeNotifierProvider<SetTimerModel>(
          create: (_) => SetTimerModel(),
        ),
        ChangeNotifierProvider<TextFieldManager>(
            create: (_) => TextFieldManager()),
        ChangeNotifierProvider<ShowDialogController>(
            create: (_) => ShowDialogController()),
        ChangeNotifierProvider<NavigationHelper>(
            create: (_) => NavigationHelper()),
        ChangeNotifierProvider<MetricPreferences>(
            create: (_) => MetricPreferences()),
        ChangeNotifierProvider(create: (_) => ReorderWorkouts()),
        ChangeNotifierProvider(create: (_) => WorkoutDataLoaded()),
        ChangeNotifierProvider(create: (_) => RequestFocus()),
        ChangeNotifierProvider(create: (_) => SearchExercise()),
        ChangeNotifierProvider(create: (_) => AddExercise()),
        ChangeNotifierProvider(create: (_) => NewWorkoutController())
      ],
      child: const MainApp(),
    ));
    timeago.setLocaleMessages('fr', timeago.FrMessages());
  });
}

class MainApp extends StatelessWidget {
  const MainApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
      routes: {
        Keys.homePage: (context) => const HomePage(),
        Keys.settingsPage: (context) => const SettingsPage()
      },
      onGenerateRoute: (settings) {
        if (settings.name == Keys.workoutPage) {
          final workout = settings.arguments as WorkoutModel;
          return MaterialPageRoute(
              builder: (context) => WorkoutPage(workout: workout));
        } else if (settings.name == Keys.bodyPartExercisePage) {
          final bodyPart = settings.arguments as String;
          return MaterialPageRoute(
              builder: (context) => BodyPartExercises(bodyPart: bodyPart));
        }
        return null;
      },
      debugShowCheckedModeBanner: false,
      theme: AppStyle.theme(),
    );
  }
}
