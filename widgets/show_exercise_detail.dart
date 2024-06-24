import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/helper/app_color.dart';
import 'package:workout_app/helper/providers/database_helper.dart';
import 'package:workout_app/helper/widget_utils.dart';
import 'package:workout_app/model/abstarct_class/exercises.dart';
import 'package:workout_app/widgets/grouped_list_elements.dart';
import 'package:workout_app/widgets/page_title.dart';

class ShowExerciseDetail extends StatefulWidget {
  final Exercises exercise;
  const ShowExerciseDetail({super.key, required this.exercise});

  @override
  State<ShowExerciseDetail> createState() => _ShowExerciseDetailState();
}

class _ShowExerciseDetailState extends State<ShowExerciseDetail>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _isLoaded = false;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _getExercisePerformance(widget.exercise.exerciseID);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final databaseHelper = Provider.of<DatabaseHelper>(context);
    final exercisePerformance = databaseHelper.exercisesPerformance;

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(2)),
      height: screenHeight * .8,
      width: screenWidth,
      child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 20, 12, 16),
          child: Column(
            children: [
              PageTitle(text: widget.exercise.exerciseName),
              Text(
                widget.exercise.bodyPart,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.secondaryText, fontSize: 16),
              ),
              const SizedBox(
                height: 20,
              ),
              TabBar(
                  controller: _tabController,
                  tabs: [_tabBarText('Détails'), _tabBarText('Performances')]),
              Expanded(
                child: TabBarView(controller: _tabController, children: [
                  // Show the details of the exercise
                  _detailTab(),

                  // If the data are not loaded yet, show a indicator of loading
                  (!_isLoaded)
                      ? _loadingCenter()

                      // If the list is not empty, show the list of the performances
                      // Otherwise show a text
                      : (exercisePerformance.isEmpty)
                          ? _noPerformanceData()
                          : _performanceTab()
                ]),
              )
            ],
          )),
    );
  }

  Widget _performanceTab() {
    final databaseHelper = Provider.of<DatabaseHelper>(context);
    final exercisesPerformance = databaseHelper.exercisesPerformance;

    final dateFormat = DateFormat('EEEE d MMMM yyyy', 'fr_FR');
    return GroupedListView(
        order: GroupedListOrder.DESC,
        groupSeparatorBuilder: (value) {
          final String formattedDate = dateFormat.format(value);
          return WidgetUtils.groupSepatatorBuilder(
              _capitalizeDate(formattedDate));
        },
        elements: exercisesPerformance,
        groupBy: (element) => element.workoutDate,
        itemBuilder: (context, element) {
          return GroupedListElement(set: element, exercise: widget.exercise);
        });
  }

  Widget _detailTab() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: (widget.exercise.description != null)
          ? ListView(
              children: [
                const SizedBox(
                  height: 20,
                ),
                RichText(
                    text: TextSpan(
                        style: const TextStyle(color: Colors.black),
                        children: _formatExerciseDetails(
                            widget.exercise.description!)))
              ],
            )
          : const Center(
              child: Text('Pas de description pour cet exercice'),
            ),
    );
  }

  // Show a text if the data are empty
  Widget _noPerformanceData() {
    const String text = 'Pas de performances enregitrées';
    return const Center(
      child: Text(text),
    );
  }

  // Show a circular progress indicator if the data are not loaded
  Widget _loadingCenter() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  // Parse and format the exercise details
  List<TextSpan> _formatExerciseDetails(String details) {
    List<TextSpan> spans = [];
    List<String> lines =
        details.split('\n'); // Splitting the details into lines

    for (var line in lines) {
      if (line.trim().endsWith(':')) {
        // This line is an header, apply bold
        spans.add(TextSpan(
          text: '$line\n',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
      } else {
        // Regular text
        spans.add(TextSpan(
          text: '$line\n',
        ));
      }
    }

    return spans;
  }

  // * A function to capitalize the first letter of the day and month
  String _capitalizeDate(String formattedDate) {
    //Split the chain of String
    List<String> words = formattedDate.split(' ');

    // Go through each word and capitalize the first letter
    String capitalizedDate = words.map((word) {
      if (word.isNotEmpty) {
        return word[0].toUpperCase() + word.substring(1);
      }
      return word;
    }).join(' ');
    return capitalizedDate;
  }

  Padding _tabBarText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }

  Future<void> _getExercisePerformance(int exerciseID) async {
    final databaseHelper = Provider.of<DatabaseHelper>(context, listen: false);
    databaseHelper
        .getPerformanceByExercise(exerciseID)
        .then((_) => _isLoaded = true);
  }
}
