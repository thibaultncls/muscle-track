import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_app/helper/app_color.dart';
import 'package:workout_app/helper/app_keys.dart';
import 'package:workout_app/helper/providers/database_helper.dart';
import 'package:workout_app/helper/providers/navigation_helper.dart';
import 'package:workout_app/routes/DashboardPage/dashboard_page.dart';
import 'package:workout_app/routes/HistoryPage/history_page.dart';
import 'package:workout_app/routes/WorkoutPage/workout_page.dart';
import 'package:workout_app/routes/ExercisesPage/exercices_page.dart';
import 'package:workout_app/routes/splash_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DatabaseHelper _db;
  late SharedPreferences _prefs;
  bool _isDataLoaded = false;
  late bool _isWorkoutInProgress;
  late int _currentWorkoutID;

  @override
  void initState() {
    super.initState();
    _isDataLoaded = false;
    _initPrefs();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isDataLoaded) {
      return const SplashScreen();
    } else if (_isWorkoutInProgress && _currentWorkoutID != 1) {
      final currentWorkout =
          _db.workouts.firstWhere((element) => element.id == _currentWorkoutID);
      return WorkoutPage(workout: currentWorkout);
    } else {
      return const Home();
    }
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _isWorkoutInProgress = _prefs.getBool(Keys.isWorkoutInProgressKey) ?? false;
    _currentWorkoutID = _prefs.getInt('currentWorkoutID') ?? -1;
    _getWorkouts();
  }

  Future<void> _getWorkouts() async {
    _db = Provider.of<DatabaseHelper>(context, listen: false);
    await _db.getWorkouts();
    _isDataLoaded = true;
    setState(() {});
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationHelper>(context);
    final currentIndex = navigationProvider.currentIndex;

    const double iconSize = 30.0;
    const double unselectedFontSize = 12;
    const double selectedFontSize = 16;
    const double elevation = 0;
    return Consumer<NavigationHelper>(builder: (_, nav, __) {
      return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          elevation: elevation,
          unselectedFontSize: unselectedFontSize,
          selectedFontSize: selectedFontSize,
          iconSize: iconSize,
          unselectedItemColor: AppColors.primaryColor,
          selectedItemColor: AppColors.buttonColor,
          backgroundColor: AppColors.backgroungColor,
          onTap: (index) {
            nav.updateIndex(index);
          },
          items: _items,
          currentIndex: currentIndex,
        ),
        body: pages[nav.currentIndex],
      );
    });
  }

  final List<BottomNavigationBarItem> _items = const [
    BottomNavigationBarItem(icon: Icon(Icons.view_agenda), label: 'Exercices'),
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Entraînements'),
    BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historique'),
  ];

  final List<Widget> pages = const [
    ExercisesPage(),
    DashboardPage(),
    HistoryPage()
  ];
}
