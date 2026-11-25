import 'package:flutter/material.dart';

class PricingResponsiveHeader extends StatelessWidget {
  const PricingResponsiveHeader({
    super.key,
    required this.title,
    required this.titleStyle,
    required this.leading,
    required this.metrics,
    required this.actions,
  });

  final String title;
  final TextStyle titleStyle;
  final List<Widget> leading;
  final List<Widget> metrics;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxWidth < 570 ||
            MediaQuery.textScalerOf(context).scale(16) > 20;
        final heading = Text(
          title,
          style: titleStyle,
          maxLines: compact ? null : 1,
          overflow: compact ? TextOverflow.visible : TextOverflow.ellipsis,
        );
        if (!compact) {
          return Row(
            children: [
              ...leading,
              const SizedBox(width: 8),
              Expanded(child: heading),
              const SizedBox(width: 8),
              ...metrics,
              ...actions,
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            heading,
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [...leading, ...actions],
            ),
            if (metrics.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: metrics,
              ),
          ],
        );
      },
    );
  }
}
