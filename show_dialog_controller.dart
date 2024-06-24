import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowDialogController extends ChangeNotifier {
  bool _showDialog = true;
  late SharedPreferences _prefs;
  final String _key = 'show_dialog';

  ShowDialogController() {
    _initPreferences();
  }

  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _checkIfDialogShouldBeShown();
  }

  bool get showDialog => _showDialog;

  set showDialog(bool value) {
    _showDialog = value;
    notifyListeners();
    _updateShowDialog(value);
  }

  void _checkIfDialogShouldBeShown() async {
    bool prefDialog = _prefs.getBool(_key) ?? true;
    _showDialog = prefDialog;
    notifyListeners();
  }

  void _updateShowDialog(bool value) async {
    _prefs.setBool(_key, value);
  }
}
