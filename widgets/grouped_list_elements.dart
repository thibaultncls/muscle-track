import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:workout_app/helper/app_color.dart';
import 'package:workout_app/helper/dialog_helper.dart';
import 'package:workout_app/helper/widget_utils.dart';
import 'package:workout_app/model/abstarct_class/exercises.dart';
import 'package:workout_app/model/abstarct_class/performances.dart';

class GroupedListElement extends StatelessWidget {
  final PerformancesModel set;
  final Exercises exercise;
  const GroupedListElement(
      {super.key, required this.set, required this.exercise});

  @override
  Widget build(BuildContext context) {
    bool hasNote = set.note != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = constraints.maxWidth * 0.7;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: maxWidth,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 4, 4),
                child: AutoSizeText(
                  maxFontSize: 13,
                  minFontSize: 13,
                  WidgetUtils.performanceDetail(set),
                  maxLines: 2,
                ),
              ),
            ),
            (hasNote)
                ? IconButton(
                    visualDensity: const VisualDensity(vertical: -2),
                    onPressed: () =>
                        DialogHelper.showNoteDialog(context, exercise, set),
                    icon: const Icon(
                      Icons.error_outline,
                      color: AppColors.secondaryColor,
                    ))
                : const SizedBox()
          ],
        );
      },
    );
  }
}
