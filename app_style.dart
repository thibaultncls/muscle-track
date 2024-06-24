import 'package:flutter/material.dart';
import 'package:workout_app/helper/app_color.dart';
import 'package:workout_app/model/set_model.dart';
import 'package:workout_app/helper/providers/metric_preferences.dart';

class AppStyle {
  static const fontWeight600 = FontWeight.w600;
  static const fontWeight500 = FontWeight.w500;
  static const double averageTextSize = 16;

  static double pageWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;
  static double pageHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  static ShapeBorder roundedRectangleBorder() => const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)));

  static ThemeData theme() {
    const double borderRadius = 14;

    return ThemeData(
        appBarTheme: const AppBarTheme(
          surfaceTintColor: AppColors.backgroungColor,
          backgroundColor: AppColors.backgroungColor,
        ),
        navigationBarTheme: NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.all(const TextStyle(
                color: AppColors.secondaryText,
                fontSize: 14,
                fontWeight: FontWeight.bold))),
        tabBarTheme: TabBarTheme(
            labelColor: AppColors.secondaryColor,
            indicatorColor: AppColors.secondaryColor,
            overlayColor:
                WidgetStatePropertyAll(AppColors.primaryColor.withOpacity(.1))),
        colorSchemeSeed: AppColors.primaryColor,
        elevatedButtonTheme: const ElevatedButtonThemeData(
            style: ButtonStyle(
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.all(Radius.circular(borderRadius)))),
                backgroundColor: WidgetStatePropertyAll(AppColors.buttonColor),
                textStyle: WidgetStatePropertyAll(
                  TextStyle(color: AppColors.backgroungColor),
                ),
                elevation: WidgetStatePropertyAll(0))),
        dialogTheme: const DialogTheme(
            backgroundColor: AppColors.backgroungColor, elevation: 0),
        inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: const BorderSide(width: .1)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide:
                    BorderSide(color: AppColors.secondaryText.withOpacity(.5))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide:
                    BorderSide(color: AppColors.secondaryText.withOpacity(.5))),
            contentPadding: const EdgeInsets.only(left: 14),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: const BorderSide(color: Colors.red))));
  }

  static TextStyle textFieldStyle() {
    return const TextStyle(
        fontSize: AppStyle.averageTextSize, fontWeight: FontWeight.w500);
  }

  // ! input decoration for the set Text Field
  static InputDecoration inputDecoration(
      double? value, String hintText, bool isSubmitted) {
    return InputDecoration(
        border: border(isSubmitted),
        enabledBorder: border(isSubmitted),
        focusedBorder: border(isSubmitted),
        disabledBorder: border(isSubmitted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 5,
        ),
        constraints: textFieldConstraints(false),
        hintText: (value == null) ? hintText : _formatDouble(value));
  }

  static BoxConstraints textFieldConstraints(bool isPerformanceMetric) {
    const double maxHeight = 35;
    double maxWidth = (isPerformanceMetric) ? 90 : 60;

    return BoxConstraints(maxHeight: maxHeight, maxWidth: maxWidth);
  }

  static String _formatDouble(double value) {
    // Check if the value hasn't decimal
    if (value % 1 == 0) {
      return value.toInt().toString();
    } else {
      return value.toString();
    }
  }

  static OutlineInputBorder border(bool isSubmitted) {
    return OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(
            color: (!isSubmitted)
                ? AppColors.primaryColor.withOpacity(0.25)
                : AppColors.primaryColor,
            width: 1));
  }

  // Display the correct hintText into the Performance Metric TextField
  static String showPerformanceMetric(
      SetModel set, MetricPreferences metricPreferences) {
    if (metricPreferences.selectedMetric == PerformanceMetric.rir) {
      if (set.rir != null) {
        return _formatDouble(set.rir!);
      } else {
        return 'RIR';
      }
    } else {
      if (set.rpe != null) {
        return _formatDouble(set.rpe!);
      } else {
        return 'RPE';
      }
    }
  }
}
