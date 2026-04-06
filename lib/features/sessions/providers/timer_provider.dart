import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

class TimerProvider extends ChangeNotifier {
  static const int defaultDuration = 90;

  int _preset = defaultDuration;
  int _remaining = 0;
  bool _isRunning = false;
  Timer? _timer;

  int get preset => _preset;
  int get remaining => _remaining;
  bool get isRunning => _isRunning;

  double get progress =>
      _preset > 0 ? (_remaining / _preset).clamp(0.0, 1.0) : 0.0;

  void start([int? seconds]) {
    final duration = seconds ?? _preset;
    _preset = duration;
    _remaining = duration;
    _isRunning = true;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
    notifyListeners();
  }

  void skip() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    _remaining = 0;
    notifyListeners();
  }

  void addThirty() {
    if (_isRunning) {
      _remaining += 30;
      notifyListeners();
    }
  }

  void setPreset(int seconds) {
    _preset = seconds;
    start(seconds);
  }

  void _onTick() {
    if (_remaining <= 0) {
      _timer?.cancel();
      _timer = null;
      _isRunning = false;
      _remaining = 0;
      _vibrate();
      notifyListeners();
      return;
    }
    _remaining--;
    if (_remaining == 0) {
      _timer?.cancel();
      _timer = null;
      _isRunning = false;
      _vibrate();
    }
    notifyListeners();
  }

  void _vibrate() {
    Vibration.vibrate(pattern: [0, 200, 100, 200]);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
