import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/helper/app_color.dart';
import 'package:workout_app/helper/app_style.dart';
import 'package:workout_app/helper/providers/database_helper.dart';
import 'package:workout_app/helper/widget_utils.dart';
import 'package:workout_app/helper/workout_helper.dart';
import 'package:workout_app/model/abstarct_class/exercises.dart';
import 'package:workout_app/model/abstarct_class/performances.dart';
import 'package:workout_app/model/abstarct_class/workouts.dart';
import 'package:workout_app/model/set_model.dart';
import 'package:workout_app/routes/DashboardPage/rename_workout.dart';
import 'package:workout_app/widgets/exercises_list_for_workout.dart';
import 'package:workout_app/helper/providers/metric_preferences.dart';
import 'package:workout_app/routes/WorkoutPage/set_detail.dart';
import 'package:workout_app/helper/providers/show_dialog_controller.dart';
import 'package:workout_app/helper/providers/text_field_manager.dart';
import 'package:workout_app/routes/home_page.dart';
import 'package:workout_app/widgets/add_exercise_button.dart';
import 'package:workout_app/widgets/add_exercise_new_workout_button.dart';

class DialogHelper {
  // A dialog to show the note saved in workout history
  static Future<void> showNoteDialog(
      BuildContext context, Exercises exercise, PerformancesModel set) async {
    // Variable for the Dialog
    final String exerciseName = exercise.exerciseName;
    final String currentSet = WidgetUtils.performanceDetail(set);
    // Title variable
    const double height = 70;
    const maxLine = 1;
    const double maxFontSize = 18;
    // Button variable
    const String buttonText = 'OK';
    // Container variable
    final double sizedBoxHeight = MediaQuery.sizeOf(context).height * 0.25;

    // Show a dialog
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              scrollable: true,
              shape: AppStyle.roundedRectangleBorder(),
              backgroundColor: AppColors.backgroungColor,
              title: SizedBox(
                width: AppStyle.pageWidth(context),
                height: height,
                child: Column(
                  children: [
                    AutoSizeText(
                      exerciseName,
                      maxLines: maxLine,
                    ),
                    AutoSizeText(
                      currentSet,
                      maxLines: maxLine,
                      maxFontSize: maxFontSize,
                    )
                  ],
                ),
              ),
              content: SizedBox(
                  height: sizedBoxHeight,
                  child: SingleChildScrollView(child: Text(set.note!))),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      buttonText,
                      style: TextStyle(
                          color: AppColors.secondaryColor,
                          fontWeight: AppStyle.fontWeight600,
                          fontSize: AppStyle.averageTextSize),
                    ))
              ],
            ));
  }

  // ! Dialog for WorkoutPage
  // Show the current note for the current set
  static Future<dynamic> showCurrentNoteDialog(
      SetModel set, BuildContext context) async {
    int setID = set.id;
    final textFieldManager =
        Provider.of<TextFieldManager>(context, listen: false);
    final db = Provider.of<DatabaseHelper>(context, listen: false);

    const inputBorder = InputBorder.none;
    final result = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12))),
            title: const Text('Ajouter une note'),
            content: Consumer<TextFieldManager>(
              builder: (_, fieldManager, __) {
                return TextField(
                  focusNode: fieldManager.noteNode(setID),
                  controller: fieldManager.noteController(setID),
                  onChanged: (value) {
                    fieldManager.updateNoteText(setID, value);
                  },
                  minLines: 5,
                  maxLines: null,
                  autofocus: true,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                      suffixIcon: (fieldManager.isNoteEmpty(setID))
                          ? null
                          : IconButton(
                              onPressed: () {
                                fieldManager.clearNoteController(setID);
                              },
                              icon: const Icon(Icons.cancel_outlined)),
                      enabledBorder: inputBorder,
                      disabledBorder: inputBorder,
                      border: inputBorder,
                      focusedBorder: inputBorder,
                      hintText: 'Note...'),
                );
              },
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    textFieldManager.cancelNoteChange(set);
                    Navigator.pop(context, false);
                  },
                  child: const Text(
                    'Annuler',
                    style: TextStyle(
                        color: AppColors.secondaryColor,
                        fontSize: AppStyle.averageTextSize,
                        fontWeight: AppStyle.fontWeight500),
                  )),
              ElevatedButton(
                  style: const ButtonStyle(
                      backgroundColor:
                          WidgetStatePropertyAll(AppColors.paleBlue)),
                  onPressed: () {
                    db.updateNote(
                        setID, textFieldManager.noteController(setID).text);
                    Navigator.pop(context, true);
                  },
                  child: const Text(
                    'Valider',
                    style: TextStyle(
                        color: AppColors.backgroungColor,
                        fontSize: AppStyle.averageTextSize,
                        fontWeight: AppStyle.fontWeight600),
                  ))
            ],
          );
        });

    if (result == null) {
      textFieldManager.cancelNoteChange(set);
    }
  }

  // Show a dialog if the user press ','
  static Future<dynamic> showRepInfo(BuildContext context) {
    const String title = 'Vous avez entrée une virgule';
    const String content = '''
      La virgule vous permet d'indiquer des répétitions partielle. Par exemple, si vous entrez "10,5", cela signifie que vous avez effectué 10 répétitions complètes suivies d'une demi-répétition.

      Les demi-répétitions sont utiles pour ajuster précisément votre effort et évaluer votre performance de manière plus détaillée.

      Si vous n'avez pas effectué de demi-répétition, vous pouvez simplement saisir un nombre entier pour le nombre total de répétitions.
      ''';
    final materialState = WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.buttonColor; // Color when the value is true
      }
      return AppColors.backgroungColor; // Color when the value is false
    });

    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text(title),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(content),
                    Consumer<ShowDialogController>(
                        builder: (context, controller, _) => Row(
                              children: [
                                Checkbox(
                                    fillColor: materialState,
                                    value: !controller.showDialog,
                                    onChanged: (bool? value) {
                                      controller.showDialog = !value!;
                                    }),
                                const Text(
                                  'Ne plus afficher ce message',
                                  style:
                                      TextStyle(color: AppColors.primaryColor),
                                )
                              ],
                            ))
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                          color: AppColors.secondaryColor,
                          fontSize: AppStyle.averageTextSize,
                          fontWeight: AppStyle.fontWeight600),
                    ))
              ],
            ));
  }

  //Show a Dialog to display the informations about RIR and RPE
  static Future<dynamic> showPerformanceMetricInfo(BuildContext context) {
    const String content = '''
RIR signifie Reps In Reserve, ce qui indique le nombre de répétitions que vous pensez pouvoir encore réaliser avant l'échec musculaire. Par exemple, un RIR de 2 signifie que vous arrêtez votre série en pensant pouvoir faire encore deux répétitions.

RPE est l'acronyme de Rate of Perceived Exertion. Il s'agit d'une échelle qui mesure l'intensité de votre effort. L'échelle varie généralement de 1 à 10, où 1 est très facile et 10 est un effort maximal. Par exemple, un RPE de 7 sur 10 indique un effort soutenu mais gérable, vous laissant une marge avant l'échec complet.
''';
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Qu\'est ce que le RIR et le RPE'),
              content: const Text(content),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                          color: AppColors.secondaryColor,
                          fontSize: AppStyle.averageTextSize),
                    ))
              ],
            ));
  }

  // * Show a dialog if at least one TextField is empty
  static Future<dynamic> showEndWorkout(BuildContext context, Workout workout) {
    const String title =
        'Etes vous sûr(e) de vouloir terminer l\'entraînement ?';
    const String content =
        '''Il semble que certaines valeurs soient restées vides dans votre entraînement. Terminer l'entraînement avec des champs vides peut affecter la précision de vos données.

Voulez-vous terminer l'entraînement ou le quitter ?''';
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text(title),
              content: const Text(content),
              actionsAlignment: MainAxisAlignment.spaceEvenly,
              actions: [
                Column(
                  children: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Annuler',
                          style: TextStyle(
                              color: AppColors.deleteColor,
                              fontSize: AppStyle.averageTextSize,
                              fontWeight: AppStyle.fontWeight600),
                        )),
                    TextButton(
                        onPressed: () {
                          WorkoutHelper.resetPrefs(context);
                          Navigator.pop(context);
                          context
                              .read<DatabaseHelper>()
                              .resetLocalWorkoutExercise();

                          if (Navigator.canPop(context)) {
                            Navigator.pop(context, true);
                          } else {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const HomePage()),
                                (route) => false);
                          }
                        },
                        child: const Text(
                          'Quitter',
                          style: TextStyle(
                              color: AppColors.deleteColor,
                              fontSize: AppStyle.averageTextSize,
                              fontWeight: AppStyle.fontWeight600),
                        )),
                    ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.all(AppColors.paleBlue),
                            fixedSize: WidgetStatePropertyAll(
                              Size(MediaQuery.of(context).size.width, 25),
                            )),
                        onPressed: () {
                          Navigator.pop(context);
                          WorkoutHelper.updateWorkout(context, workout);
                        },
                        child: const Text(
                          'Terminer',
                          style: TextStyle(
                              color: AppColors.backgroungColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        )),
                  ],
                )
              ],
            ));
  }

  static Future<dynamic> showCancelDialog(BuildContext context, bool canPop) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title:
                  const Text('Voulez vous vraiment quitter l\'entraînement ?'),
              content: const Text(
                  'Si vous quittez l\'entraînement les performances ne seront pas enregistrées'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Non',
                      style: TextStyle(
                          color: AppColors.paleBlue,
                          fontSize: AppStyle.averageTextSize),
                    )),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            const WidgetStatePropertyAll(AppColors.deleteColor),
                        padding: WidgetStateProperty.all(
                            const EdgeInsets.symmetric(horizontal: 30))),
                    onPressed: () {
                      WorkoutHelper.resetPrefs(context);
                      context
                          .read<DatabaseHelper>()
                          .resetLocalWorkoutExercise();
                      if (canPop) {
                        Navigator.pop(context);
                        Navigator.pop(context, true);
                        context.read<DatabaseHelper>().getWorkouts();
                      } else {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomePage()),
                            (route) => false);
                      }
                    },
                    child: const Text(
                      'Quitter',
                      style: TextStyle(
                          color: AppColors.backgroungColor,
                          fontWeight: FontWeight.w600,
                          fontSize: AppStyle.averageTextSize),
                    )),
              ],
            ));
  }

  // Show a dialog at the end of the workout
  static Future<dynamic> showFinishedWorkout(
      BuildContext context, Workout workout) {
    const String title = 'Vous avez fini votre séance ?';
    const String content =
        'Vous avez fini toute vos séries ! Valider la fin de l\'entraînement ?';

    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              actionsOverflowDirection: VerticalDirection.up,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              title: const Text(title),
              content: const Text(content),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Annuler',
                      style: TextStyle(
                          color: AppColors.deleteColor,
                          fontSize: AppStyle.averageTextSize,
                          fontWeight: AppStyle.fontWeight600),
                    )),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      WorkoutHelper.updateWorkout(context, workout);
                      context.read<DatabaseHelper>().getWorkouts();
                      context
                          .read<DatabaseHelper>()
                          .resetLocalWorkoutExercise();
                    },
                    style: const ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(AppColors.paleBlue)),
                    child: const Text(
                      'Valider',
                      style: TextStyle(
                          color: AppColors.backgroungColor,
                          fontWeight: AppStyle.fontWeight600,
                          fontSize: AppStyle.averageTextSize),
                    ))
              ],
            ));
  }

  static Future<dynamic> showSetupDialog(
      BuildContext context, Exercises exercise) async {
    final fieldManager = Provider.of<TextFieldManager>(context, listen: false);
    String title = 'Configuration de ${exercise.exerciseName}';

    const String hintText =
        'Réglages (ex. position des mains, inclinaison, etc.)';
    const style = TextStyle(fontSize: 15);
    final int exerciseID = exercise.exerciseID;

    // Function to call when the user press 'Done' or 'Valider'
    void onSubmitted() {
      Navigator.pop(context, true);
      DialogHelper.setupRegister(context, exercise);
    }

    final result = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12))),
              title: Text(title),
              content: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Consumer<TextFieldManager>(
                  builder: (_, fieldManager, __) {
                    return TextField(
                      onChanged: (value) {
                        fieldManager.updateSetupText(exerciseID, value);
                      },
                      style: style,
                      minLines: 2,
                      maxLines: 10,
                      autofocus: true,
                      controller:
                          fieldManager.setupController(exercise.exerciseID),
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                          suffixIcon: (!fieldManager.isSetupEmpty(exerciseID))
                              ? IconButton(
                                  onPressed: () =>
                                      fieldManager.clearSetupField(exerciseID),
                                  icon: const Icon(
                                    Icons.cancel_outlined,
                                    color: AppColors.secondaryText,
                                  ))
                              : null,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          hintMaxLines: 2,
                          hintStyle: style,
                          hintText: hintText),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      fieldManager.cancelSetupChange(exercise);
                      Navigator.pop(context, false);
                    },
                    child: const Text(
                      'Annuler',
                      style: TextStyle(
                          fontWeight: AppStyle.fontWeight600,
                          fontSize: AppStyle.averageTextSize,
                          color: AppColors.buttonColor),
                    )),
                ElevatedButton(
                    onPressed: () => onSubmitted(),
                    style: const ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(AppColors.paleBlue)),
                    child: const Text(
                      'Valider',
                      style: TextStyle(
                          color: AppColors.backgroungColor,
                          fontWeight: AppStyle.fontWeight600,
                          fontSize: AppStyle.averageTextSize),
                    ))
              ],
            ));

    // If the user close the dialog by clicking next to the dialog, cancel the change
    if (result == null) {
      fieldManager.cancelSetupChange(exercise);
    }
    return result;
  }

  static Future<dynamic> setupRegister(
    BuildContext context,
    Exercises exercise,
  ) async {
    const style = TextStyle(fontWeight: FontWeight.w400, fontSize: 16);
    const padding = EdgeInsets.symmetric(horizontal: 40, vertical: 16);
    final db = Provider.of<DatabaseHelper>(context, listen: false);
    final fieldManager = Provider.of<TextFieldManager>(context, listen: false);

    final result = await showDialog(
        context: context,
        builder: (context) => Dialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16))),
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      child: Text(
                        'Enregistrer le réglage de ${exercise.exerciseName} pour :',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: AppStyle.averageTextSize),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      db.updateExerciseSetup(
                          exercise.exerciseID,
                          fieldManager
                              .setupController(exercise.exerciseID)
                              .text);
                      Navigator.pop(context, true);
                    },
                    child: const Padding(
                      padding: padding,
                      child: Text(
                        'Tous les entraînements',
                        style: style,
                      ),
                    ),
                  ),
                  const Divider(),
                  InkWell(
                    onTap: () {
                      db.updateExerciseWorkoutSetup(
                          exercise.exerciseID,
                          fieldManager
                              .setupController(exercise.exerciseID)
                              .text);
                      Navigator.pop(context, true);
                    },
                    child: const Padding(
                      padding: padding,
                      child: Text(
                        'Cet entraînement seulement',
                        style: style,
                      ),
                    ),
                  )
                ],
              ),
            ));

    if (result == null) {
      fieldManager.cancelSetupChange(exercise);
    }
    return result;
  }

  static Future<dynamic> showSetDetail(BuildContext context, int initialPage) {
    return showDialog(
        context: context,
        builder: (context) {
          return SetDetail(
            initialPage: initialPage,
          );
        });
  }

  static Future<dynamic> showMetricMenu(
      SetModel set, GlobalKey key, BuildContext context) {
    final metricPrefs = Provider.of<MetricPreferences>(context, listen: false);

    final RenderBox button =
        key.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(const Offset(-35, 20)),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    return showMenu(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side:
                    const BorderSide(color: AppColors.primaryColor, width: .5)),
            elevation: 0,
            color: AppColors.backgroungColor,
            context: context,
            position: position,
            items: PerformanceMetric.values.map((classType) {
              return PopupMenuItem<PerformanceMetric>(
                  value: classType,
                  child: Text(
                    classType.toString().split('.').last.toUpperCase(),
                    style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 16),
                  ));
            }).toList())
        .then((value) {
      if (value != null) {
        metricPrefs.selectedMetric = (value == PerformanceMetric.rir)
            ? PerformanceMetric.rir
            : PerformanceMetric.rpe;
      }
    });
  }

  static Future<dynamic> showRenameWorkoutDialog(
      Workout workout, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => Dialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16))),
              elevation: 0,
              child: RenameWorkout(
                workout: workout,
              ),
            ));
  }

  static Future<void> showDeleteDialog(
      Workout workoutModel, BuildContext context) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            actionsAlignment: MainAxisAlignment.spaceAround,
            backgroundColor: AppColors.backgroungColor,
            title: Text('Supprimer ${workoutModel.workoutName} ?'),
            content: const Text(
                '''Vous êtes sur le point de supprimer cet entraînement. Cette action est irréversible et entraînera la perte définitive de toutes les données associées à cet entraînement, y compris les exercices, les sets, et les performances enregistrées.

Veuillez confirmer si vous souhaitez procéder à la suppression.'''),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Annuler',
                    style: TextStyle(
                        color: AppColors.paleBlue, fontWeight: FontWeight.bold),
                  )),
              ElevatedButton(
                  style: const ButtonStyle(
                      elevation: WidgetStatePropertyAll(0),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)))),
                      backgroundColor:
                          WidgetStatePropertyAll(AppColors.deleteColor)),
                  onPressed: () {
                    context.read<DatabaseHelper>().deleteWorkout(workoutModel);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Supprimer',
                    style: TextStyle(
                        color: AppColors.backgroungColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  )),
            ],
          );
        });
  }

  static Future<dynamic> showExerciseDialog(
      BuildContext context, Workout workout) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return ExercisesListForWorkout(
            addButton: AddExerciseButton(workout: workout),
          );
        });
  }

  static Future<dynamic> showExerciseNewWorkout(BuildContext context) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return const ExercisesListForWorkout(
            addButton: AddExerciseNewWorkoutButton(),
          );
        });
  }
}
