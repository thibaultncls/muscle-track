import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:workout_app/helper/app_color.dart';
import 'package:workout_app/helper/app_style.dart';
import 'package:workout_app/helper/dialog_helper.dart';
import 'package:workout_app/model/abstarct_class/exercises.dart';
import 'package:workout_app/model/abstarct_class/performances.dart';
import 'package:workout_app/model/abstarct_class/workouts.dart';
import 'package:workout_app/widgets/show_exercise_detail.dart';
import 'package:timeago/timeago.dart' as timeago;

class WidgetUtils {
  static Future<dynamic> showExerciseDetailBottomSheet(
      BuildContext context, Exercises exercise) async {
    showModalBottomSheet(
        showDragHandle: true,
        isScrollControlled: true,
        context: context,
        builder: ((BuildContext context) =>
            ShowExerciseDetail(exercise: exercise)));
  }

  // A widget to show details for the exercise in history
  static String performanceDetail(PerformancesModel perfs) {
    String performanceMetricValue = '';
    String repetitonsValue = _formatNumber(perfs.repetitions, 1);
    String weightValue = _formatNumber(perfs.weight, 1);

    if (perfs.rir != null) {
      performanceMetricValue = 'à ${_formatNumber(perfs.rir, 1)} RIR';
    } else if (perfs.rpe != null) {
      performanceMetricValue = 'à RPE ${_formatNumber(perfs.rpe, 1)}';
    }

    if (perfs.weight == null || perfs.repetitions == null) {
      return '${perfs.setNumber} : Pas de perfs enregistrées';
    } else {
      return '${perfs.setNumber} : $weightValue kg x $repetitonsValue reps $performanceMetricValue';
    }
  }

  // * Universal number formatter to avoid showing unnecessary decimal points
  static String _formatNumber(double? number, int decimalPlace) {
    if (number == null) return '';
    String formatedText = number.toStringAsFixed(decimalPlace);
    String nonSignificantZeros = '.${'0' * decimalPlace}';
    if (formatedText.endsWith(nonSignificantZeros)) {
      return number.toInt().toString();
    }
    return number.toString();
  }

  static Row groupedListElement(PerformancesModel set, BuildContext context,
      bool hasNote, Exercises exercise, double widthCoef) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: AppStyle.pageWidth(context) * widthCoef,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 4, 4),
            child: AutoSizeText(
              maxFontSize: 13,
              minFontSize: 13,
              performanceDetail(set),
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
  }

  static Padding groupSepatatorBuilder(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 2),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static String formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return timeago.format(date, locale: 'fr');
  }

  static String formattedTime(int duration) {
    int hours = duration ~/ 3600;
    int minutes = (duration % 3600) ~/ 60;
    int seconds = duration % 60;
    String formattedTime =
        '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    return formattedTime;
  }

  static Widget detailListView(Workout workout) {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: workout.details!.length,
        itemBuilder: (context, index) {
          final detail = workout.details![index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            child: Text(
              '${detail.setCount} x ${detail.exerciseName}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
            ),
          );
        });
  }
}
