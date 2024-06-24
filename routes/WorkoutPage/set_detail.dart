// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/helper/app_color.dart';
import 'package:workout_app/helper/app_style.dart';

import 'package:workout_app/helper/providers/database_helper.dart';
import 'package:workout_app/helper/dialog_helper.dart';
import 'package:workout_app/helper/providers/request_focus.dart';
import 'package:workout_app/routes/WorkoutPage/keyboard_overlay.dart';
import 'package:workout_app/helper/providers/metric_preferences.dart';
import 'package:workout_app/helper/providers/text_field_manager.dart';
import 'package:workout_app/routes/WorkoutPage/workout_widgets.dart';

class SetDetail extends StatefulWidget {
  final int initialPage;
  const SetDetail({
    Key? key,
    required this.initialPage,
  }) : super(key: key);

  @override
  State<SetDetail> createState() => _SetDetailState();
}

class _SetDetailState extends State<SetDetail> {
  @override
  void initState() {
    super.initState();
    context.read<TextFieldManager>().initialize(widget.initialPage);
  }

  @override
  void dispose() {
    if (Platform.isIOS) KeyboardOverlay.removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var sets = context.read<DatabaseHelper>().getAllSets();

    final fieldManager = Provider.of<TextFieldManager>(context);
    const double sizedBoxHeight = 8;
    return Dialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14))),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.start,
        children: [
          IconButton(
              onPressed: () {
                Navigator.pop(this.context);
              },
              icon: const Icon(
                Icons.cancel_outlined,
                size: 26,
                color: AppColors.secondaryColor,
              )),
          SizedBox(
            height: 350,
            child: PageView.builder(
              controller: fieldManager.controller,
              itemCount: sets.length,
              itemBuilder: (context, index) {
                // Variables
                final set = sets[index];
                final setID = set.id;
                final exercise =
                    context.read<DatabaseHelper>().getCurrentExercise(setID);
                final key = GlobalKey();

                // Widget
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                  child: Wrap(
                    children: [
                      ExerciseName(exercise: exercise, widthCoef: 0.4),
                      SetupTextField(exercise: exercise),
                      const Divider(),
                      const SetTimer(),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 30),
                            child: Text(
                              '${set.setNumber} :',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w400),
                            ),
                          ),
                          Column(
                            children: [
                              const TextFieldInfo(info: 'Kg'),
                              const SizedBox(
                                height: sizedBoxHeight,
                              ),
                              Consumer<RequestFocus>(builder: (_, focus, __) {
                                return WeightField(
                                  autoFocus: focus.isWeightTaped,
                                  set: set,
                                  readOnly: false,
                                  onChanged: (_) => fieldManager.saveData(),
                                  focusNode: fieldManager.weightNode(setID),
                                );
                              })
                            ],
                          ),
                          Column(
                            children: [
                              const TextFieldInfo(info: 'Reps'),
                              const SizedBox(
                                height: sizedBoxHeight,
                              ),
                              Consumer<RequestFocus>(builder: (_, focus, __) {
                                return RepsField(
                                  focusNode: fieldManager.repsNode(setID),
                                  set: set,
                                  autoFocus: focus.isRepsTaped,
                                );
                              })
                            ],
                          ),
                          Consumer<MetricPreferences>(
                            builder: (_, metricPrefs, __) {
                              return Column(
                                children: [
                                  TextFieldInfo(
                                      info: (metricPrefs.selectedMetric ==
                                              PerformanceMetric.rir)
                                          ? 'RIR'
                                          : 'RPE'),
                                  const SizedBox(
                                    height: sizedBoxHeight,
                                  ),
                                  Consumer<RequestFocus>(
                                      builder: (_, focus, __) {
                                    return TextField(
                                      style: AppStyle.textFieldStyle(),
                                      onChanged: (value) {
                                        fieldManager.saveData();
                                      },
                                      textInputAction: TextInputAction.next,
                                      onEditingComplete: (Platform.isAndroid &&
                                              fieldManager.isOnNextEnabled)
                                          ? () =>
                                              fieldManager.onNext(set, context)
                                          : () {},
                                      controller: fieldManager
                                          .performanceMetricController(setID),
                                      autofocus: focus.isPerfsTaped,
                                      keyboardType: (Platform.isIOS)
                                          ? const TextInputType
                                              .numberWithOptions(decimal: true)
                                          : TextInputType.number,
                                      focusNode: fieldManager
                                          .performanceMetricNode(setID),
                                      decoration: InputDecoration(
                                          border: AppStyle.border(fieldManager
                                              .isPerformanceMetricSubmitted(
                                                  setID)),
                                          enabledBorder: AppStyle.border(fieldManager
                                              .isPerformanceMetricSubmitted(
                                                  setID)),
                                          focusedBorder: AppStyle.border(
                                              fieldManager.isPerformanceMetricSubmitted(
                                                  setID)),
                                          disabledBorder: AppStyle.border(
                                              fieldManager
                                                  .isPerformanceMetricSubmitted(
                                                      setID)),
                                          suffixIcon: InkWell(
                                            key: key,
                                            onTap: () =>
                                                DialogHelper.showMetricMenu(
                                                    set, key, context),
                                            child: const Icon(
                                                Icons.arrow_drop_down),
                                          ),
                                          hintText: AppStyle.showPerformanceMetric(
                                              set, metricPrefs),
                                          constraints:
                                              AppStyle.textFieldConstraints(true)),
                                    );
                                  }),
                                ],
                              );
                            },
                          )
                        ],
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: NoteField(set: set),
                      )
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
