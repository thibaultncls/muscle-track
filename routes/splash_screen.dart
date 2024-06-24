import 'package:flutter/material.dart';
import 'package:workout_app/helper/app_keys.dart';
import 'package:workout_app/helper/app_style.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Image.asset(
      fit: BoxFit.cover,
      Keys.splashScreenPath,
      width: AppStyle.pageWidth(context),
      height: AppStyle.pageHeight(context),
    ));
  }
}
