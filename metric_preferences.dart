import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PerformanceMetric { rir, rpe }

class MetricPreferences extends ChangeNotifier {
  late SharedPreferences _preferences;
  final String _key = 'metric';
  PerformanceMetric _selectedMetric = PerformanceMetric.rir;

  PerformanceMetric get selectedMetric => _selectedMetric;

  Future<void> _initPreferences() async {
    _preferences = await SharedPreferences.getInstance();
    _getMetricPreferences();
  }

  MetricPreferences() {
    _initPreferences();
  }

  void _getMetricPreferences() async {
    String performanceMetric =
        _preferences.getString(_key) ?? PerformanceMetric.rir.toString();
    _selectedMetric = PerformanceMetric.values.firstWhere(
      (element) => element.toString() == performanceMetric,
      orElse: () => PerformanceMetric.rir,
    );
    notifyListeners();
  }

  set selectedMetric(PerformanceMetric metric) {
    _selectedMetric = metric;
    notifyListeners();
    _setMetricPreferences(metric);
  }

  void _setMetricPreferences(PerformanceMetric metric) async {
    await _preferences.setString(_key, metric.toString());
  }
}
