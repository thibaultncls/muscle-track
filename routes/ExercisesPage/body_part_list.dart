import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/helper/app_keys.dart';
import 'package:workout_app/helper/providers/database_helper.dart';
import 'package:workout_app/widgets/listview_item.dart';

class BodyPartList extends StatelessWidget {
  const BodyPartList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseHelper>(builder: (_, db, __) {
      final bodyParts = db.bodyPartsList();
      return ListView.builder(
          itemCount: bodyParts.length,
          itemBuilder: (context, index) {
            final bodyPart = bodyParts[index];
            return ListViewItem(
                text: bodyPart,
                onTap: () => Navigator.pushNamed(
                    context, Keys.bodyPartExercisePage,
                    arguments: bodyPart));
          });
    });
  }
}
