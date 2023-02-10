import 'package:flutter/material.dart';

class InProgressPipelineIcon extends StatefulWidget {
  const InProgressPipelineIcon({
    required this.child,
  });

  final Widget child;

  @override
  State<InProgressPipelineIcon> createState() => _InProgressPipelineIconState();
}

class _InProgressPipelineIconState extends State<InProgressPipelineIcon> with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(seconds: 4))..forward();
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);

    _animationController.addListener(() {
      if (_animationController.status == AnimationStatus.completed) {
        if (!mounted) return;

        setState(() {
          _animationController.repeat();
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _animation,
      child: widget.child,
    );
  }
}
