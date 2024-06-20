import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({
    super.key,
    required this.taskForProgressIndicator,
  });

  final Future taskForProgressIndicator;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/message-ring.svg',
                    height: 50,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.primary.withBlue(200),
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: SimulatedProgressIndicator(
                      task: taskForProgressIndicator,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SimulatedProgressIndicator extends StatefulWidget {
  const SimulatedProgressIndicator({
    required this.task,
    super.key,
  });

  final Future<void> task;

  @override
  State<SimulatedProgressIndicator> createState() =>
      _SimulatedProgressIndicatorState();
}

class _SimulatedProgressIndicatorState
    extends State<SimulatedProgressIndicator> {
  double _progressValue = 0.0;
  Timer? _timer;
  bool _isTaskComplete = false;

  @override
  void initState() {
    super.initState();
    _startSimulatingProgress();
    _completeTask();
  }

  void _startSimulatingProgress() {
    const duration = Duration(milliseconds: 5);
    _timer = Timer.periodic(duration, (Timer timer) {
      if (_isTaskComplete) {
        setState(() {
          _progressValue = 1.0;
          timer.cancel();
        });
        return;
      }
      setState(() {
        if (_progressValue < 0.8) {
          _progressValue += 0.2; // Uniform progress to 80%
        } else if (_progressValue < 1.0) {
          _progressValue += 0.05; // Slow progress after 80%
        }

        if (_progressValue >= 1.0) {
          _progressValue = 1.0;
          timer.cancel();
        }
      });
    });
  }

  void _completeTask() {
    widget.task.then((_) {
      setState(() {
        _isTaskComplete = true;
        _progressValue = 1.0;
        _timer?.cancel();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(value: _progressValue),
      ],
    );
  }
}
