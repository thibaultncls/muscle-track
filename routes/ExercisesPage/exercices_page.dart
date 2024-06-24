import 'package:flutter/material.dart';
import 'package:workout_app/helper/app_color.dart';
import 'package:workout_app/routes/ExercisesPage/body_part_list.dart';
import 'package:workout_app/routes/ExercisesPage/exercise_list.dart';
import 'package:workout_app/widgets/dismiss_keyboard.dart';
import 'package:workout_app/widgets/page_title.dart';

class ExercisesPage extends StatefulWidget {
  const ExercisesPage({super.key});

  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppColors.backgroungColor,
          title: const PageTitle(text: 'Exercices'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Text(
                  'Tous les exercices',
                  style: TextStyle(
                      fontSize: 15,
                      letterSpacing: 0.1,
                      fontWeight: FontWeight.w600),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Text('Groupes musculaires',
                    style: TextStyle(
                        fontSize: 15,
                        letterSpacing: 0.1,
                        fontWeight: FontWeight.w600)),
              )
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            Container(
              color: AppColors.backgroungColor,
              child: const ExerciseList(),
            ),
            Container(
                color: AppColors.backgroungColor, child: const BodyPartList())
          ],
        ),
      ),
    );
  }
}
