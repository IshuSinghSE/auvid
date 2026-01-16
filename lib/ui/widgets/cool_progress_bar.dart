import 'package:flutter/material.dart';

/// A custom styled progress bar with glow effect
class CoolProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Color? color;
  final Color? backgroundColor;
  final bool showGlow;

  const CoolProgressBar({
    super.key,
    required this.progress,
    this.height = 8.0,
    this.color,
    this.backgroundColor,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    final progressColor = color ?? Theme.of(context).primaryColor;
    final bgColor = backgroundColor ?? 
        Theme.of(context).colorScheme.surfaceVariant;

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        color: bgColor,
      ),
      child: Stack(
        children: [
          // Progress fill
          FractionallySizedBox(
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(height / 2),
                gradient: LinearGradient(
                  colors: [
                    progressColor,
                    progressColor.withOpacity(0.8),
                  ],
                ),
                boxShadow: showGlow
                    ? [
                        BoxShadow(
                          color: progressColor.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
          // Animated shimmer effect
          if (progress > 0 && progress < 1)
            AnimatedProgressShimmer(
              progress: progress,
              height: height,
              color: progressColor,
            ),
        ],
      ),
    );
  }
}

class AnimatedProgressShimmer extends StatefulWidget {
  final double progress;
  final double height;
  final Color color;

  const AnimatedProgressShimmer({
    super.key,
    required this.progress,
    required this.height,
    required this.color,
  });

  @override
  State<AnimatedProgressShimmer> createState() =>
      _AnimatedProgressShimmerState();
}

class _AnimatedProgressShimmerState extends State<AnimatedProgressShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FractionallySizedBox(
          widthFactor: widget.progress.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.height / 2),
              gradient: LinearGradient(
                begin: Alignment(-1.0 + (_controller.value * 2), 0),
                end: Alignment(1.0 + (_controller.value * 2), 0),
                colors: [
                  Colors.transparent,
                  widget.color.withOpacity(0.3),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }
}
