import 'package:flutter/material.dart';
import 'package:game_edu/common/constants/ui/padding_constants.dart';
import 'package:game_edu/common/constants/ui/radius_constants.dart';
import 'package:game_edu/common/theme/app_palette.dart';


class CardContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final double? borderRadius;

  const CardContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(PaddingConstants.small),
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppPalette.cardSurfaceColor,
        borderRadius: BorderRadius.circular(
          borderRadius ?? RadiusConstants.large,
        ),
        border: Border.all(
          color: borderColor ?? AppPalette.elevatedSurfaceColor,
          width: borderWidth ?? 1.5,
        ),
      ),
      child: child,
    );
  }
}
