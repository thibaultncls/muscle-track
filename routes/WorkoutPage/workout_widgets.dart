import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/helper/app_color.dart';
import 'package:workout_app/helper/app_style.dart';
import 'package:workout_app/helper/dialog_helper.dart';
import 'package:workout_app/helper/providers/set_timer_model.dart';
import 'package:workout_app/helper/providers/show_dialog_controller.dart';
import 'package:workout_app/helper/widget_utils.dart';
import 'package:workout_app/model/abstarct_class/exercises.dart';
import 'package:workout_app/model/set_model.dart';
import 'package:workout_app/helper/providers/text_field_manager.dart';
import 'package:workout_app/widgets/set_timer_display.dart';

class ExerciseName extends StatelessWidget {
  final Exercises exercise;
  final double widthCoef;
  const ExerciseName(
      {super.key, required this.exercise, required this.widthCoef});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      decoration: const BoxDecoration(
        color: AppColors.clearBlue,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      width: AppStyle.pageWidth(context),
      child: Padding(
        padding: const EdgeInsets.only(top: 3, bottom: 3, left: 8, right: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: AppStyle.pageWidth(context) * widthCoef,
              child: Text(
                overflow: TextOverflow.ellipsis,
                exercise.exerciseName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: AppColors.backgroungColor,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: ElevatedButton(
                  style: const ButtonStyle(
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)))),
                      backgroundColor:
                          WidgetStatePropertyAll(AppColors.backgroungColor),
                      padding: WidgetStatePropertyAll(EdgeInsets.zero)),
                  child: const Icon(
                    Icons.more_horiz,
                    color: AppColors.clearBlue,
                  ),
                  onPressed: () => WidgetUtils.showExerciseDetailBottomSheet(
                      context, exercise)),
            ),
          ],
        ),
      ),
    );
  }
}

class SetupTextField extends StatefulWidget {
  final Exercises exercise;
  const SetupTextField({super.key, required this.exercise});

  @override
  State<SetupTextField> createState() => _SetupTextFieldState();
}

class _SetupTextFieldState extends State<SetupTextField> {
  late TextEditingController _controller;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.exercise.setup);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fieldManager = Provider.of<TextFieldManager>(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 0),
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        trackVisibility: true,
        thickness: 2,
        radius: const Radius.circular(20),
        child: TextField(
          scrollController: _scrollController,
          readOnly: true,
          minLines: null,
          maxLines: 2,
          controller: fieldManager.setupController(widget.exercise.exerciseID),
          onTap: () => DialogHelper.showSetupDialog(context, widget.exercise),
          decoration: const InputDecoration(
              hintStyle: TextStyle(fontSize: 14),
              contentPadding: EdgeInsets.zero,
              hintText: 'Réglages (ex. position des mains, inclinaison, etc.)',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              icon: Icon(
                Icons.edit_outlined,
                size: 20,
              )),
        ),
      ),
    );
  }
}

class SetTimer extends StatelessWidget {
  const SetTimer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const double x = 0.94;
    const double y = -1.9;
    return SizedBox(
      height: 75,
      child: Stack(
        children: [
          const Align(alignment: Alignment.center, child: SetTimerDisplay()),
          Align(
            alignment: const Alignment(x - 0.05, y + 0.68),
            child: Container(
              width: 37,
              height: 37,
              decoration: const BoxDecoration(
                  color: AppColors.backgroungColor,
                  borderRadius: BorderRadius.all(Radius.circular(34))),
            ),
          ),
          Align(
            alignment: const Alignment(x, y),
            child: IconButton(
                onPressed: () {
                  context.read<SetTimerModel>().resetTimer();
                  context.read<SetTimerModel>().startSet();
                },
                icon: const Icon(
                  Icons.restart_alt_outlined,
                  color: AppColors.secondaryColor,
                  size: 34,
                )),
          )
        ],
      ),
    );
  }
}

class WeightField extends StatelessWidget {
  final SetModel set;
  final void Function()? onTap;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final bool readOnly;
  final bool? autoFocus;
  const WeightField(
      {super.key,
      required this.set,
      this.onTap,
      required this.readOnly,
      this.onChanged,
      this.focusNode,
      this.autoFocus});

  @override
  Widget build(BuildContext context) {
    final setID = set.id;
    final fieldManager = Provider.of<TextFieldManager>(context);

    return TextField(
        style: AppStyle.textFieldStyle(),
        onChanged: onChanged,
        readOnly: readOnly,
        autofocus: autoFocus ?? false,
        onTap: onTap,
        textInputAction: TextInputAction.next,
        onEditingComplete: (Platform.isAndroid && fieldManager.isOnNextEnabled)
            ? () {
                fieldManager.onNext(set, context);
              }
            : null,
        controller: fieldManager.weightController(setID),
        focusNode: focusNode,
        keyboardType: (Platform.isIOS)
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.number,
        decoration: AppStyle.inputDecoration(
            set.weight, 'Poids', fieldManager.isWeightSubmitted(setID)));
  }
}

class NoteField extends StatefulWidget {
  final SetModel set;
  const NoteField({super.key, required this.set});

  @override
  State<NoteField> createState() => _NoteFieldState();
}

class _NoteFieldState extends State<NoteField> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fieldManager = Provider.of<TextFieldManager>(context);
    final setID = widget.set.id;

    return Scrollbar(
      thickness: 2,
      thumbVisibility: true,
      radius: const Radius.circular(20),
      controller: _scrollController,
      child: TextField(
        scrollController: _scrollController,
        readOnly: true,
        onTap: () {
          DialogHelper.showCurrentNoteDialog(widget.set, context);
        },
        controller: fieldManager.noteController(setID),
        minLines: 1,
        maxLines: 3,
        decoration: const InputDecoration(
          prefixIcon: Icon(
            Icons.edit_calendar_outlined,
            color: AppColors.primaryColor,
          ),
          enabledBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          disabledBorder: InputBorder.none,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: 'Ajouter une note',
        ),
      ),
    );
  }
}

class RepsField extends StatelessWidget {
  final bool? autoFocus;
  final bool? readOnly;
  final FocusNode? focusNode;
  final Function()? onTap;
  final SetModel set;
  const RepsField(
      {super.key,
      this.autoFocus,
      required this.set,
      this.onTap,
      this.readOnly,
      this.focusNode});

  @override
  Widget build(BuildContext context) {
    final fieldManager = Provider.of<TextFieldManager>(context);
    final showDialogController = Provider.of<ShowDialogController>(context);
    final setID = set.id;

    return TextField(
      onTap: onTap,
      readOnly: readOnly ?? false,
      onEditingComplete:
          (Platform.isAndroid) ? () => fieldManager.onNext(set, context) : null,
      textInputAction: TextInputAction.next,
      style: AppStyle.textFieldStyle(),
      onChanged: (value) {
        fieldManager.saveData();
        if (value.contains('.') && showDialogController.showDialog) {
          DialogHelper.showRepInfo(context);
        }
      },
      autofocus: autoFocus ?? false,
      decoration: AppStyle.inputDecoration(
          set.repetitions, 'Reps', fieldManager.isRepsSubmitted(setID)),
      keyboardType: (Platform.isIOS)
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      controller: fieldManager.repsController(setID),
      focusNode: focusNode,
    );
  }
}

class TextFieldInfo extends StatelessWidget {
  final String info;
  const TextFieldInfo({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    return Text(info, style: const TextStyle(color: AppColors.secondaryText));
  }
}
