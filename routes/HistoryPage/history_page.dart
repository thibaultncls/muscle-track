import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/helper/app_color.dart';
import 'package:workout_app/helper/providers/database_helper.dart';
import 'package:workout_app/helper/providers/navigation_helper.dart';
import 'package:workout_app/helper/widget_utils.dart';
import 'package:workout_app/model/workout_history_model.dart';
import 'package:workout_app/routes/HistoryPage/detail_history_dialog.dart';
import 'package:workout_app/widgets/detail_list_widget.dart';
import 'package:workout_app/widgets/page_title.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // A variable to check if the data are loaded
  bool _isLoading = true;

  @override
  void initState() {
    _isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getWorkoutHistories();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final databaseHelper = Provider.of<DatabaseHelper>(context);
    final workoutHistories = databaseHelper.workoutHistory;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.backgroungColor,
        title: const PageTitle(text: 'Historique'),
      ),
      body: Container(
          color: AppColors.backgroungColor,
          height: height,
          width: width,
          // Check if the async function is done
          child: (_isLoading)
              ? _loadingData()
              // Check if there are data for the history
              : (workoutHistories.isEmpty)
                  ? _noWorkoutHistories()
                  : _workoutHistoriesList()),
    );
  }

  // A widget if data are not loaded yet
  Widget _loadingData() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  // A widget if there are no workout finished yet
  Widget _noWorkoutHistories() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Pas encore d\'entraînement enregistré'),
          const SizedBox(
            height: 30,
          ),
          ElevatedButton(
              onPressed: () => _previousPage(),
              child: const Text(
                'Commencer un entraînement',
                style: TextStyle(
                    color: AppColors.backgroungColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
              ))
        ],
      ),
    );
  }

  // List of the workout finished
  Widget _workoutHistoriesList() {
    final databaseHelper = Provider.of<DatabaseHelper>(context);
    List<WorkoutHistoryModel> workoutHistories = databaseHelper.workoutHistory;
    return ListView.builder(
        itemCount: workoutHistories.length,
        itemBuilder: (context, index) {
          final workoutHistory = workoutHistories[index];
          return Padding(
            padding: const EdgeInsets.only(top: 20, right: 25, left: 25),
            child: Container(
              decoration: BoxDecoration(
                  color: AppColors.backgroungColor,
                  border: Border.all(
                    color: AppColors.primaryColor.withOpacity(.9),
                    width: .7,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(20))),
              child: Theme(
                data: ThemeData().copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: Text(
                    workoutHistory.workoutName,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    WidgetUtils.formatTimestamp(workoutHistory.date),
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.secondaryText),
                  ),
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: (workoutHistory.details != null)
                            ? DetailList(workout: workoutHistory)
                            : const SizedBox()),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          style: const ButtonStyle(
                              elevation: WidgetStatePropertyAll(0),
                              backgroundColor:
                                  WidgetStatePropertyAll(AppColors.buttonColor),
                              shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(14))))),
                          onPressed: () =>
                              _showDetailHistoryDialog(workoutHistory),
                          child: const Text(
                            'Voir le détail',
                            style: TextStyle(
                                color: AppColors.backgroungColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 16),
                          )),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  // Get the history of workouts in the database
  Future<void> _getWorkoutHistories() async {
    final databaseHelper = Provider.of<DatabaseHelper>(context, listen: false);
    databaseHelper.getWorkoutHistories().then((value) => _isLoading = false);
  }

  // Go back to the DashboardPage
  void _previousPage() {
    final navigationProvider =
        Provider.of<NavigationHelper>(context, listen: false);
    navigationProvider.updateIndex(1);
  }

  Future<dynamic> _showDetailHistoryDialog(
      WorkoutHistoryModel workoutHistory) async {
    showDialog(
        context: context,
        builder: ((BuildContext context) =>
            DetailHistoryDialog(workoutHistory: workoutHistory)));
  }
}
