import 'package:flutter/material.dart';
import 'package:workout_app/model/abstarct_class/workouts.dart';

class DetailList extends StatelessWidget {
  final Workout workout;
  const DetailList({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
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
