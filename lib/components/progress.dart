import 'package:flutter/material.dart';

class StepsProgress extends StatefulWidget {
  //StepsProgress({Key? key, steps, target}) : super(key: key);
  int steps = 1;
  int target = 1;
  StepsProgress(this.steps, this.target);

  @override
  State<StepsProgress> createState() => _StepsProgressState();
}

class _StepsProgressState extends State<StepsProgress> with TickerProviderStateMixin {
  late AnimationController controller;
  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      value: getProgress(widget.steps, widget.target),
    )..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  double getProgress(int steps, int target) {
    try {
      if ((steps / target) < 0.1) {
        return 0.1;
      } else {
        return steps / target;
      }
    } catch (UnsupportedError) {
      return 0.1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CircularProgressIndicator(
        value: getProgress(widget.steps, widget.target),
        semanticsLabel: 'Linear progress indicator',
        strokeWidth: 100,
        backgroundColor: Colors.lightBlue[100],
      ),
    ]);
  }
}
