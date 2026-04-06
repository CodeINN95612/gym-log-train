import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_train_log/features/sessions/providers/timer_provider.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });
  group('TimerProvider', () {
    test('initial state is not running', () {
      final timer = TimerProvider();
      expect(timer.isRunning, isFalse);
      expect(timer.remaining, 0);
      timer.dispose();
    });

    test('start sets isRunning and remaining', () {
      fakeAsync((async) {
        final timer = TimerProvider();
        timer.start(60);
        expect(timer.isRunning, isTrue);
        expect(timer.remaining, 60);
        timer.dispose();
      });
    });

    test('remaining decrements each second', () {
      fakeAsync((async) {
        final timer = TimerProvider();
        timer.start(10);
        async.elapse(const Duration(seconds: 3));
        expect(timer.remaining, 7);
        timer.dispose();
      });
    });

    test('timer stops when reaching zero', () {
      fakeAsync((async) {
        final timer = TimerProvider();
        timer.start(3);
        async.elapse(const Duration(seconds: 4));
        expect(timer.isRunning, isFalse);
        expect(timer.remaining, 0);
        timer.dispose();
      });
    });

    test('skip stops the timer', () {
      fakeAsync((async) {
        final timer = TimerProvider();
        timer.start(60);
        async.elapse(const Duration(seconds: 5));
        timer.skip();
        expect(timer.isRunning, isFalse);
        expect(timer.remaining, 0);
        timer.dispose();
      });
    });

    test('addThirty adds 30 seconds when running', () {
      fakeAsync((async) {
        final timer = TimerProvider();
        timer.start(90);
        async.elapse(const Duration(seconds: 10));
        timer.addThirty();
        expect(timer.remaining, 110); // 80 + 30
        timer.dispose();
      });
    });

    test('addThirty does nothing when not running', () {
      fakeAsync((async) {
        final timer = TimerProvider();
        timer.addThirty();
        expect(timer.remaining, 0);
        timer.dispose();
      });
    });

    test('setPreset changes preset and restarts timer', () {
      fakeAsync((async) {
        final timer = TimerProvider();
        timer.start(90);
        async.elapse(const Duration(seconds: 30));
        timer.setPreset(120);
        expect(timer.preset, 120);
        expect(timer.remaining, 120);
        expect(timer.isRunning, isTrue);
        timer.dispose();
      });
    });

    test('progress goes from 1.0 to 0.0', () {
      fakeAsync((async) {
        final timer = TimerProvider();
        timer.start(10);
        expect(timer.progress, closeTo(1.0, 0.01));
        async.elapse(const Duration(seconds: 5));
        expect(timer.progress, closeTo(0.5, 0.01));
        timer.dispose();
      });
    });

    test('default preset is 90 seconds', () {
      fakeAsync((async) {
        final timer = TimerProvider();
        timer.start();
        expect(timer.preset, 90);
        expect(timer.remaining, 90);
        timer.dispose();
      });
    });

    test('notifyListeners called on each tick', () {
      fakeAsync((async) {
        final timer = TimerProvider();
        int notifyCount = 0;
        timer.addListener(() => notifyCount++);
        timer.start(5);
        notifyCount = 0; // reset after start notify
        async.elapse(const Duration(seconds: 3));
        expect(notifyCount, greaterThanOrEqualTo(3));
        timer.dispose();
      });
    });
  });
}
