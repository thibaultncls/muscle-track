import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LifecycleEventHandler extends WidgetsBindingObserver {
  final AsyncCallback detachedCallBack;
  final AsyncCallback resumeCallBack;

  LifecycleEventHandler({
    required this.detachedCallBack,
    required this.resumeCallBack,
  });

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.inactive) {
      await detachedCallBack();
    } else if (state == AppLifecycleState.resumed) {
      await resumeCallBack();
    }
  }
}
