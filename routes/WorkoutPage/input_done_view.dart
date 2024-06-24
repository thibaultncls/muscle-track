import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:workout_app/helper/app_color.dart';
import 'package:workout_app/model/set_model.dart';
import 'package:workout_app/helper/providers/text_field_manager.dart';

class InputDoneView extends StatelessWidget {
  final bool isLast;
  final SetModel set;
  const InputDoneView({Key? key, required this.isLast, required this.set})
      : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) {
    final fieldManager = Provider.of<TextFieldManager>(context);
    return Container(
        width: double.infinity,
        color: CupertinoColors.extraLightBackgroundGray,
        child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
              child: CupertinoButton(
                padding:
                    const EdgeInsets.only(right: 24.0, top: 8.0, bottom: 8.0),
                onPressed: fieldManager.isOnNextEnabled
                    ? () {
                        fieldManager.onNext(set, context);
                      }
                    : null,
                child: Text((isLast) ? 'Terminé' : 'Suivant',
                    style: const TextStyle(
                        color: AppColors.secondaryColor, fontSize: 18)),
              ),
            )));
  }
}
