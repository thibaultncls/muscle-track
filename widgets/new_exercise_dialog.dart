import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/helper/app_color.dart';
import 'package:workout_app/helper/providers/database_helper.dart';
import 'package:workout_app/helper/providers/search_exercise.dart';
import 'package:workout_app/model/exercise_model.dart';

class NewExerciseDialog extends StatefulWidget {
  const NewExerciseDialog({
    super.key,
  });

  @override
  State<NewExerciseDialog> createState() => _NewExerciseDialogState();
}

class _NewExerciseDialogState extends State<NewExerciseDialog> {
  final controller = TextEditingController();
  String? selectedBodyPart;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final items = bodyPart()
        .map((bodyPart) => DropdownMenuItem(
              value: bodyPart,
              child: Text(bodyPart),
            ))
        .toList();
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        height: 300,
        decoration: BoxDecoration(
            color: AppColors.backgroungColor,
            borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  'Nouvel exercice',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const Spacer(
                  flex: 1,
                ),
                TextFormField(
                  decoration:
                      const InputDecoration(hintText: 'Nom de l\'exercice'),
                  controller: controller,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer du texte';
                    }
                    return null;
                  },
                ),
                const Spacer(
                  flex: 2,
                ),
                DropdownButtonFormField2(
                  hint: const Text('Partie du corps'),
                  validator: (value) {
                    if (value == null) {
                      return 'Veuillez choisir une partie du corps pour cet exercice';
                    }
                    return null;
                  },
                  items: items,
                  value: selectedBodyPart,
                  onChanged: (value) => selectedBodyPart = value,
                ),
                const Spacer(
                  flex: 4,
                ),
                ElevatedButton(
                    style: ButtonStyle(
                        fixedSize:
                            WidgetStateProperty.all(Size(width * 0.6, 40))),
                    onPressed: () {
                      _addExercise();
                    },
                    child: const Text(
                      'Ajouter',
                      style: TextStyle(
                          color: AppColors.backgroungColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<String> bodyPart() {
    final databaseHelper = Provider.of<DatabaseHelper>(context, listen: false);
    List<ExerciseModel> exercises = databaseHelper.exercises;
    List<String> list = [];
    for (var exercise in exercises) {
      if (!list.contains(exercise.bodyPart)) {
        list.add(exercise.bodyPart);
      }
    }
    list.sort(
      (a, b) => a.compareTo(b),
    );
    return list;
  }

  Future<void> _addExercise() async {
    final databaseHelper = Provider.of<DatabaseHelper>(context, listen: false);
    if (_formKey.currentState!.validate()) {
      databaseHelper
          .addExercise(controller.text, selectedBodyPart!)
          .then((exercise) {
        setState(() {
          Navigator.pop(context, true);
          context.read<SearchExercise>().showNewExercise(exercise);
        });
      });
    }
  }
}
