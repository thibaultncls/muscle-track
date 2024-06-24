import 'package:flutter/cupertino.dart';
import 'package:workout_app/model/set_model.dart';
import 'package:workout_app/routes/WorkoutPage/input_done_view.dart';

class KeyboardOverlay {
  static OverlayEntry? _overlayEntry;

  static showOverlay(
    BuildContext context,
    bool isLastSet,
    SetModel set,
  ) {
    if (_overlayEntry != null) {
      return;
    }

    OverlayState? overlayState = Overlay.of(context);

    _overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          right: 0.0,
          left: 0.0,
          child: InputDoneView(
            isLast: isLastSet,
            set: set,
          ));
    });

    overlayState.insert(_overlayEntry!);
  }

  static removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }
}
