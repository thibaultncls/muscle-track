import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/helper/app_color.dart';
import 'package:workout_app/helper/providers/database_helper.dart';
import 'package:workout_app/model/abstarct_class/workouts.dart';

class RenameWorkout extends StatefulWidget {
  final Workout workout;
  const RenameWorkout({super.key, required this.workout});

  @override
  State<RenameWorkout> createState() => _RenameWorkoutState();
}

class _RenameWorkoutState extends State<RenameWorkout> {
  late TextEditingController _controller;
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.workout.workoutName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.3;
    final width = MediaQuery.sizeOf(context).width * 0.8;
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Form(
        key: _key,
        child: Container(
          height: height,
          width: width,
          color: AppColors.backgroungColor,
          child: Column(
            children: [
              const Text(
                'Renommer l\'entraînement',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const Spacer(
                flex: 1,
              ),
              TextFormField(
                autofocus: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nouveau nom';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
                controller: _controller,
                decoration:
                    InputDecoration(hintText: widget.workout.workoutName),
              ),
              const Spacer(
                flex: 3,
              ),
              ElevatedButton(
                  onPressed: () {
                    if (_key.currentState!.validate()) {
                      context
                          .read<DatabaseHelper>()
                          .renameWorkout(_controller.text, widget.workout.id);

                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'Terminer',
                    style: TextStyle(
                        color: AppColors.backgroungColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
